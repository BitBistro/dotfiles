#!/bin/bash
set -euo pipefail
BASEDIR="$1"
OSENV="$2"
OKCD="$(pwd)"
trap 'cd "$OKCD"' EXIT

if [ "$OSENV" != "linux" ] && [ "$OSENV" != "darwin" ]; then
    exit 0
fi

_VER="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)"
if [ -z "$_VER" ]; then
    echo "Could not determine latest Go version" >&2
    exit 255
fi

case "$(uname -m)" in
    x86_64|amd64) _ARCH=amd64 ;;
    aarch64|arm64) _ARCH=arm64 ;;
    armv6l|armv7l) _ARCH=armv6l ;;
    *) echo "Unsupported arch: $(uname -m)" >&2; exit 255 ;;
esac

_OS=linux
[ "$OSENV" = "darwin" ] && _OS=darwin
_DL="https://go.dev/dl/${_VER}.${_OS}-${_ARCH}.tar.gz"

if [ -f /usr/local/go/VERSION ] && [ "$_VER" = "$(head -n1 /usr/local/go/VERSION)" ]; then
    echo "Already have the latest go ($_VER)"
    exit 0
fi

tmpdir="$(mktemp -d)"
trap 'cd "$OKCD"; [ -n "$tmpdir" ] && [ -d "$tmpdir" ] && rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

echo "Updating Go to $_VER"
echo "Downloading $_DL"
curl -fsSL "$_DL" -o go.tgz || exit 255

echo "Removing old install"
sudo rm -rf /usr/local/go

echo "Installing"
sudo tar -C /usr/local -xzf "$tmpdir/go.tgz"
