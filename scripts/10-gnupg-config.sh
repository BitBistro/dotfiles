#!/bin/bash
RELOAD_AGENT=

if ! grep -q use-agent "$HOME/.gnupg/gpg.conf" 2>/dev/null; then
    echo use-agent >> "$HOME/.gnupg/gpg.conf"
    RELOAD_AGENT=true
fi

if ! grep -q enable-ssh-support "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo enable-ssh-support >> "$HOME/.gnupg/gpg-agent.conf"
    RELOAD_AGENT=true
fi

for i in default-cache-ttl max-cache-ttl default-cache-ttl-ssh max-cache-ttl-ssh; do
    if ! grep -q "^$i" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
        echo "$i 21600" >> "$HOME/.gnupg/gpg-agent.conf"
        RELOAD_AGENT=true
    fi
done

if ! grep -q pinentry-timeout "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo "pinentry-timeout 60" >> "$HOME/.gnupg/gpg-agent.conf"
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
