#!/bin/bash

RELOAD_AGENT=
if ! grep -q enable-ssh-support "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo enable-ssh-support >> "$HOME/.gnupg/gpg-agent.conf"
    RELOAD_AGENT=true
fi

if ! grep -q default-cache-ttl "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo "default-cache-ttl 3600" >> "$HOME/.gnupg/gpg-agent.conf"
    RELOAD_AGENT=true
fi

if [ -n "$LC_MESSAGES" ]; then
    if ! grep -q lc-messages "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
        echo "lc-messages $LC_MESSAGES" >> "$HOME/.gnupg/gpg-agent.conf"
        RELOAD_AGENT=true
    fi
fi

if [ -n "$LC_CTYPE" ]; then
    if ! grep -q lc-ctype "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
        echo "lc-ctype $LC_CTYPE" >> "$HOME/.gnupg/gpg-agent.conf"
        RELOAD_AGENT=true
    fi
fi

if [ ! -z "$RELOAD_AGENT" ]; then
    gpg-connect-agent <<< RELOADAGENT &>/dev/null
fi

systemctl --user mask --now ssh-agent.service
systemctl --user enable --now gpg-agent.socket
