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
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    if [ "$tmpdir" != "" ]  || [ -z "$tmpdir" ] || [ "$tmpdir" != "." ]; then
        echo "cleanup"
        nohup bash -c "cd /tmp; rm -rf \"$tmpdir\"" &>/dev/null &
    fi
fi


