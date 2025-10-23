#!/bin/bash
set -euo pipefail
BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" = "linux" ]; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

    EXPECTED="798AEC654E5C15428C8E42EEAA16FCBCA621E701"
    gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --with-colons --fingerprint \
        | awk -F: '$1=="fpr"{print toupper($10)}' \
        | grep -Fxq "$EXPECTED" || exit 1

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

    sudo apt update
    sudo apt-get install terraform -y
fi
