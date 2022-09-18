#!/bin/bash
BASEDIR="$1"
OSENV="$2"
OKCD="$(pwd)"
trap 'cd "$OKCD"' EXIT

if [ "$2" == "linux" ]; then
    tmpdir="$(mktemp -d)"
    cd "$tmpdir"
    cd "`readlink -f .`"
    tmpdir="$(readlink -f .)"

    echo "go is a go"
    curl -qL "https://go.dev/dl/go1.19.1.linux-amd64.tar.gz" -o go.tgz 2>/dev/null || exit 255
    echo "out with the old"
    sudo rm -rf /usr/local/go
    echo "in with the new"
    sudo tar -C /usr/local -xzf "$tmpdir/go.tgz"
    if [ "$tmpdir" != "" ]  || [ -z "$tmpdir" ] || [ "$tmpdir" != "." ]; then
        echo "cleanup"
        nohup bash -c "cd /tmp; rm -rf \"$tmpdir\"" &>/dev/null &
    fi
fi


