#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE="$ROOT_DIR/public/media/cover.png"
AUDIO="$ROOT_DIR/public/media/narration.wav"
OUTPUT="$ROOT_DIR/public/media/demo.mp4"

[ -f "$IMAGE" ] || { echo "ERROR: cover image not found: $IMAGE"; exit 1; }
[ -f "$AUDIO" ] || { echo "ERROR: narration audio not found: $AUDIO"; exit 1; }
if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -y \
    -loop 1 -i "$IMAGE" \
    -i "$AUDIO" \
    -c:v libx264 \
    -tune stillimage \
    -c:a aac \
    -b:a 192k \
    -shortest \
    -pix_fmt yuv420p \
    -vf "scale=1080:1920,format=yuv420p" \
    "$OUTPUT" >/dev/null 2>&1
elif [ -f "$OUTPUT" ]; then
  echo "WARN: ffmpeg not found; reusing existing demo.mp4"
else
  echo "ERROR: ffmpeg not found and no existing demo.mp4 to reuse"
  exit 1
fi

echo "Video generated: public/media/demo.mp4"
