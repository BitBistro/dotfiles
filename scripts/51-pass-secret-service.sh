#!/bin/bash
# Install pass-secret-service using prebuilt release binary.
set -euo pipefail
# BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" != "linux" ]; then
    exit 0
fi

# Detect architecture
case "$(uname -m)" in
    x86_64|amd64) _ARCH="x86_64" ;;
    aarch64|arm64) _ARCH="aarch64" ;;
    *) echo "Unsupported arch: $(uname -m)" >&2; exit 255 ;;
esac

ASSET_NAME="pass-secret-service-${_ARCH}"
INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/pass-secret-service"

# Setup dependencies
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

# Fetch release metadata
release_json="$(curl -fsSL 'https://api.github.com/repos/grimsteel/pass-secret-service/releases/latest')" || exit 255
_VER_TAG="$(printf '%s\n' "$release_json" | "${JSON[@]}" '.tag_name // empty')"
_LATEST_VER="${_VER_TAG#v}"

if [ -z "$_LATEST_VER" ]; then
    echo "Could not determine latest pass-secret-service version" >&2
    exit 255
fi

# Check if current install matches latest version
if [ -x "$INSTALL_PATH" ]; then
    _CURRENT_VER_OUT="$("$INSTALL_PATH" -V 2>&1 || "$INSTALL_PATH" --version 2>&1 || true)"
    _CURRENT_VER="$(echo "$_CURRENT_VER_OUT" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' | head -n1 | sed 's/^v//')"
    if [ "$_CURRENT_VER" = "$_LATEST_VER" ]; then
        echo "Already have the latest pass-secret-service ($_LATEST_VER)"
        exit 0
    fi
fi

# Locate the correct asset URL and digest
_DL="$(printf '%s\n' "$release_json" | "${JSON[@]}" ".assets[] | select(.name == \"$ASSET_NAME\") | .browser_download_url")"
_DIGEST="$(printf '%s\n' "$release_json" | "${JSON[@]}" ".assets[] | select(.name == \"$ASSET_NAME\") | .digest")"
_EXPECTED="${_DIGEST#sha256:}"

if [ -z "$_DL" ] || [ -z "$_EXPECTED" ]; then
    echo "Could not find asset URL or digest for $ASSET_NAME" >&2
    exit 255
fi

tmpdir="$(mktemp -d)"
trap '[ -n "$tmpdir" ] && [ -d "$tmpdir" ] && rm -rf "$tmpdir"' EXIT
binary_tmp="$tmpdir/pass-secret-service"

echo "Updating pass-secret-service to ${_LATEST_VER}"
echo "Downloading $_DL"
curl -fsSL "$_DL" -o "$binary_tmp" || exit 255

_ACTUAL="$("${SHA256[@]}" "$binary_tmp" | awk '{print $1}')"
if [ "$_ACTUAL" != "$_EXPECTED" ]; then
    echo "pass-secret-service checksum mismatch" >&2
    echo "expected: $_EXPECTED" >&2
    echo "actual:   $_ACTUAL" >&2
    exit 255
fi

mkdir -p "$INSTALL_DIR"
install -m 0755 "$binary_tmp" "$INSTALL_PATH"
echo "Installed pass-secret-service to $INSTALL_PATH"
