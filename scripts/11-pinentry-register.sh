#!/bin/bash
set -e
# BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" != "linux" ] && [ "$OSENV" != "darwin" ]; then
    exit 0
fi

PINENTRY="$HOME/.local/bin/pinentry"
CONF="$HOME/.gnupg/gpg-agent.conf"

if [ ! -x "$PINENTRY" ]; then
    echo "pinentry wrapper not installed at $PINENTRY" >&2
    echo "ensure scripts/09-install-tools.sh ran successfully" >&2
    exit 255
fi

mkdir -p "$HOME/.gnupg"
touch "$CONF"

CHANGED=""
if grep -q '^pinentry-program ' "$CONF" 2>/dev/null; then
    if ! grep -qx "pinentry-program $PINENTRY" "$CONF"; then
        backup="$CONF.$(date +%Y%m%d%H%M%S).bak"
        cp "$CONF" "$backup"
        tmp="$(mktemp)"
        awk -v p="$PINENTRY" '
            /^pinentry-program[[:space:]]/ { if (!w) { print "pinentry-program " p; w=1 }; next }
            { print }
            END { if (!w) print "pinentry-program " p }
        ' "$CONF" > "$tmp"
        cat "$tmp" > "$CONF"
        rm -f "$tmp"
        echo "updated pinentry-program in $CONF (backup: $backup)"
        CHANGED="true"
    fi
else
    echo "pinentry-program $PINENTRY" >> "$CONF"
    echo "added pinentry-program to $CONF"
    CHANGED="true"
fi

if [ -n "$CHANGED" ]; then
    gpgconf --kill gpg-agent 2>/dev/null || true
fi
