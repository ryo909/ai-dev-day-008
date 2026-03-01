#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

INPUT="$ROOT_DIR/narration.txt"
TMP_WAV="$ROOT_DIR/temp.wav"
OUTPUT="$ROOT_DIR/public/media/narration.wav"

[ -f "$INPUT" ] || { echo "ERROR: narration.txt not found: $INPUT"; exit 1; }
mkdir -p "$ROOT_DIR/public/media"

if command -v espeak >/dev/null 2>&1 && command -v ffmpeg >/dev/null 2>&1; then
  espeak -f "$INPUT" -w "$TMP_WAV"
  ffmpeg -y -i "$TMP_WAV" -ar 44100 -ac 2 "$OUTPUT" >/dev/null 2>&1
  rm -f "$TMP_WAV"
elif [ -f "$OUTPUT" ]; then
  echo "WARN: espeak/ffmpeg not found; reusing existing narration.wav"
else
  echo "ERROR: espeak/ffmpeg not found and no existing narration.wav to reuse"
  exit 1
fi

echo "Audio generated: public/media/narration.wav"
