#!/bin/bash
set -euo pipefail
BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" != "linux" ] && [ "$OSENV" != "darwin" ]; then
    exit 0
fi

if ! command -v uv >/dev/null 2>&1; then
    echo "missing dependency: uv" >&2
    exit 255
fi

TARGET_DIR="$HOME/.config/frogmouth-env"
TARGET_TOML="$TARGET_DIR/pyproject.toml"
TARGET_PKG="frogmouth"
REQ_FILE="$TARGET_DIR/requirements.txt"

mkdir -p "$TARGET_DIR"

if [ ! -f "$TARGET_TOML" ]; then
    uv init --no-package "$TARGET_DIR"
fi

uv add --project "$TARGET_DIR" "$TARGET_PKG" safety
uv export --project "$TARGET_DIR" --format requirements-txt --output-file "$REQ_FILE"
"$TARGET_DIR/.venv/bin/python" -m safety scan -r "$REQ_FILE" --full-report || true

if ! grep -Fq '"h11==0.16.0"' "$TARGET_TOML"; then
    if grep -Fxq '[tool.uv]' "$TARGET_TOML"; then
        echo "frogmouth: [tool.uv] already exists without h11 override" >&2
        exit 255
    fi

    cat << 'EOF' >> "$TARGET_TOML"
[tool.uv]
override-dependencies = [
  "h11==0.16.0"
]
EOF
fi

uv lock --project "$TARGET_DIR"
uv sync --project "$TARGET_DIR"
uv export --project "$TARGET_DIR" --format requirements-txt --output-file "$REQ_FILE"
"$TARGET_DIR/.venv/bin/python" -m safety scan -r "$REQ_FILE" --full-report
