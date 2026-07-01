#!/bin/bash
# Liquid Mocha — Media Info Streamer
# Outputs JSON lines on media status change for Quickshell

while true; do
    if playerctl status &>/dev/null; then
        # Run playerctl follow mode, outputting JSON on change
        playerctl metadata --format '{"title": "{{markup_escape(title)}}", "artist": "{{markup_escape(artist)}}", "album": "{{markup_escape(album)}}", "status": "{{status}}"}' -F 2>/dev/null
    else
        # No player running, output idle state
        echo '{"title": "No Media", "artist": "Idle", "album": "", "status": "Stopped"}'
        sleep 3
    fi
done
