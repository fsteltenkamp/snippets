#add navigational shortcuts
alias ..='cd ..'
alias ...='cd ../..'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='LC_COLLATE=C ls --color=auto -hAl --group-directories-first'
    alias dir='dir --color=auto -h'
    alias vdir='vdir --color=auto -h'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# Display the directory structure better.
alias tree='tree --dirsfirst -F'

# Make a directory and all parent directories with verbosity.
alias mkdir='mkdir -p -v'

# use hg to search in history
function hg() {
    history | grep "$1";
}

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'