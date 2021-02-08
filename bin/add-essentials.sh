#!/bin/bash

set -e
BASEDIR="$(readlink -f `dirname  $0`/..)";
. $BASEDIR/overlay/.env

if [ `id -u` -ne '0' ]; then
    if [ -z $NO_RECURSE ]; then
        export NO_RECURSE=1
        exec sudo /bin/bash -e "$0"
    else
        echo "This must be run as root" >&2 && false
    fi
fi

TEMPFILE="$(mktemp)"
trap '/bin/rm -f -- "$TEMPFILE"' EXIT
apt-config dump | egrep 'APT::Install' | sed -re 's/1/0/g' > $TEMPFILE
export APT_CONFIG="$TEMPFILE"

/usr/bin/apt-get update
/usr/bin/apt-get -y install aptitude aptitude-doc-en
/usr/bin/aptitude -y safe-upgrade
/usr/bin/aptitude -y install "?and(?architecture(native),?or(~prequired))" bash-completion vim-nox git rsync
