#!/bin/bash
OSENV="linux"
if [ "$(uname -s | tr '[:upper:]' '[:lower:]')" == "darwin" ]; then
    OSENV="darwin"
fi

FLAVOR="unknown"
if command -v lsb_release &> /dev/null ; then
    FLAVOR="$(tr '[:upper:]' '[:lower:]' <<< "$(lsb_release -i -s)")"
fi

READLINK=$(command -v greadlink readlink | head -n1)
BASEDIR="$($READLINK -f "$(dirname "$0")/..")"

usage() {
    cat <<END_OF_USAGE >&2
$0 [ -y | -h ]

    -y assume yes
    -h this help message

Executes files in ${BASEDIR}/scripts matching pattern [0-9][0-9][a-zA-Z-]+.sh in lexical
order.

END_OF_USAGE
    exit 1
}

run-now() {
    REGEXTYPE=('-regextype' 'egrep')
    REPRE=""
    if [ "$OSENV" == "darwin" ]; then
        REPRE='-E'
        REGEXTYPE=()
    fi
    SCRIPTS=$(command find $REPRE "${BASEDIR}/scripts" "${REGEXTYPE[@]}" -maxdepth 1 -regex '^.*\/[0-9][0-9][a-zA-Z-]+\.sh$' -type f -print | command sort)
    for SCRIPT in $SCRIPTS; do
        echo "Running: $SCRIPT"
        "${SCRIPT}" "${BASEDIR}" "${OSENV}" "${FLAVOR}"
        RC=$?
        if [ $RC -ne 0 ]; then
            echo "Error: script '$SCRIPT' failed with exit code $RC"
            exit "$RC"
        fi
    done
}

case "$1" in
    -y)
        export WITH_FORCE=true
        run-now
        ;;
    -h|help)
        usage
        ;;
    *)
        yn=n
        read -r -p "Process with setup [y/N]? " -n1 yn; echo
        if [ "$yn" == "y" ]; then
            run-now
        else
            echo "Action canceled." >&2
            exit 2
        fi
        ;;
esac

exit 0
