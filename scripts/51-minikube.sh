BASEDIR="$1"
OSENV="$2"
OKCD="$(pwd)"
trap 'cd "$OKCD"' EXIT

if [ "$OSENV" == "linux" ]; then
    tmpdir="$(mktemp -d)"
    cd "$tmpdir"
    cd "`readlink -f .`"
    tmpdir="$(readlink -f .)"
    CURRENT=-1
    if command -v minikube &> /dev/null; then
        CURRENT="$(minikube version --short)"
    fi
    LATEST="$(curl -s https://api.github.com/repos/kubernetes/minikube/releases | awk -F": " '/download_url/&&!/beta/&&/v.*\/minikube-linux-amd64"/{gsub("\"","",$2); print $2;exit}')"
    if [ "$CURRENT" == "-1" ] || ! grep -q "$CURRENT/minikube-linux-amd64"<<<"$LATEST" ; then 
        echo "Updating minikube"
        echo "Downloading"
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 2>/dev/null || echo 255
        echo "Installing"
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        if [ "$tmpdir" != "" ]  || [ -z "$tmpdir" ] || [ "$tmpdir" != "." ]; then
            echo "cleanup"
            nohup bash -c "cd /tmp; rm -rf \"$tmpdir\"" &>/dev/null &
        fi
    else
        echo "minikube up to date"
    fi
fi


