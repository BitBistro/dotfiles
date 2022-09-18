SSH_CONFIG="${HOME}/.ssh/config"
exec 11>>"$SSH_CONFIG"

if ! command grep -q '^ *ServerAliveInterval' $HOME/.ssh/config 2>/dev/null ; then
    echo 'ServerAliveInterval 60' >&11
fi

if ! command grep -q '^ *VisualHostKey' $HOME/.ssh/config 2>/dev/null ; then
    echo 'VisualHostKey yes' >&11
fi

if ! command grep -q UPDATESTARTUPTTY $HOME/.ssh/config 2>/dev/null ; then
    echo '# https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9' >&11
    echo 'Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"' >&11
fi

exec 11>&-
