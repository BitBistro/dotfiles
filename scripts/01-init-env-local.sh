#!/bin/bash
# Populate ~/.env-local with variables the dotfiles setup scripts read at
# install time. Prompts only for variables not already present, appending
# each one as it's collected. Safe to re-run; safe to ctrl-C mid-prompt
# (previously-collected values are already on disk).
set -eu

ENV_FILE="$HOME/.env-local"
[ -e "$ENV_FILE" ] || touch "$ENV_FILE"

echo "Checking $ENV_FILE for required setup variables..."

# Each entry: VARNAME|prompt text. Add new vars here as the setup scripts grow.
PROMPTS=(
    "GIT_USER_NAME|Full name for git commits"
    "GIT_USER_EMAIL|Email address for git commits"
    "GIT_SIGNINGKEY|GPG signing key fingerprint (40 hex chars; blank to skip)"
)

is_set() {
    grep -q "^export $1=" "$ENV_FILE" 2>/dev/null
}

prompt_and_append() {
    local var="$1" prompt="$2" value escaped
    printf '%s: ' "$prompt"
    IFS= read -r value || return 0
    if [ -z "$value" ]; then
        echo "  (skipped $var; re-run to add later)"
        return 0
    fi
    escaped=$(printf '%s' "$value" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf 'export %s="%s"\n' "$var" "$escaped" >> "$ENV_FILE"
    echo "  -> wrote $var to $ENV_FILE"
}

added=0
for entry in "${PROMPTS[@]}"; do
    var="${entry%%|*}"
    prompt="${entry#*|}"
    if is_set "$var"; then
        continue
    fi
    prompt_and_append "$var" "$prompt"
    added=$((added + 1))
done

if [ "$added" -eq 0 ]; then
    echo "All known variables already set in $ENV_FILE; nothing to do."
fi
