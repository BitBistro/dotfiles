#!/bin/bash
set -euo pipefail
BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" != "linux" ] && [ "$OSENV" != "darwin" ]; then
    exit 0
fi

if command -v uv >/dev/null 2>&1; then
    uv self update
    exit 0
fi

if command -v jq >/dev/null 2>&1; then
    JSON=(jq -r)
elif command -v gojq >/dev/null 2>&1; then
    JSON=(gojq -r)
else
    echo "missing dependency: jq or gojq" >&2
    exit 255
fi

if command -v sha256sum >/dev/null 2>&1; then
    SHA256=(sha256sum)
elif command -v shasum >/dev/null 2>&1; then
    SHA256=(shasum -a 256)
else
    echo "missing dependency: sha256sum or shasum" >&2
    exit 255
fi

release_json="$(curl -fsSL 'https://api.github.com/repos/astral-sh/uv/releases/latest')" || exit 255
_VER="$(printf '%s\n' "$release_json" | "${JSON[@]}" '.tag_name // empty')"
_DL="$(printf '%s\n' "$release_json" | "${JSON[@]}" '.assets[] | select(.name == "uv-installer.sh") | .browser_download_url')"
_DIGEST="$(printf '%s\n' "$release_json" | "${JSON[@]}" '.assets[] | select(.name == "uv-installer.sh") | .digest')"
_EXPECTED="${_DIGEST#sha256:}"

if [ -z "$_VER" ] || [ -z "$_DL" ] || [ -z "$_EXPECTED" ] || [ "$_DIGEST" = "$_EXPECTED" ]; then
    echo "Could not determine latest uv installer metadata" >&2
    exit 255
fi

tmpdir="$(mktemp -d)"
trap '[ -n "$tmpdir" ] && [ -d "$tmpdir" ] && rm -rf "$tmpdir"' EXIT
installer="$tmpdir/uv-installer.sh"

echo "Installing uv $_VER"
echo "Downloading $_DL"
curl --proto '=https' --tlsv1.2 -fsSL "$_DL" -o "$installer" || exit 255

_ACTUAL="$("${SHA256[@]}" "$installer" | awk '{print $1}')"
if [ "$_ACTUAL" != "$_EXPECTED" ]; then
    echo "uv-installer.sh checksum mismatch" >&2
    echo "expected: $_EXPECTED" >&2
    echo "actual:   $_ACTUAL" >&2
    exit 255
fi

sh "$installer"
