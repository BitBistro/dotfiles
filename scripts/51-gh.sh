#!/bin/bash
# Install GitHub CLI (gh) into ~/.local/bin
set -eu

# BASEDIR="$1"
OSENV="${2:-linux}"

if [ "$OSENV" != "linux" ] && [ "$OSENV" != "darwin" ]; then
    exit 0
fi

# Detect architecture
case "$(uname -m)" in
    x86_64|amd64) _ARCH="amd64" ;;
    aarch64|arm64) _ARCH="arm64" ;;
    *) echo "Unsupported arch: $(uname -m)" >&2; exit 255 ;;
esac

INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/gh"

# Setup dependencies
if command -v jq >/dev/null 2>&1; then
    JSON=(jq -r)
elif command -v gojq >/dev/null 2>&1; then
    JSON=(gojq -r)
else
    echo "missing dependency: jq or gojq" >&2
    exit 255
fi

# Fetch release metadata from GitHub API
release_json="$(curl -fsSL 'https://api.github.com/repos/cli/cli/releases/latest')" || exit 255
_VER_TAG="$(printf '%s\n' "$release_json" | "${JSON[@]}" '.tag_name // empty')"
_LATEST_VER="${_VER_TAG#v}"

if [ -z "$_LATEST_VER" ]; then
    echo "Could not determine latest gh version" >&2
    exit 255
fi

# Check if current install matches latest version
if [ -x "$INSTALL_PATH" ]; then
    _CURRENT_VER_OUT="$("$INSTALL_PATH" --version 2>/dev/null || true)"
    _CURRENT_VER="$(echo "$_CURRENT_VER_OUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | awk 'NR==1' || true)"
    if [ "$_CURRENT_VER" = "$_LATEST_VER" ]; then
        echo "Already have the latest gh ($_LATEST_VER)"
        exit 0
    fi
fi

_DL="$(printf '%s\n' "$release_json" | "${JSON[@]}" ".assets[] | select(.name | endswith(\"linux_${_ARCH}.tar.gz\")) | .browser_download_url" | awk 'NR==1')"

if [ -z "$_DL" ]; then
    echo "Could not find gh download URL for linux_${_ARCH}" >&2
    exit 255
fi

tmpdir="$(mktemp -d)"
trap '[ -n "$tmpdir" ] && [ -d "$tmpdir" ] && rm -rf "$tmpdir"' EXIT
tar_tmp="$tmpdir/gh.tar.gz"

echo "Updating gh to ${_LATEST_VER}"
echo "Downloading $_DL"
curl -fsSL "$_DL" -o "$tar_tmp" || exit 255

tar -xzf "$tar_tmp" -C "$tmpdir" || exit 255

_EXTRACTED_BIN="$(find "$tmpdir" -type f -name gh | awk 'NR==1')"
if [ -z "$_EXTRACTED_BIN" ]; then
    echo "Failed to locate gh binary inside archive" >&2
    exit 255
fi

mkdir -p "$INSTALL_DIR"
install -m 0755 "$_EXTRACTED_BIN" "$INSTALL_PATH"
echo "Installed gh to $INSTALL_PATH"
