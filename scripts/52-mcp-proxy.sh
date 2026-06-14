#!/bin/bash
set -euo pipefail
# BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" != "linux" ] && [ "$OSENV" != "darwin" ]; then
    exit 0
fi

if ! command -v uv >/dev/null 2>&1; then
    echo "missing dependency: uv" >&2
    exit 255
fi

TARGET_DIR="$HOME/.config/mcp-proxy-env"
TARGET_TOML="$TARGET_DIR/pyproject.toml"
TARGET_PKG="mcp-proxy"
REQ_FILE="$TARGET_DIR/requirements.txt"

# EARLY EXIT: If the hardened binary already exists, skip the entire pipeline
if [ -x "$TARGET_DIR/.venv/bin/$TARGET_PKG" ]; then
    echo "$TARGET_PKG is already installed. Skipping provisioning."
    exit 0
fi

mkdir -p "$TARGET_DIR"

if [ ! -f "$TARGET_TOML" ]; then
    uv init --no-package "$TARGET_DIR"
fi

# PRE-EMPTIVE HARDENING: Inject the known security override before resolution
if ! grep -Fq '"h11==0.16.0"' "$TARGET_TOML"; then
    cat << 'EOF' >> "$TARGET_TOML"

[tool.uv]
override-dependencies = [
  "h11==0.16.0"
]
EOF
fi

# RESOLVE & SYNC: uv add will now factor in the override immediately
uv add --project "$TARGET_TOML" "$TARGET_PKG" safety

# EXPORT: Generate the static requirements artifact
uv export --project "$TARGET_TOML" --format requirements-txt --output-file "$REQ_FILE"

# SCAN & TRAP: Run safety in a headless subshell. 
# If vulnerabilities are found, safety exits non-zero, triggering the 'exit 255'.
(cd "$TARGET_DIR" && CI=1 .venv/bin/python -m safety scan --non-interactive -r requirements.txt --full-report) || {
    echo "CRITICAL: Safety scan failed. Vulnerabilities detected in $TARGET_PKG environment." >&2
    exit 255
}
