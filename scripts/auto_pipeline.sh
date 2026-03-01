#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

echo "=== START AUTO VIDEO PIPELINE ==="
"$SCRIPT_DIR/generate_audio.sh"
"$SCRIPT_DIR/generate_video.sh"
"$SCRIPT_DIR/post_to_make.sh"
echo "=== DONE ==="
