# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Always make sure this is executed if available
if [ -n "$BASH_ENV" ]; then . "$BASH_ENV" || true ; fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# If setting term to xterm when it isn't, this will fix line drawing
# commented out for now, because the term should be set properly
if [ -n $SOMMELIER_VERSION ]; then
    if echo $LANG | command grep -qi utf8; then
        export NCURSES_NO_UTF8_ACS=1
    fi
fi

if [ -e /usr/bin/less ]; then
    PAGER=less
    MANPAGER=less
fi
LESS="FRiX"
EDITOR=vi
if command -v vim &> /dev/null; then
    EDITOR=vim
    alias vi='vim'
fi
if command -v nvim &> /dev/null; then
    EDITOR=nvim
    alias vim="nvim"
fi
PS1='$ '

addPATH () {
    if [ -d "$1" ]; then
        if echo "${PATH}" | command egrep -vq "(^|:)$1($|:)" ; then
            PATH="$1:$PATH"
        fi
    fi
}

addCDPATH () {
    if [ -d "$1" ]; then
        if echo "${CDPATH}" | command egrep -vq "(^|:)$1($|:)" ; then
            if [ -z "$CDPATH" ]; then
                CDPATH="./"
            fi
            CDPATH="$CDPATH:$1"
        fi
    fi
}

goto() {
    if [ -n "$1" ]; then
        _path="$(cd "$1" &>/dev/null && readlink -f .)"
        if [ $? == 0 ] && [ -n "$_path" ]; then
            cd "$_path"
        else
            return 1
        fi
    else
        return 1
    fi
}

if [ "`id -u`" -eq 0 ]; then
    PS1='# '
    mesg n || true
else
    TZ="America/New_York"
    addPATH /usr/local/games
    addPATH /usr/games
    # For Darwin
    addPATH /usr/local/opt/coreutils/libexec/gnubin
    # set PATH so it includes user's private bin if it exists
    addPATH "${HOME}/bin"
    addPATH "${HOME}/.../bin"
    addPATH "${HOME}/.local/bin"
    addCDPATH "${HOME}/...:"
fi

export PAGER MANPAGER LESS EDITOR
export PS1 PATH

XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}"
if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    # systemd-created directory doesn't exist
    XDG_RUNTIME_DIR=$(mktemp -d "/tmp/xdg-runtime-$(id -u)-XXXXXX")
fi

# Check dir has got the correct type, ownership, and permissions
if ! [[ -d "$XDG_RUNTIME_DIR" && -O "$XDG_RUNTIME_DIR" &&
    "$(stat -c '%a' "$XDG_RUNTIME_DIR")" = 700 ]]; then
    chmod 0700 "$XDG_RUNTIME_DIR" &>/dev/null
fi

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export TZ="America/New_York"
export HISTTIMEFORMAT="%F %T "
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTIGNORE='history'
export HISTCONTROL=ignorespace:erasedups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    prompt_context=$(cat /etc/debian_chroot)
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion || true
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion || true
  fi
  if type brew &>/dev/null; then
    HAS_BREW="true"
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
      source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" || true
    else
      for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
        [[ -r "$COMPLETION" ]] && source "$COMPLETION" || true
      done
    fi
  fi
fi

# make less more friendly for non-text input files, see lesspipe(1) and less(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt

color_prompt=
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
else
    case "$TERM" in
        xterm-color|*-256color|linux|iTerm*|iterm*) color_prompt=yes;;
    esac
fi

# Do not run command not found and skip the fancy git prompt when running as root

SKIP_GIT_PROMPT=
if [ "`id -u`" -eq 0 ]; then
    SKIP_GIT_PROMPT=true
    SKIP_SSH_AGENT=true
    unset command_not_found_handle
fi

# Sets up the fancy or not so fanyc prompt

