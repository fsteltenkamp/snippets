# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Variables for color
blk='\[\033[01;30m\]'   # Black
red='\[\033[01;31m\]'   # Red
grn='\[\033[01;32m\]'   # Green
ylw='\[\033[01;33m\]'   # Yellow
blu='\[\033[01;34m\]'   # Blue
pur='\[\033[01;35m\]'   # Purple
cyn='\[\033[01;36m\]'   # Cyan
wht='\[\033[01;37m\]'   # White
clr='\[\033[00m\]'      # Reset

HISTCONTROL=ignoreboth  # don't put duplicate lines or lines starting with space in the history.
shopt -s histappend     # append to the history file, don't overwrite it
HISTFILESIZE=99999999
HISTSIZE=99999999
shopt -s checkwinsize   # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
force_color_prompt=yes

# Functions for adding stuff to the prompt:
function git_branch() {
    if [ -d .git ] ; then
        printf "%s" "($(git branch 2> /dev/null | awk '/\*/{print $2}'))";
    fi
}
function docker_container() {
    if ! [ -z "$CONTAINER_ID" ]; then
        printf "%s" "[$CONTAINER_ID]"
    fi
}

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

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
    PS1=${pur}'┌ '${red}'${debian_chroot:+($debian_chroot)}\u'${ylw}'@'${cyn}'\h '${grn}'$(docker_container) '${blu}'$(git_branch) '${ylw}'\w \n'${pur}'└ \$ '${clr}
else
    PS1='┌ ${debian_chroot:+($debian_chroot)}\u@\h $(docker_container):\w\n└ \$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h $(docker_container): \w\a\]$PS1"
    ;;
*)
    ;;
esac

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# alias config
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Kubernetes Config
if [ -f ~/.kubernetes_config ]; then
    . ~/.kubernetes_config
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# PATH Variable:
export PATH="/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin:~/.local/bin:$PATH"
