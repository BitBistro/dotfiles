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

if [ ! -z "$RELOAD_AGENT" ]; then
    gpg-connect-agent <<< RELOADAGENT &>/dev/null
fi

systemctl --user mask --now ssh-agent.service
systemctl --user enable --now gpg-agent.socket
