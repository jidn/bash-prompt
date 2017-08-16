# bash-prompt

*Here is my simple, bash prompt showing the current python virtual environment, git branch and CWD.*

![bash-prompt](https://user-images.githubusercontent.com/3378145/28842715-4c477e88-76c4-11e7-8ec2-a0097d4e3e9d.png)

## Install

You can test this out on your terminal by "sourcing" it into your shell.

``` bash
    $ source ~/{path}/bash-prompt/bash-prompt.sh
```

In your .bashrc file '~/.bashrc', source the contents of bash-prompt.sh.  If you want to push it's use to all users on the system, then make the same modifications to the system wide version of .bashrc in the /etc directory.  Just make the following addition to either file.

``` bash
    source ~/{path}/bash-prompt/bash-prompt.sh
```

## VIRTUAL_ENV

I keep my virtual env in the directory of my project.  It is either called **env** or **.env**, so the existing solutions showing the directory name doesn't help in keeping track of which virtual environment I am using.  This prompt will use the parent name of the virtual environment.  Take a look at the picture to see an example.

## USER

I know who I am.  Most standard bash prompts show it.  This one does also.  However, in the script, you can change it so it only shows the USER if it is not the expected default.  Just put in your username inside the quotes of the default_user in bash-prompt.sh

``` bash
    local default_user=""

    local default_user="clinton"
