#!/bin/bash
set -e
BASEDIR="$1"
OSENV="$2"
# FLAVOR="$3" — unused

if [ "$OSENV" != "linux" ] && [ "$OSENV" != "darwin" ]; then
    exit 0
fi

PREFIX="$HOME/.local"
BIN_DIR="$PREFIX/bin"
APP_DIR="$PREFIX/share/applications"
TOOLS_SRC="$BASEDIR/tools"

mkdir -p "$BIN_DIR" "$APP_DIR"

is_wsl() {
    [ -r /proc/version ] \
        && grep -qi 'microsoft' /proc/version 2>/dev/null \
        && command -v wslpath >/dev/null 2>&1
}

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "missing dependency: $1${2:+ ($2)}" >&2
        exit 255
    fi
}

require_file_executable() {
    if [ ! -x "$1" ]; then
        echo "missing dependency: $1${2:+ ($2)}" >&2
        exit 255
    fi
}

# --- backup deps (always) ---
require_cmd gpg "install gnupg"
require_cmd restic "install restic"
if ! command -v greadlink >/dev/null 2>&1 && ! command -v readlink >/dev/null 2>&1; then
    echo "missing dependency: GNU readlink (coreutils)" >&2
    exit 255
fi

# --- pinentry deps (always) ---
require_file_executable /usr/bin/pinentry-fltk  "install pinentry-fltk"
require_file_executable /usr/bin/pinentry-tty   "install pinentry-tty"

install -m 0755 "$TOOLS_SRC/bin/backup"   "$BIN_DIR/backup"
install -m 0755 "$TOOLS_SRC/bin/pinentry" "$BIN_DIR/pinentry"
install -m 0755 "$TOOLS_SRC/bin/keys"     "$BIN_DIR/keys"
echo "installed $BIN_DIR/backup"
echo "installed $BIN_DIR/pinentry"
echo "installed $BIN_DIR/keys"

# --- WSL-only: browser + desktop entry ---
if ! is_wsl; then
    echo "skipping browser install (not WSL)"
    exit 0
fi

require_cmd xdg-settings "install xdg-utils"
require_cmd wslpath
require_cmd explorer.exe
require_cmd rundll32.exe

install -m 0755 "$TOOLS_SRC/bin/browser" "$BIN_DIR/browser"
ln -sfn "$BIN_DIR/browser" "$BIN_DIR/start"
ln -sfn "$BIN_DIR/browser" "$BIN_DIR/open"
echo "installed $BIN_DIR/browser (start, open symlinks)"

template="$TOOLS_SRC/share/applications/browser.desktop.in"
desktop="$APP_DIR/browser.desktop"
expected_exec="Exec=$BIN_DIR/browser %u"
if [ ! -f "$desktop" ] || ! grep -Fxq "$expected_exec" "$desktop"; then
    sed "s|@@BIN_DIR@@|$BIN_DIR|g" "$template" > "$desktop"
    echo "wrote $desktop"
    desktop_changed=1
else
    desktop_changed=0
fi

if [ "$desktop_changed" = 1 ] && command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

current_browser=$(XDG_CURRENT_DESKTOP=X-Generic BROWSER="" xdg-settings get default-web-browser 2>/dev/null || true)
if [ "$current_browser" != "browser.desktop" ]; then
    XDG_CURRENT_DESKTOP=X-Generic BROWSER="" xdg-settings set default-web-browser browser.desktop || {
        echo "xdg-settings: failed to set default browser" >&2
        exit 255
    }
fi
