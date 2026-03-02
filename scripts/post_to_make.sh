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
DRY_RUN="${DRY_RUN:-0}"
YT_DISABLED="${YT_DISABLED:-0}"

err() { echo "ERROR: $*" >&2; }

for v in WEBHOOK VIDEO_URL THUMB_URL TRACE_ID TITLE TEXT PRIVACY; do
  [ -n "${!v:-}" ] || { err "required variable is empty: $v"; exit 1; }
done

# JST fixed epoch
now_epoch_jst() { TZ=Asia/Tokyo date +%s; }

x_time_by_dow() {
  # 1=Mon ... 7=Sun
  case "$1" in
    1) echo "21:00" ;; # Mon
    2) echo "08:30" ;; # Tue
    3) echo "12:10" ;; # Wed
    4) echo "09:00" ;; # Thu
    5) echo "08:30" ;; # Fri
    6) echo "10:00" ;; # Sat
    7) echo "21:00" ;; # Sun
    *) echo "21:00" ;;
  esac
}

yt_time_by_dow() {
  case "$1" in
    1|2|3|4|5) echo "20:00" ;; # Weekdays
    6|7)       echo "11:00" ;; # Weekend
    *)         echo "20:00" ;;
  esac
}

next_slot_iso() {
  # $1 = kind: "x" or "yt"
  local kind="$1"
  local now_epoch min_epoch
  now_epoch=$(now_epoch_jst) || { err "failed to get JST now epoch"; return 1; }
  min_epoch=$((now_epoch + 120)) # safety margin: 2min

  for i in 0 1 2 3 4 5 6; do
    local day_str dow hhmm cand_epoch
    day_str=$(TZ=Asia/Tokyo date -d "+${i} days" "+%Y-%m-%d") || continue
    dow=$(TZ=Asia/Tokyo date -d "+${i} days" +%u) || continue

    if [ "$kind" = "x" ]; then
      hhmm=$(x_time_by_dow "$dow")
    elif [ "$kind" = "yt" ]; then
      hhmm=$(yt_time_by_dow "$dow")
    else
      err "unknown slot kind: $kind"
      return 1
    fi

    cand_epoch=$(TZ=Asia/Tokyo date -d "${day_str} ${hhmm}:00" +%s) || continue
    if [ "$cand_epoch" -ge "$min_epoch" ]; then
      TZ=Asia/Tokyo date -d "@$cand_epoch" "+%Y-%m-%dT%H:%M:%S+09:00"
      return 0
    fi
  done

  # fallback
  TZ=Asia/Tokyo date -d "+15 minutes" "+%Y-%m-%dT%H:%M:%S+09:00"
  return 0
}

DUE_AT_X="$(next_slot_iso "x")" || { err "failed to compute DUE_AT_X"; exit 1; }
DUE_AT_YT="$(next_slot_iso "yt")" || { err "failed to compute DUE_AT_YT"; exit 1; }
[ -n "$DUE_AT_X" ] || { err "DUE_AT_X is empty"; exit 1; }
[ -n "$DUE_AT_YT" ] || { err "DUE_AT_YT is empty"; exit 1; }
echo "[auto_pipeline] DUE_AT_X=$DUE_AT_X"
echo "[auto_pipeline] DUE_AT_YT=$DUE_AT_YT"

PAYLOAD_FILE="$(mktemp)"
RESPONSE_FILE="$(mktemp)"
cleanup() { rm -f "$PAYLOAD_FILE" "$RESPONSE_FILE"; }
trap cleanup EXIT

if [ "$YT_DISABLED" = "1" ]; then
cat > "$PAYLOAD_FILE" <<EOF_JSON
{
  "batch_id": "$TRACE_ID",
  "posts": [
    {
      "platform": "x",
      "text": "$TEXT",
      "dueAt": "$DUE_AT_X"
    }
  ]
}
EOF_JSON
else
cat > "$PAYLOAD_FILE" <<EOF_JSON
{
  "batch_id": "$TRACE_ID",
  "posts": [
    {
      "platform": "x",
      "text": "$TEXT",
      "dueAt": "$DUE_AT_X"
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
      "dueAt": "$DUE_AT_YT"
    }
  ]
}
EOF_JSON
fi

echo "Payload body:"
cat "$PAYLOAD_FILE"
echo

if [ "$DRY_RUN" = "1" ]; then
  echo "[auto_pipeline] DRY_RUN=1, skip webhook POST"
  echo "TRACE_ID:$TRACE_ID"
  exit 0
fi

HTTP_STATUS="$(curl -sS -o "$RESPONSE_FILE" -w '%{http_code}' -X POST "$WEBHOOK" \
  -H 'Content-Type: application/json' \
  -d @"$PAYLOAD_FILE")"

echo "Response body:"
cat "$RESPONSE_FILE"
echo
echo "TRACE_ID:$TRACE_ID"
echo "HTTP_STATUS:$HTTP_STATUS"
