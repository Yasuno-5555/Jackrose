#!/bin/bash
SUMMARY="$1"
if [ -z "$SUMMARY" ]; then
    exit 1
fi
# Find .ics files containing VEVENT and having the exact SUMMARY
for file in "$HOME"/.local/share/calendars/personal/*.ics; do
    if [ ! -f "$file" ]; then continue; fi
    if grep -q "BEGIN:VEVENT" "$file" && grep -q -E "^SUMMARY([^:]*):$SUMMARY[[:space:]]*$" "$file"; then
        rm "$file"
        echo "Deleted event: $SUMMARY (file: $(basename "$file"))"
        exit 0
    fi
done
echo "Event not found: $SUMMARY"
exit 1
