#!/bin/bash

set -e
BASEDIR="$(readlink -f `dirname  $0`/..)";
. $BASEDIR/overlay/.env

if [ `id -u` -ne '0' ]; then
    if [ -z $NO_RECURSE ]; then
        export NO_RECURSE=1
        exec sudo LEVEL=$LEVEL /bin/bash -e "$0"
    else
        echo "This must be run as root" >&2 && false
    fi
fi

TEMPFILE="$(mktemp)"
trap '/bin/rm -f -- "$TEMPFILE"' EXIT
apt-config dump | egrep 'APT::Install' | sed -re 's/1/0/g' > $TEMPFILE
export APT_CONFIG="$TEMPFILE"

if [ -z "$LEVEL" ]; then
    LEVEL="base"
fi

case $LEVEL in
    "base")
        apt-get update
        apt-get -y install aptitude aptitude-doc-en
        aptitude update
        aptitude -y safe-upgrade
        aptitude -y install "?and(?architecture(native),?or(~prequired))" bash-completion vim-nox git rsync pinentry-tty\
                pinentry-curses_ gpg-agent
    ;;
    "standard")
        aptitude update
        aptitude -y safe-upgrade
        aptitude -r install "?and(?architecture(native),?or(~prequired,~pimportant,~pstandard),?not(rsyslog))" bsd-mailx
    ;;
    *)
        echo "Not implemented" >&2
    exit 1
esac

exit 0
