function __prompt_venv {
  # https://stackoverflow.com/questions/15777996/bash-split-string-on-delimiter-assign-segments-to-array
  [[ -n "$VIRTUAL_ENV" ]] || return 1
  local idx path IFS=/
  set -f
  path=( $VIRTUAL_ENV )
  set +f
  for ((idx=${#path[@]}-1; idx>=0; idx--)); do
    [ "${path[idx]}" != "env" ] && break
  done
  printf "(%s)" ${path[idx]}
}
function __prompt_user_host {
  # arg: see default user and host 1 or 0
  # arg: default username
  local myuser=""
  local myhost=""
  if [ $1 -eq 1 -o "$USER" != "${2}" ]; then
    myuser=${USER}
  fi
  if [ $1 -eq 1 -o -n "${SSH_CLIENT}" ]; then
    if [[ -n ${ZSH_VERSION-} ]]; then myhost="%m";
    elif [[ -n ${FISH_VERSION-} ]]; then myhost=`hostname -s`;
    else myhost="\\h"; fi
  fi
  if [ -z "$myuser" -a -z "$myhost" ]; then
    return 1
  elif [ -n "$myuser" -a -n "$myhost" ]; then
    printf "%s@%s" $myuser $myhost
  elif [ -n "$myuser" ]; then
    printf "$myuser"
  else
    printf "$myhost"
  fi
}
function __prompt_git {
  local branch
  #local branch_symbol="⎇ "  # "\u2387"
  local branch_symbol=""

  # git
  if hash git 2>/dev/null; then
    if branch=$( { git symbolic-ref --short --quiet HEAD || git rev-parse --short HEAD; } 2>/dev/null ); then
      # ${parameter##word} Remove longest matching prefix pattern
      branch=${branch##*/}
      printf "%s" "${branch_symbol}${branch:-unknown}"
      return
    fi
  fi
  return 1
}
function __prompt_cwd {
  local dir_limit="3"
  local truncation="..."
  local first_char
  local part_count=0
  local formatted_cwd=""
  local dir_sep="/"
  local tilde="~"
  local cwd="${PWD/#$HOME/$tilde}"

  # get first char of the path, i.e. tilde or slash
  [[ -n ${ZSH_VERSION-} ]] && first_char=$cwd[1,1] || first_char=${cwd::1}

  # remove leading tilde
  cwd="${cwd#\~}"

  while [[ "$cwd" == */* && "$cwd" != "/" ]]; do
    # pop off last part of cwd
    local part="${cwd##*/}"
    cwd="${cwd%/*}"

    formatted_cwd="$dir_sep$part$formatted_cwd"
    part_count=$((part_count+1))

    [[ $part_count -eq $dir_limit ]] && first_char="$truncation" && break
  done

  printf "%s" "$first_char$formatted_cwd"
}
# For division between sections, take a look at U2590 clinton▐t420
function __prompt_wrap {
  # wrap the text in $1 with $2 and $3 if $1 not empty
  [[ -n "$1" ]] || return 1
  printf "%s" "${2}${1}${3}"
}
function __prompt_left {
  local is_empty=1

  # section virtual env
  local prefix="${FG_ORANGE}"
  local suffix=" "

  __prompt_wrap "$(__prompt_venv)" $prefix "$suffix" && { is_empty=0; }
  
  # section user@host
  prefix="${FG_BLUE}"

  __prompt_wrap "$(__prompt_user_host 0 $default_user)" $prefix "$suffix" && { is_empty=0; }

  # section git
  prefix="${FG_VIOLET}"
  __prompt_wrap "$(__prompt_git)" ${prefix} "$suffix" && { is_empty=0; }

  # section CWD
  __prompt_wrap "$(__prompt_cwd)" "${RESET}" $suffix

  printf " \\$ "
}
# function __prompt_right {
#   #export PS1="\[$(tput sc; __prompt_git; tput rc)\]$PS1"
#   _prompt_wrap "$(__prompt_git)" "[" "]" && { empty=0 }
# }
function __prompt_ps1 {
#   #export PS1="\[$(tput sc; __prompt_git; tput rc)\]$PS1"
  __prompt_left
}
function __prompt {
  local default_user=""
  local sep=" "
  local esc=$'[' _esc=m
  if [[ -n ${ZSH_VERSION-} ]]; then local noprint='{%' _noprint='%}'
  elif [[ -n ${FISH_VERSION-} ]]; then local noprint='' _noprint=''
  else local noprint='\[' _noprint='\]'
  fi
  local wrap="$noprint$esc"  _wrap="$_esc$_noprint"
  local a_fg="${wrap}38;5;220${_wrap}"
  local a_bg="${wrap}48;5;166${_wrap}"
  local DIM="\[$(tput dim)\]"
  local REVERSE="\[$(tput rev)\]"
  local RESET="\[$(tput sgr0)\]"
  local BOLD="\[$(tput bold)\]"
  local PUSH="\[$(tput sc)\]"
  local POP="\[$(tput rc)\]"

  local FG_YELLOW="\[$(tput setaf 136)\]"
  local FG_ORANGE="\[$(tput setaf 166)\]"
  local FG_RED="\[$(tput setaf 160)\]"
  local FG_MAGENTA="\[$(tput setaf 125)\]"
  local FG_VIOLET="\[$(tput setaf 61)\]"
  local FG_BLUE="\[$(tput setaf 33)\]"
  local FG_CYAN="\[$(tput setaf 37)\]"
  local FG_GREEN="\[$(tput setaf 64)\]"

  local BG_YELLOW="\[$(tput setab 136)\]"
  local BG_ORANGE="\[$(tput setab 166)\]"
  local BG_RED="\[$(tput setab 160)\]"
  local BG_MAGENTA="\[$(tput setab 125)\]"
  local BG_VIOLET="\[$(tput setab 61)\]"
  local BG_BLUE="\[$(tput setab 33)\]"
  local BG_CYAN="\[$(tput setab 37)\]"
  local BG_GREEN="\[$(tput setab 64)\]"


  if [[ -n ${ZSH_VERSION-} ]]; then
    PROMPT="$(__prompt_left)"
    PROMPTR="$(__prompt_right)"
  elif [[ -n ${FISH_VERSION} ]]; then
    if [[ -n "$1" ]]; then
      [[ "$1" = "left" ]] && __prompt_left_prompt || __prompt_right_prompt
    else
      __prompt_ps1
    fi
  else
    #__prompt_ps1
    PS1="$(__prompt_ps1)"
  fi
}

if [[ -n ${ZSH_VERSION-} ]]; then
  if [[ ! ${precmd_function[(r)__prompt]} == __prompt ]]; then
    precmd_functions+=(__prompt)
  fi
elif [[ -n ${FISH_VERSION-} ]]; then
  __prompt "$1"
else
  if [[ ! "$PROMPT_COMMAND" == *__prompt* ]]; then
    PROMPT_COMMAND='__prompt;'$'\n'"$PROMPT_COMMAND"
  fi
fi
