# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Always make sure this is executed if available
if [ -n "$BASH_ENV" ]; then . "$BASH_ENV"; fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export TZ="America/New_York"
export HISTSIZE=10000
export HISTFILESIZE=10000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f "${HOME}/.bash_aliases" ]; then
    . "${HOME}/.bash_aliases"
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

# make less more friendly for non-text input files, see lesspipe(1) and less(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)

case "$TERM" in
    xterm-color|*-256color|linux) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt

force_color_prompt=yes

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
        # Based on https://github.com/jimeh/git-aware-prompt/blob/master/prompt.sh
        function find_git_branch() {
            local branch
            git_branch_color="0m"
            git_branch=""
            git_dirty=""
            git_space=""
            if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
                if [[ $branch == "master" || $branch == "HEAD" ]]; then
                    git_branch_color="33m"
                fi
                local status=$(git status --porcelain 2> /dev/null)
                if [[ "$status" != "" ]]; then
                    git_dirty="*"
                fi
                git_branch=" ($branch)"
                git_space=" "
            fi
        }

        if [[ ! $PROMPT_COMMAND =~ "find_git_branch" ]]; then
            export PROMPT_COMMAND="find_git_branch; $PROMPT_COMMAND"
        fi
    fi

    # Sets up a super fancy color prompt that includes the git variables. If git prompts are set the prompt will still be fine.
    PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[\${git_branch_color}\]\${git_branch}\[\e[0;31m\]\${git_dirty}\[\033[00m\]\${git_space}\\$ "
else
    # set a fancy prompt (non-color, overwrite the one in /etc/profile)
    # but only if not SUDOing and have SUDO_PS1 set; then assume smart user.
    if ! [ -n "${SUDO_USER}" -a -n "${SUDO_PS1}" ]; then
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

unset color_prompt force_color_prompt SKIP_GIT_PROMPT
export PS1

if [ -z $SKIP_SSH_AGENT ]; then
    export GPG_TTY=$(tty)
    if [ -z "${SSH_AUTH_SOCK}" ]; then
        if test -x /bin/systemctl && /bin/systemctl --quiet --user is-active gpg-agent-ssh.socket; then
            if [ -z "${SSH_AUTH_SOCK}" ]; then
                unset SSH_AGENT_PID
                export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
            fi
            if [ -x /usr/bin/gpg-connect-agent ]; then
                gpg-connect-agent UPDATESTARTUPTTY /bye &>/dev/null
            fi
        else
            eval `test -x /usr/bin/ssh-agent && /usr/bin/ssh-agent -s`
        fi
    fi
fi
