# Fixes terminal when using the alternative character set
# http://www.in-ulm.de/~mascheck/various/alternate_charset/
alias sout='printf "\033[m\033(B\033)0\016\033[?5l\0337\033[r\0338"'
alias sin='printf "\033[m\033(B\033)0\017\033[?5l\0337\033[r\0338"'
alias stitle='PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"'

# Top 10 memory hogs
alias hogs='ps -eorss,args | sort -nr | pr -TW$COLUMNS | head'

# Random Character Generator
alias rnd='echo $(dd if=/dev/urandom of=>(strings) bs=1024 count=1 2>/dev/null)'

alias grpe='grep'
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        alias egrep='egrep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias grep='grep --color=auto'
        alias grpe='grep --color=auto'
fi

alias vi='vim'
