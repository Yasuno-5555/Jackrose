#!/bin/bash
# Liquid Mocha — System Stats Stream
# Outputs JSON lines every 5 seconds for Quickshell consumption

get_wifi_status() {
    local wifi_iface wifi_ssid nmcli_status

    wifi_iface="$(find /sys/class/net -maxdepth 1 -type l -name 'wl*' -printf '%f\n' 2>/dev/null | head -n 1)"
    [ -z "$wifi_iface" ] && wifi_iface="$(find /sys/class/net -maxdepth 2 -type d -name wireless 2>/dev/null | sed -n '1s#/wireless$##p' | xargs -r basename | head -n 1)"

    wifi_ssid=""
    if command -v nmcli >/dev/null 2>&1; then
        wifi_ssid="$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status 2>/dev/null | awk -F: '$2=="wifi" && $3=="connected" {print $4; exit}')"
        if [ -n "$wifi_ssid" ]; then
            printf 'wifi:%s' "$wifi_ssid"
            return
        fi
    fi

    if [ -n "$wifi_iface" ] && [ -f "/sys/class/net/$wifi_iface/operstate" ]; then
        if [ "$(cat "/sys/class/net/$wifi_iface/operstate" 2>/dev/null)" = "up" ]; then
            printf 'wifi'
            return
        fi
    fi

    nmcli_status="$(nmcli -t -f WIFI g 2>/dev/null | head -n 1)"
    if [ "$nmcli_status" = "enabled" ]; then
        printf 'wifi'
        return
    fi

    local wired_iface=""
    wired_iface="$(find /sys/class/net -maxdepth 1 -type l ! -name 'lo' ! -name 'wl*' ! -name 'tailscale*' -printf '%f\n' 2>/dev/null | while read -r iface; do
        [ -f "/sys/class/net/$iface/type" ] || continue
        [ "$(cat "/sys/class/net/$iface/type" 2>/dev/null)" = "1" ] || continue
        [ -d "/sys/class/net/$iface/wireless" ] && continue
        [ "$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)" = "up" ] || continue
        printf '%s\n' "$iface"
        break
    done)"
    if [ -n "$wired_iface" ]; then
        printf 'wired'
        return
    fi

    printf 'offline'
}

get_bluetooth_status() {
    local bt_rfkill

    bt_rfkill="$(find /sys/class/rfkill -maxdepth 1 -type l 2>/dev/null | while read -r rf; do
        [ -f "$rf/type" ] || continue
        [ "$(cat "$rf/type" 2>/dev/null)" = "bluetooth" ] || continue
        printf '%s\n' "$rf"
        break
    done)"

    if [ -n "$bt_rfkill" ]; then
        if [ "$(cat "$bt_rfkill/soft" 2>/dev/null)" = "1" ] || [ "$(cat "$bt_rfkill/hard" 2>/dev/null)" = "1" ]; then
            printf 'off'
            return
        fi
        printf 'on'
        return
    fi

    if [ -d /sys/class/bluetooth ] || [ -d /sys/devices/platform/soc/690000000.pcie/pci0000:00/0000:00:00.0/0000:01:00.1/bluetooth ]; then
        printf 'on'
        return
    fi

    printf 'off'
}

while true; do
    # CPU
    cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print int(100 - $1)}')

    # Memory
    mem=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')

    # Battery
    bat_dir=$(find /sys/class/power_supply -maxdepth 1 \( -name "BAT*" -o -name "*battery*" \) 2>/dev/null | head -n 1)
    if [ -n "$bat_dir" ] && [ -d "$bat_dir" ]; then
        bat_cap=$(cat "$bat_dir/capacity")
        bat_status=$(cat "$bat_dir/status")
    else
        bat_cap=100
        bat_status="Full"
    fi

    # Volume
    vol_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    vol_muted=false
    if [[ "$vol_info" =~ \[MUTED\] ]]; then
        vol="muted"
        vol_muted=true
    else
        vol=$(echo "$vol_info" | awk '{print int($2 * 100)}')
    fi
    if [ -z "$vol" ]; then
        vol="0"
    fi

    # Brightness
    if which brightnessctl &>/dev/null; then
        bright=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')
        [ -z "$bright" ] && bright=100
    else
        bright=100
    fi

    # Network / Bluetooth
    net_status="$(get_wifi_status)"
    bt="$(get_bluetooth_status)"

    # Current niri profile
    profile="normal"
    if [ -f "$HOME/.cache/niri-current-profile" ]; then
        profile=$(cat "$HOME/.cache/niri-current-profile")
    fi

    echo "{\"cpu\":$cpu,\"mem\":$mem,\"bat_cap\":$bat_cap,\"bat_status\":\"$bat_status\",\"vol\":\"$vol\",\"vol_muted\":$vol_muted,\"bright\":$bright,\"net\":\"$net_status\",\"bt\":\"$bt\",\"profile\":\"$profile\"}"
    sleep 1
done
