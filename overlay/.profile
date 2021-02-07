# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
export PATH="/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin"
if [ "`id -u`" -eq 0 ]; then
    export PS1='# '
    mesg n || true
else
    export TZ="America/New_York"
    export PATH="$PATH:/usr/local/games:/usr/games"
    export PS1='$ '
fi

# If running bash then run the bash rc which will exit fast if not interactive
if [ "$BASH_VERSION" ] && [ "$BASH" != "/bin/sh" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
