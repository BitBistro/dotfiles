#!/bin/bash
# Configure systemd user units and D-Bus activation for pass-secret-service.
set -euo pipefail
BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" != "linux" ]; then
    exit 0
fi

# Fall back to ~/.env-local if the GIT_* vars aren't already exported
if [ -z "${GIT_SIGNINGKEY:-}" ] && [ -r "$HOME/.env-local" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.env-local"
fi

# Only run if the GPG signing key is available
if [ -z "${GIT_SIGNINGKEY:-}" ]; then
    echo "GIT_SIGNINGKEY is not defined. Skipping pass-secret-service setup."
    exit 0
fi

# Only run if pass-secret-service binary is installed
INSTALL_PATH="$HOME/.local/bin/pass-secret-service"
if [ ! -x "$INSTALL_PATH" ]; then
    echo "pass-secret-service binary not found. Skipping service setup."
    exit 0
fi

# 1. Initialize pass with the GPG key if not already initialized with it
if command -v pass >/dev/null 2>&1; then
    GPG_ID_FILE="$HOME/.password-store/.gpg-id"
    if [ -f "$GPG_ID_FILE" ] && grep -Fxqi "$GIT_SIGNINGKEY" "$GPG_ID_FILE"; then
        echo "pass is already initialized with key: $GIT_SIGNINGKEY"
    else
        echo "Initializing pass with key: $GIT_SIGNINGKEY"
        pass init "$GIT_SIGNINGKEY"
    fi
else
    echo "Warning: 'pass' is not installed. Skipping pass init."
fi

# 2. Check and copy systemd user service file
SERVICE_DEST="$HOME/.config/systemd/user/pass-secret-service.service"
SERVICE_SRC="$BASEDIR/tools/systemd/pass-secret-service.service"
service_changed=0

if [ ! -f "$SERVICE_DEST" ] || ! cmp -s "$SERVICE_SRC" "$SERVICE_DEST"; then
    mkdir -p "$(dirname "$SERVICE_DEST")"
    cp "$SERVICE_SRC" "$SERVICE_DEST"
    echo "Installed systemd user unit: $SERVICE_DEST"
    service_changed=1
fi

# 3. Check and install D-Bus service activation file
DBUS_DEST="$HOME/.local/share/dbus-1/services/org.freedesktop.secrets.service"
DBUS_SRC="$BASEDIR/tools/systemd/org.freedesktop.secrets.service.in"
dbus_changed=0

expected_dbus="$(sed "s|@@BIN_DIR@@|$HOME/.local/bin|g" "$DBUS_SRC")"
if [ ! -f "$DBUS_DEST" ] || [ "$(cat "$DBUS_DEST" 2>/dev/null)" != "$expected_dbus" ]; then
    mkdir -p "$(dirname "$DBUS_DEST")"
    printf '%s\n' "$expected_dbus" > "$DBUS_DEST"
    echo "Installed D-Bus activation file: $DBUS_DEST"
    dbus_changed=1
fi

# 4. Reload and enable systemd user units if any changes occurred
if [ "$service_changed" -eq 1 ] || [ "$dbus_changed" -eq 1 ]; then
    if systemctl --user daemon-reload >/dev/null 2>&1; then
        echo "Reloading systemd user daemon and enabling pass-secret-service..."
        systemctl --user daemon-reload
        systemctl --user enable --now pass-secret-service
    else
        echo "Systemd user session is not accessible. Skipping systemctl activation."
    fi
fi
