#!/usr/bin/env bash
set -euo pipefail

WEBHOOK="https://hook.eu1.make.com/2kqto795b92mdbhhanpvc5oj3qqa9ku8"
VIDEO_URL="https://ryo909.github.io/ai-dev-day-008/media/demo.mp4"
THUMB_URL="https://ryo909.github.io/ai-dev-day-008/media/cover.png"
TRACE_ID="day008-$(TZ=Asia/Tokyo date '+%Y%m%d-%H%M%S')"
TITLE="Day008 | Draft Tightener（成果物デモ）"
TEXT='Day008 | Draft Tightener\nhttps://ryo909.github.io/ai-dev-day-008/\n#個人開発 #100日開発'
PRIVACY="public"
MADE_FOR_KIDS=false
NOTIFY_SUBSCRIBERS=false

now_epoch=$(TZ=Asia/Tokyo date +%s)
dow=$(TZ=Asia/Tokyo date +%u) # 1=Mon ... 7=Sun

if [ "$dow" -le 5 ]; then
  target_h=21
  target_m=00
else
  target_h=11
  target_m=00
fi

today_target_epoch=$(TZ=Asia/Tokyo date -d "today ${target_h}:${target_m}:00" +%s)

if [ "$today_target_epoch" -le "$now_epoch" ]; then
  next_dow=$(TZ=Asia/Tokyo date -d "tomorrow" +%u)
  if [ "$next_dow" -le 5 ]; then
    target_h=21
    target_m=00
  else
    target_h=11
    target_m=00
  fi
  target_epoch=$(TZ=Asia/Tokyo date -d "tomorrow ${target_h}:${target_m}:00" +%s)
else
  target_epoch=$today_target_epoch
fi

DUE_AT=$(TZ=Asia/Tokyo date -d "@$target_epoch" "+%Y-%m-%dT%H:%M:%S+09:00")
echo "[auto_pipeline] DUE_AT=$DUE_AT"

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
