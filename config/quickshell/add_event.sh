#!/bin/bash
DATE="$1"
if [ -z "$DATE" ]; then
    DATE=$(date +%Y-%m-%d)
fi

if ! command -v khal >/dev/null 2>&1; then
    notify-send "Jackrose" "khal is not installed. Calendar entry was skipped."
    exit 0
fi

TEMP_FILE=$(mktemp)

# Launch ghostty with a transient input prompt to support full Japanese IME and clear line breaks
ghostty --title="New Event" -e bash -c "
    echo '=== 新しい予定を追加 ==='
    echo '対象日: $DATE'
    echo ''
    echo '入力例 (改行されて表示されます):'
    echo '  12:00 会議 (時間指定)'
    echo '  10:00-11:00 ミーティング'
    echo '  today 終日イベント'
    echo ''
    read -p '予定を入力してください: ' EVENT
    echo -n \"\$EVENT\" > '$TEMP_FILE'
"

RAW_EVENT=$(cat "$TEMP_FILE")
rm -f "$TEMP_FILE"

# Trim spaces
EVENT=$(echo "$RAW_EVENT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if [ -n "$EVENT" ]; then
    if [[ "$EVENT" =~ ^[0-9]{2}:[0-9]{2} ]]; then
        khal new -a personal "$DATE" $EVENT
    elif [[ "$EVENT" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        khal new -a personal $EVENT
    else
        khal new -a personal "$DATE" $EVENT
    fi
fi
