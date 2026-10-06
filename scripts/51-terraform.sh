#!/bin/bash
set -eu
# BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" = "linux" ]; then
    KEYRING=/usr/share/keyrings/hashicorp-archive-keyring.gpg
    SOURCE=/etc/apt/sources.list.d/hashicorp.list
    # Primary signing key fingerprint. HashiCorp rotates this periodically; when
    # apt reports "Missing key ... needed to verify signature", verify the new
    # fingerprint against HashiCorp's published value and update it here.
    EXPECTED="D55C0D1AC78A8D8126CB631CFC9CA96ACA026560"

    # Print the primary key fingerprint of a keyring file (empty if unreadable).
    primary_fpr() {
        gpg --no-default-keyring --keyring "$1" --with-colons --fingerprint 2>/dev/null |
            awk -F: '$1=="fpr"{print toupper($10); exit}'
    }

    CHANGED=false

    if [ ! -f "$KEYRING" ] || [ "$(primary_fpr "$KEYRING")" != "$EXPECTED" ]; then
        TMPKEY="$(mktemp)"
        trap 'rm -f "$TMPKEY"' EXIT
        if ! curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor >"$TMPKEY"; then
            if command -v terraform >/dev/null 2>&1; then
                echo "WARN: could not refresh HashiCorp signing key; keeping existing keyring" >&2
                exit 0
            fi
            exit 1
        fi
        if [ "$(primary_fpr "$TMPKEY")" != "$EXPECTED" ]; then
            echo "ERROR: HashiCorp signing key fingerprint mismatch (expected $EXPECTED)" >&2
            exit 1
        fi
        sudo install -m 0644 "$TMPKEY" "$KEYRING"
        CHANGED=true
    fi

    LINE="deb [arch=$(dpkg --print-architecture) signed-by=$KEYRING] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main"
    if [ ! -f "$SOURCE" ] || [ "$(cat "$SOURCE")" != "$LINE" ]; then
        echo "$LINE" | sudo tee "$SOURCE" >/dev/null
        CHANGED=true
    fi

    if [ "$CHANGED" = true ]; then
        sudo apt update
    fi

    if ! command -v terraform >/dev/null 2>&1; then
        sudo apt-get install terraform -y
    fi
fi
