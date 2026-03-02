#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="https://hook.eu1.make.com/2kqto795b92mdbhhanpvc5oj3qqa9ku8"
VIDEO_URL="https://ryo909.github.io/ai-dev-day-008/media/demo.mp4"
THUMB_URL="https://ryo909.github.io/ai-dev-day-008/media/cover.png"
DUE_AT="$(TZ=Asia/Tokyo date -d '+10 minutes' '+%Y-%m-%dT%H:%M:%S+09:00')"
TRACE_ID="day008-$(TZ=Asia/Tokyo date '+%Y%m%d-%H%M%S')"
TITLE="Day008 | Draft Tightener（成果物デモ）"
TEXT='Day008 | Draft Tightener\nhttps://ryo909.github.io/ai-dev-day-008/\n#個人開発 #100日開発'
PRIVACY="public"
MADE_FOR_KIDS=false
NOTIFY_SUBSCRIBERS=false

PAYLOAD_FILE="$(mktemp)"
RESPONSE_FILE="$(mktemp)"
cleanup() { rm -f "$PAYLOAD_FILE" "$RESPONSE_FILE"; }
trap cleanup EXIT

cat > "$PAYLOAD_FILE" <<EOF_JSON
{
  "batch_id": "$TRACE_ID",
  "posts": [
    {
      "platform": "x",
      "text": "$TEXT",
      "dueAt": "$DUE_AT"
    },
    {
      "platform": "youtube",
      "title": "$TITLE",
      "description": "$TEXT",
      "videoUrl": "$VIDEO_URL",
      "thumbnailUrl": "$THUMB_URL",
      "privacy": "$PRIVACY",
      "madeForKids": $MADE_FOR_KIDS,
      "notifySubscribers": $NOTIFY_SUBSCRIBERS,
      "dueAt": "$DUE_AT"
    }
  ]
}
EOF_JSON

echo "Payload body:"
cat "$PAYLOAD_FILE"
echo

HTTP_STATUS="$(curl -sS -o "$RESPONSE_FILE" -w '%{http_code}' -X POST "$WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d @"$PAYLOAD_FILE")"

echo "Response body:"
cat "$RESPONSE_FILE"
echo
echo "TRACE_ID:$TRACE_ID"
echo "HTTP_STATUS:$HTTP_STATUS"
