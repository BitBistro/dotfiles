#!/bin/bash
# Install GitLab CLI (glab) into ~/.local/bin
set -euo pipefail

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
INSTALL_PATH="$INSTALL_DIR/glab"

# Setup dependencies
if command -v jq >/dev/null 2>&1; then
    JSON=(jq -r)
elif command -v gojq >/dev/null 2>&1; then
    JSON=(gojq -r)
else
    echo "missing dependency: jq or gojq" >&2
    exit 255
fi

# Fetch release metadata from GitLab API
release_json="$(curl -fsSL 'https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases')" || exit 255
_VER_TAG="$(printf '%s\n' "$release_json" | "${JSON[@]}" '.[0].tag_name // empty')"
_LATEST_VER="${_VER_TAG#v}"

if [ -z "$_LATEST_VER" ]; then
    echo "Could not determine latest glab version" >&2
    exit 255
fi

# Check if current install matches latest version
if [ -x "$INSTALL_PATH" ]; then
    _CURRENT_VER_OUT="$("$INSTALL_PATH" --version 2>/dev/null || true)"
    _CURRENT_VER="$(echo "$_CURRENT_VER_OUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)"
    if [ "$_CURRENT_VER" = "$_LATEST_VER" ]; then
        echo "Already have the latest glab ($_LATEST_VER)"
        exit 0
    fi
fi

_DL="https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/packages/generic/glab/${_LATEST_VER}/glab_${_LATEST_VER}_linux_${_ARCH}.tar.gz"

tmpdir="$(mktemp -d)"
trap '[ -n "$tmpdir" ] && [ -d "$tmpdir" ] && rm -rf "$tmpdir"' EXIT
tar_tmp="$tmpdir/glab.tar.gz"

echo "Updating glab to ${_LATEST_VER}"
echo "Downloading $_DL"
curl -fsSL "$_DL" -o "$tar_tmp" || exit 255

tar -xzf "$tar_tmp" -C "$tmpdir" || exit 255

_EXTRACTED_BIN="$(find "$tmpdir" -type f -name glab | head -n1)"
if [ -z "$_EXTRACTED_BIN" ]; then
    echo "Failed to locate glab binary inside archive" >&2
    exit 255
fi

mkdir -p "$INSTALL_DIR"
install -m 0755 "$_EXTRACTED_BIN" "$INSTALL_PATH"
echo "Installed glab to $INSTALL_PATH"
