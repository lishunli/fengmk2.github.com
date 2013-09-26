# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

ulimit -n 10240

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt



##### git master #####
# https://gist.github.com/120804

# COLORS
LIGHT_GRAY="\[\033[0;37m\]"; BLUE="\[\033[1;36m\]"; RED="\[\033[0;31m\]"; LIGHT_RED="\[\033[1;31m\]"; 
GREEN="\[\033[0;32m\]"; WHITE="\[\033[1;37m\]"; LIGHT_GRAY="\[\033[0;37m\]"; YELLOW="\[\033[1;33m\]";
# GIT PROMPT (http://gist.github.com/120804)
function parse_git_branch { 
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \(\1\)/'; 
}
function parse_git_status { 
  git status 2> /dev/null | sed -e '/(working directory clean)$/!d' | wc -l; 
}
function check_git_changes { 
  # tput setaf 1 = RED, tput setaf 2 = GREEN
  [ `parse_git_status` -ne 1 ] && tput setaf 1 || tput setaf 2
} 
export PS1="${debian_chroot:+($debian_chroot)}$BLUE\u@$YELLOW\w\[\$(check_git_changes)\]\$(parse_git_branch)$LIGHT_GRAY $ "

##### git master end #####


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -GalF'
alias la='ls -A'
alias ls='ls -G'
alias l='ls -CFG'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

test -r /sw/bin/init.sh && . /sw/bin/init.sh
#export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH

export SVN_EDITOR="/usr/bin/vim"
#export PATH=$PATH:/usr/local/mysql/bin
#export PATH=$PATH:/Developer/usr/bin
#export PATH=$PATH:$HOME/node_modules/.bin

# see http://www.codethatmatters.com/2010/01/git-autocomplete-in-mac-os-x/
source ~/git/fengmk2.github.com/git-completion.bash
# npm completion
source ~/git/fengmk2.github.com/npm-completion.bash

#nvm
. ~/git/nvm/nvm.sh
[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion

# node_modules bin & mongodb 
export PATH=$HOME/node_modules/.bin:$HOME/git/depot_tools:$HOME/apps/mongodb/bin:$PATH

# chromedriver
#export PATH=$HOME/git/ghost/bin:$PATH

# Setting for the new UTF-8 terminal support in Lion
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# alias to nw
#alias nw="/Applications/nw.app/Contents/MacOS/node-webkit"
#alias node-webkit="/Applications/nw.app/Contents/MacOS/node-webkit"

# spot
export PATH=$HOME/git/spot:$PATH

alias sublime="/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl"
#alias sublime3="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"

# git
alias gca="git commit -a"
alias gd="git diff"
alias gl="git log --graph"
alias gs="git status"
alias ga="git add"
alias gb="git branch -av"
alias gr="git remote -v"
alias gp="git pull -p"

# fengmk2 bin
export PATH=$HOME/git/fengmk2.github.com/bin:$HOME/git/ngen/bin:$HOME/git/watch:$PATH

# github proxy remote
# http://twopenguins.org/tips/git-through-proxy.php
alias gpl='export -n GIT_PROXY_COMMAND'
alias gpr='export GIT_PROXY_COMMAND="$HOME/git/fengmk2.github.com/proxy-wrapper"'


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# HBASE
#export HADOOP_HOME=$HOME/apps/hadoop-1.0.4
export JAVA_HOME=`/usr/libexec/java_home -v 1.6`

export PATH=$HOME/apps/apache-maven-2.2.1/bin:$PATH

# ADT
export PATH=$HOME/AliDrive/adt-bundle-mac-x86_64/sdk/tools:$HOME/AliDrive/adt-bundle-mac-x86_64/sdk/platform-tools:$PATH

# local/bin
export PATH=$HOME/local/bin:$PATH

# phantomjs
export PATH=$HOME/apps/phantomjs/bin:$PATH

