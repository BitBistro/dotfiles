#!/bin/bash
OSENV="linux"
if [ "$(uname -s | tr A-Z a-z)" == "darwin" ]; then
    OSENV="darwin"
fi

READLINK=$(command -v greadlink readlink | head -n1)
BASEDIR="$($READLINK -f `dirname  $0`/..)";

usage() {
    cat <<END_OF_USAGE >&2
$0 [ -y | -h ]

    -y assume yes
    -h this help message

Executes files in ${BASEDIR} matching regex pattern [0-9][9-9]-*.sh in lexical
order.

END_OF_USAGE
    exit 1
}

run-now() {
    REPOST=('-regextype' 'egrep')
    REPRE=""
    if [ "$OSENV" == "darwin" ]; then
        REPRE='-E'
	REPOST=""
    fi
    SCRIPTS=$(command find $REPRE "${BASEDIR}/scripts" ${REGEXTYPE[*]} -maxdepth 1 -regex '^.*\/[0-9][0-9][a-zA-Z-]+\.sh$' -type f -print | command sort)
    for SCRIPT in $SCRIPTS; do
        echo "Running: $SCRIPT"
        /bin/bash "${SCRIPT}" "${BASEDIR}" "${OSENV}"
        if [ $? -eq 255 ]; then
            echo "Error 255 encountered in script '$SCRIPT'"
            exit 255
        fi
    done
}

case "$1" in
    -y)
        run-now
        ;;
    help)
        usage
        ;;
    *)
        yn=n
        read -p "Process with setup [y/N]? " yn; echo
        if [ "$yn" == "y" ]; then
            run-now
        else
            echo "Action canceled." >&2
            exit 2
        fi
        ;;
esac

exit 0
