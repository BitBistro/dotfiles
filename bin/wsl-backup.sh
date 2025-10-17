#!/bin/bash

READLINK="$(command -v greadlink readlink | head -n1)"
if [ -z "$READLINK" ]; then
    echo "The 'readlink' command cannot be found. This can be installed from GNU coreutils"
    exit 1
fi
THIS=`${READLINK} -f "$0"`
if [ -z "${THIS}" ]; then
    echo "Please install GNU Readlink from coreutils"
    exit 2
fi

export BACKUP_SELF='/mnt/c/Users/Mike.Perry/OneDrive - Sophos Ltd/Backups/wsl-backup'
export RESTIC_REPOSITORY='/mnt/c/Users/Mike.Perry/OneDrive - Sophos Ltd/Backups/WSL'
export RESTIC_PASSWORD_COMMAND="'${THIS}' -p"

function usage() {
    exec 1>&2
    if [ -n "$1" ]; then
        echo "$1"
    fi
    echo "Usage: $0 [flags]"
    echo
    echo "Common Options:"
    echo " -h this [h]elp"
    echo " -q be [q]uiet"
    echo " -v be [v]erbose"
    echo ""
    echo "Actions:"
    echo " -c set pruning policy and [c]lean"
    echo " -e print [e]nv suitable for bash eval"
    echo " -p get [p]assword secret from command"
    echo " -C create repo"
    echo " -R rewrite, use with backup selection"
    echo ""
    echo "Restore Actions: "
    echo " -r <SNAPSHOT_ID> [r]estore; note if unknown try -r list"
    echo " -i <INCLUDE> [i]ncludes subset of files"
    echo " -l <PATH> filter backup by [l]ocation"
    echo " -x <EXCLUDE> e[x]cludes subset of files"
    echo " -t <TARGET> restore [t]arget"
    echo ""
    echo "Backup Selections:"
    echo " -A AppData backup"
    echo " -E /[E]tc backup"
    echo " -F [f]ull backup"
    echo " -L /usr/[L]ocal/ backup"
    echo " -Q [Q]uick backup"
    echo ""
    echo "Other Actions:"
    echo " -f forget backup"
    echo ""
    exit 1
}

ACTION=""
SNAPSHOT=""
DO_RESTORE=""
FOUND_ANY=""
FORGET_SNAPSHOT=""
RESTORE_IN=""
RESTORE_PATH=""
RESTORE_TARGET=""
RESTORE_EX=""
RESTORE_SNAPSHOT="latest"
while builtin getopts ":hcCepqvAEFLQr:i:l:t:x:f:R:" OPT; do
    FOUND_ANY="true"
    case ${OPT} in
        h)
            usage
            ;;
        b)
            ACTION="BACKUP"
            ;;
        c)
            ACTION="CLEAN"
            ;;
        e)
            ACTION="ENV"
            ;;
        f)  ACTION="FORGET"
            FORGET_SNAPSHOT="$OPTARG"
            ;;
        i)
            RESTORE_IN="$OPTARG"
            ;;
        l)
            RESTORE_PATH="$OPTARG"
            ;;
        t)
            RESTORE_TARGET="$OPTARG"
            ;;
        x)
            RESTORE_EX="$OPTARG"
            ;;
        p)
            ACTION="GETPW"
            ;;
        q)
            QUIET="true"
            ;;
        r)
            ACTION="RESTORE"
            RESTORE_SNAPSHOT="$OPTARG"
            ;;
        v)
            set -vx
            ;;
        C)
            ACTION="CREATE"
            ;;
        A)
            SNAPSHOT="APPDATA"
            ;;
        E)
            SNAPSHOT="ETC"
            ;;
        F)
            SNAPSHOT="FULL"
            ;;
        L)
            SNAPSHOT="LOCAL"
            ;;
        Q)
            SNAPSHOT="QUICK"
            ;;
        R)
            ACTION="REWRITE"
            REWRITE_SNAPSHOT="$OPTARG"
            ;;
        V)
            SNAPSHOT="VMS"
            ;;
    esac
done
shift $((OPTIND -1))

if [ -z "$FOUND_ANY" ]; then
    usage "No options selected"
fi

if [ "$QUIET" == "true" ]; then
    exec 1>/dev/null
    VERBOSE=""
else
    VERBOSE="--verbose"
fi

if [ -z "$ACTION" ]; then
    ACTION="BACKUP"
fi

