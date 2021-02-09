# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# ENV always runs. If bash is a login shell, it will call .bashrc which pulls
# in ENV. Non-interactive bash will source ENV. Dash and other stuff will call
# ENV always. EVERYBODY ENV
if [ -r "${HOME}/.env" ]; then
    export ENV="${HOME}/.env"
    export BASH_ENV="${ENV}"
fi

# If running bash then run the bash rc which will exit fast if not interactive
if [ "$BASH_VERSION" ] && [ "$BASH" != "/bin/sh" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc" || true
    fi
else
    if [ -r "$ENV" ]; then
        . "$ENV" || true
    fi
fi
