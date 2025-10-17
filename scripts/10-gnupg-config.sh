RELOAD_AGENT=

# Ensure .gnupg directory exists
mkdir -p "$HOME/.gnupg"

# Function to set or update a config value
update_config_value() {
    local key="$1"
    local value="$2"
    local file="$3"

    if grep -q "^$key " "$file" 2>/dev/null; then
        # Key exists, check if value is different
        if ! grep -q "^$key $value$" "$file" 2>/dev/null; then
            # Update existing value
            sed -i "s/^$key .*/$key $value/" "$file"
            RELOAD_AGENT=true
        fi
    else
        # Key doesn't exist, add it
        echo "$key $value" >> "$file"
        RELOAD_AGENT=true
    fi
}

# Function for boolean config values (no value after the key)
update_config_boolean() {
    local key="$1"
    local file="$2"

    if ! grep -q "^$key$" "$file" 2>/dev/null; then
        echo "$key" >> "$file"
        RELOAD_AGENT=true
    fi
}

# Enable agent usage in GPG
update_config_boolean "use-agent" "$HOME/.gnupg/gpg.conf"

# Enable SSH support in GPG agent
update_config_boolean "enable-ssh-support" "$HOME/.gnupg/gpg-agent.conf"

# Always ensure TTL values are set correctly (will update if different)
update_config_value "default-cache-ttl" "21600" "$HOME/.gnupg/gpg-agent.conf"
update_config_value "max-cache-ttl" "21600" "$HOME/.gnupg/gpg-agent.conf"
update_config_value "default-cache-ttl-ssh" "21600" "$HOME/.gnupg/gpg-agent.conf"
update_config_value "max-cache-ttl-ssh" "21600" "$HOME/.gnupg/gpg-agent.conf"

update_config_value "pinentry-timeout" "60" "$HOME/.gnupg/gpg-agent.conf"

if [ -n "$LC_MESSAGES" ]; then
    update_config_value "lc-messages" "$LC_MESSAGES" "$HOME/.gnupg/gpg-agent.conf"
fi

if [ -n "$LC_CTYPE" ]; then
    update_config_value "lc-ctype" "$LC_CTYPE" "$HOME/.gnupg/gpg-agent.conf"
fi

# Set pinentry-program only if the custom script exists
if [ -f "/home/mperry/.gnupg/pinentry-ide.sh" ]; then
    update_config_value "pinentry-program" "/home/mperry/.gnupg/pinentry-ide.sh" "$HOME/.gnupg/gpg-agent.conf"
fi

# Use gpgconf for reloading (more reliable than gpg-connect-agent)
if [ ! -z "$RELOAD_AGENT" ]; then
    gpgconf --reload gpg-agent 2>/dev/null || true
fi

if [ -n "$(command -v systemctl)" ]; then
    systemctl --user mask --now ssh-agent.service 2>/dev/null || true
    systemctl --user enable --now gpg-agent.socket 2>/dev/null || true
    systemctl --user enable --now gpg-agent-ssh.socket 2>/dev/null || true
fi
