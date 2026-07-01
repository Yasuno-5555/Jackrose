#!/bin/bash
TEMP_FILE=$(mktemp)

# Launch ghostty with a transient input prompt to support full Japanese IME and clear line breaks
ghostty --title="New Task" -e bash -c "
    echo '=== 新しいタスクを追加 ==='
    echo ''
    echo '入力例:'
    echo '  買い物に行く'
    echo '  明日10時にミーティング'
    echo ''
    read -p 'タスク名を入力してください: ' TASK
    echo -n \"\$TASK\" > '$TEMP_FILE'
"

RAW_TASK=$(cat "$TEMP_FILE")
rm -f "$TEMP_FILE"

# Trim spaces
TASK=$(echo "$RAW_TASK" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if [ -n "$TASK" ]; then
    "$HOME/.local/bin/todo" new -l personal "$TASK"
fi
