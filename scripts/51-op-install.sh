#!/bin/bash
# Install 1Password CLI (op) into ~/.local/bin
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
INSTALL_PATH="$INSTALL_DIR/op"

# Check dependencies
if ! command -v unzip >/dev/null 2>&1; then
    echo "missing dependency: unzip" >&2
    exit 255
fi

# Fetch release metadata from 1Password release history page
release_html="$(curl -fsSL 'https://app-updates.agilebits.com/product_history/CLI2')" || exit 255
_DL="$(printf '%s\n' "$release_html" | grep -oE "https://[^\"]+op_linux_${_ARCH}[^\"]+\.zip" | grep -v 'beta' | awk 'NR==1')"
_VER_TAG="$(echo "$_DL" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | awk 'NR==1')"
_LATEST_VER="${_VER_TAG#v}"

if [ -z "$_LATEST_VER" ] || [ -z "$_DL" ]; then
    echo "Could not determine latest 1Password CLI version or download URL" >&2
    exit 255
fi

# Check if current install matches latest version
if [ -x "$INSTALL_PATH" ]; then
    _CURRENT_VER_OUT="$("$INSTALL_PATH" --version 2>/dev/null || true)"
    _CURRENT_VER="$(echo "$_CURRENT_VER_OUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | awk 'NR==1' || true)"
    if [ "$_CURRENT_VER" = "$_LATEST_VER" ]; then
        echo "Already have the latest 1Password CLI ($_LATEST_VER)"
        exit 0
    fi
fi

tmpdir="$(mktemp -d)"
trap '[ -n "$tmpdir" ] && [ -d "$tmpdir" ] && rm -rf "$tmpdir"' EXIT
zip_tmp="$tmpdir/op.zip"

echo "Updating 1Password CLI to ${_LATEST_VER}"
echo "Downloading $_DL"
curl -fsSL "$_DL" -o "$zip_tmp" || exit 255

unzip -q -o "$zip_tmp" op -d "$tmpdir" || exit 255

mkdir -p "$INSTALL_DIR"
install -m 0755 "$tmpdir/op" "$INSTALL_PATH"
echo "Installed 1Password CLI to $INSTALL_PATH"
