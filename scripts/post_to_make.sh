#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="https://hook.eu1.make.com/ju8skmhvso645uktrc8a1ixahpklrg4s"
CHANNEL_ID="69a41dcf3f3b94a12104b7b4"
VIDEO_URL="https://ryo909.github.io/ai-dev-day-008/media/demo.mp4"
THUMB_URL="https://ryo909.github.io/ai-dev-day-008/media/cover.png"
DUE_AT="$(TZ=Asia/Tokyo date -d '+10 minutes' '+%Y-%m-%dT%H:%M:%S+09:00')"

RESPONSE_FILE="$(mktemp)"
cleanup() { rm -f "$RESPONSE_FILE"; }
trap cleanup EXIT

HTTP_STATUS="$(curl -sS -o "$RESPONSE_FILE" -w '%{http_code}' -X POST "$WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d @- <<EOF_JSON
{
  "channelId": "$CHANNEL_ID",
  "title": "Day008 | Draft Tightener（成果物デモ）",
  "text": "Day008 | Draft Tightener\\nhttps://ryo909.github.io/ai-dev-day-008/\\n#個人開発 #100日開発",
  "videoUrl": "$VIDEO_URL",
  "thumbnailUrl": "$THUMB_URL",
  "dueAt": "$DUE_AT",
  "privacy": "public",
  "madeForKids": false,
  "notifySubscribers": false
}
EOF_JSON
)"

echo "Response body:"
cat "$RESPONSE_FILE"
echo
echo "HTTP_STATUS:$HTTP_STATUS"
