BASEDIR="$1"
OSENV="$2"
OKCD="$(pwd)"
trap 'cd "$OKCD"' EXIT

if [ "$OSENV" == "linux" ]; then
    _VER="go1.24.5"
    _DL="https://go.dev/dl/${_VER}.linux-amd64.tar.gz"

    if [ ! -f /usr/local/go/VERSION ] || [ "$_VER" != "$(cat /usr/local/go/VERSION)" ]; then
        tmpdir="$(mktemp -d)"
        cd "$tmpdir"
        cd "`readlink -f .`"
        tmpdir="$(readlink -f .)"

        echo "go is a go"
        curl -qL "$_DL" -o go.tgz 2>/dev/null || exit 255
        echo "out with the old"
        sudo rm -rf /usr/local/go
        echo "in with the new"
        sudo tar -C /usr/local -xzf "$tmpdir/go.tgz"
        if [ "$tmpdir" != "" ]  || [ -z "$tmpdir" ] || [ "$tmpdir" != "." ]; then
            echo "cleanup"
            nohup bash -c "cd /tmp; rm -rf \"$tmpdir\"" &>/dev/null &
        fi
    else
        echo "Already have the latest go"
    fi
fi