case $ACTION in
    CREATE)
        restic "$VERBOSE" init
        ;;
    BACKUP)
        if [ -z "$SNAPSHOT" ]; then
            usage "No snapshot selected"
        fi
        cp -vf "$THIS" "$BACKUP_SELF"
        restic snapshots
        if [ "$SNAPSHOT" == "QUICK" ]; then
            restic $VERBOSE backup "$HOME" --host localhost --one-file-system --exclude-file=<(awk '/XX_EXCLUDE_LIST$/,/^XX_EXCLUDE_LIST$/{if($0!~/XX_EXCLUDE_LIST/)print}' "${THIS}") --tag "home" --tag "quick"
        elif [ "$SNAPSHOT" == "ETC" ]; then
            restic $VERBOSE backup "/etc" --host localhost --one-file-system --exclude-file=<(awk '/XX_EXCLUDE_LIST$/,/^XX_EXCLUDE_LIST$/{if($0!~/XX_EXCLUDE_LIST/)print}' "${THIS}") --tag "etc"
        elif [ "$SNAPSHOT" == "LOCAL" ]; then
            restic $VERBOSE backup "/usr/local" --host localhost --one-file-system --exclude-file=<(awk '/XX_EXCLUDE_LIST$/,/^XX_EXCLUDE_LIST$/{if($0!~/XX_EXCLUDE_LIST/)print}' "${THIS}") --tag "local"
        elif [ "$SNAPSHOT" == "APPDATA" ]; then
            restic $VERBOSE backup "/mnt/c/Users/Mike.Perry/AppData" --host localhost --one-file-system --exclude-file=<(awk '/XX_EXCLUDE_LIST$/,/^XX_EXCLUDE_LIST$/{if($0!~/XX_EXCLUDE_LIST/)print}' "${THIS}") --tag "appdata"
        elif [ "$SNAPSHOT" == "FULL" ]; then
            restic $VERBOSE backup "/" --host localhost --one-file-system --exclude-file=<(awk '/XX_EXCLUDE_LIST$/,/^XX_EXCLUDE_LIST$/{if($0!~/XX_EXCLUDE_LIST/)print}' "${THIS}") --tag "home" --tag "local" --tag "etc" --tag "full"
        fi
        ;;
    CLEAN)
        restic unlock
        restic cache --max-age=14
        restic cache --cleanup
        restic forget --prune --keep-last 7 --keep-hourly 2 --keep-weekly 2 --keep-monthly 2 --keep-yearly 1
        ;;
    ENV)
        env | sed -nre '/RESTIC_/!d' -e 's/([^=]+)=(.*)/export \1="\2"/pg'
        ;;
    FORGET)
        restic forget "$FORGET_SNAPSHOT"
        ;;
    REWRITE)
        restic rewrite --exclude-file=<(awk '/XX_EXCLUDE_LIST$/,/^XX_EXCLUDE_LIST$/{if($0!~/XX_EXCLUDE_LIST/)print}' "${THIS}") "$REWRITE_SNAPSHOT"
        ;;
    GETPW)
        awk '/XX_REPO_ENC$/,/^XX_REPO_ENC$/{if($0!~/XX_REPO_ENC/)print}' "$0" | gpg --decrypt -q
        ;;
    RESTORE)
        if [ "$RESTORE_SNAPSHOT" == "list" ]; then
            restic snapshots
            exit
        fi

        CMD_ARGS=()

        if [ -n "$VERBOSE" ]; then
            CMD_ARGS+=("--verbose")
        fi

        if [ -n "$RESTORE_PATH" ]; then
            CMD_ARGS+=('--path' "$RESTORE_PATH")
        fi

        if [ -n "$RESTORE_IN" ]; then
            CMD_ARGS+=('--include' "$RESTORE_IN")
        fi

        if [ -n "$RESTORE_EX" ]; then
            CMD_ARGS+=('--EXCLUDE' "$RESTORE_EX")
        fi

        if [ -z "$RESTORE_TARGET" ]; then
            RESTORE_TARGET="$(mktemp -d)"
        fi

        echo "Restoring to $RESTORE_TARGET"
        set -x
        if [ "${#CMD_ARGS[@]}" -gt 0 ]; then
            restic "${CMD_ARGS[@]}" restore "$RESTORE_SNAPSHOT" --host localhost --target "$RESTORE_TARGET"
        else
            restic restore "$RESTORE_SNAPSHOT" --host localhost --target "$RESTORE_TARGET"
        fi
        ;;
esac


:<<XX_EXCLUDE_LIST
$HOME/**/go/pkg/mod
$HOME/OneDrive
$HOME/VirtualDisks
$HOME/tmp
$HOME/.Trash
/**/*cache*
/**/.cache*
/**/*Cache*
/**/Downloads
/**/*OneDrive*
/**/*Temp*
/**/tmp
/**/Tmp
/usr/src
/var/cache
/var/tmp
/var/lib/docker
/mnt/c/**/*log*
/mnt/c
/mnt
XX_EXCLUDE_LIST

:<<XX_REPO_ENC
XX_REPO_ENC
