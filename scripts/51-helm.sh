#!/bin/sh
set -eu
OSENV="${2:-linux}"

if [ "$OSENV" != "linux" ]; then
    exit 0
fi

if command -v helm >/dev/null 2>&1; then
    exit 0
fi

curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