if [ "$color_prompt" = yes ]; then
    # Adds the git branch to your prompt
    if [ -z "$SKIP_GIT_PROMPT" -a -x "/usr/bin/git" ]; then
        git_branch_color="0m"
        git_branch=""
        git_dirty=""
        git_space=""

        # Based on https://github.com/jimeh/git-aware-prompt/blob/master/prompt.sh
        function find_git_branch() {
            local branch
            git_branch_color="0m"
            git_branch=""
            git_dirty=""
            git_space=""
            if branch=$(command git rev-parse --abbrev-ref HEAD 2> /dev/null); then
                if [[ $branch == "master" || $branch == "HEAD" ]]; then
                    git_branch_color="33m"
                fi
                local status=$(command git status --porcelain 2> /dev/null)
                if [[ "$status" != "" ]]; then
                    git_dirty="*"
                fi
                git_branch=" ($branch)"
                git_space=" "
            fi
        }

        if [[ ! $PROMPT_COMMAND =~ "find_git_branch" ]]; then
            if [ -n "$HAS_BREW" ]; then
                PROMPT_COMMAND="/usr/bin/git --version &>/dev/null & disown; PROMPT_COMMAND=\"find_git_branch; $PROMPT_COMMAND\""
            else
                PROMPT_COMMAND="find_git_branch; $PROMPT_COMMAND"
            fi
        fi
    fi

    # Sets up a super fancy color prompt that includes the git variables. If git prompts are set the prompt will still be fine.
    PS1="\${prompt_context:+(\[\033[\${prompt_context_color}\]\${prompt_context}\[\033[00m\]) }\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[\${git_branch_color}\]\${git_branch}\[\e[0;31m\]\${git_dirty}\[\033[00m\]\${git_space}\\$ "
else
    # set a fancy prompt (non-color, overwrite the one in /etc/profile)
    # but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
    if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
        PS1='${prompt_context:+$prompt_context }\u@\h:\w\$ '
    fi
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;\${prompt_context:+\$prompt_context }\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

unset color_prompt SKIP_GIT_PROMPT HAS_BREW
export PS1

if [ -z $SKIP_GPG_AGENT ] && type gpg-agent &>/dev/null; then
    export GPG_TTY=$(tty)
    export GPG_AGENT_INFO=true
    export GNUPGHOME="${GNUPGHOME:-"$HOME/.gnupg"}"
    export GNUPGCONFIG="${GNUPGHOME}/gpg-agent.conf"
    if test ! -S "$(gpgconf --list-dirs agent-socket)"; then
        if uname -a | grep -q microsoft; then
            gpg-agent --daemon --use-standard-socket &>/dev/null;
        elif command -v systemctl &>/dev/null && systemctl --user -q is-system-running &>/dev/null; then
            systemctl --user enable --now gpg-agent.socket
        fi
    fi
    GPG_SSH_AGENT_SOCKET="$(gpgconf --list-dirs agent-ssh-socket)"
    if [ -z "${SSH_AUTH_SOCK}" ] || [ "${SSH_AUTH_SOCK}" != "${GPG_SSH_AGENT_AGENT_SOCKET}" ]; then
        export SSH_AUTH_SOCK="${GPG_SSH_AGENT_SOCKET}"
        unset SSH_AGENT_PID
    fi
    if command -v gpg-connect-agent &>/dev/null; then
        gpg-connect-agent UPDATESTARTUPTTY /bye &>/dev/null
    fi
fi

# Aliases

# Fixes terminal when using the alternative character set
# http://www.in-ulm.de/~mascheck/various/alternate_charset/
alias sout='printf "\033[m\033(B\033)0\016\033[?5l\0337\033[r\0338"'
alias sin='printf "\033[m\033(B\033)0\017\033[?5l\0337\033[r\0338"'

# Top 10 memory hogs
alias hogs='ps -eorss,args | sort -nr | pr -TW$COLUMNS | head'

# Random Character Generator
alias rnd='echo $(dd if=/dev/urandom of=>(strings) bs=1024 count=1 2>/dev/null)'

# enable color support of ls and also add handy aliases
if command -v dircolors &>/dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias grpe='grep --color=auto'
fi
