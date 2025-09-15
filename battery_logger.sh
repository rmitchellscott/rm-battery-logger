#!/bin/bash

VERSION="dev"

# Handle version flag
if [[ "$1" == "-v" ]] || [[ "$1" == "--version" ]]; then
    echo "rm-battery-logger version $VERSION"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Auto-detect battery controller
if [[ -d "/sys/class/power_supply/max1726x_battery" ]]; then
    BATTERY_PATH="/sys/class/power_supply/max1726x_battery"
    echo "Detected: reMarkable Paper Pro"
elif [[ -d "/sys/class/power_supply/max77818_battery" ]]; then
    BATTERY_PATH="/sys/class/power_supply/max77818_battery"
    echo "Detected: reMarkable 2 or Paper Pro Move"
else
    echo "Error: No supported battery controller found"
    exit 1
fi

FRONTLIGHT_PATH="/sys/class/backlight/rm_frontlight/brightness"
LOG_INTERVAL=300
CHECK_INTERVAL=60
RUNNING=1

cleanup() {
    echo "Battery logger stopped."
    RUNNING=0
    exit 0
}

trap cleanup TERM INT

read_sysfs() {
    local file="$1"
    if [[ -r "$file" ]]; then
        cat "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

get_battery_data() {
    local capacity charge_now charge_full status current_avg voltage_now temp brightness
    local charge_now_mah charge_full_mah current_avg_ma voltage_v temp_c

    capacity=$(read_sysfs "$BATTERY_PATH/capacity")

    charge_now=$(read_sysfs "$BATTERY_PATH/charge_now")
    charge_now_mah=$((charge_now / 100))
    charge_now_mah="${charge_now_mah%??}.${charge_now_mah: -2}"

    charge_full=$(read_sysfs "$BATTERY_PATH/charge_full")
    charge_full_mah=$((charge_full / 100))
    charge_full_mah="${charge_full_mah%??}.${charge_full_mah: -2}"

    status=$(read_sysfs "$BATTERY_PATH/status")
    [[ -z "$status" || "$status" == "0" ]] && status="Unknown"

    current_avg=$(read_sysfs "$BATTERY_PATH/current_avg")
    current_avg_ma=$((current_avg / 100))
    current_avg_ma="${current_avg_ma%??}.${current_avg_ma: -2}"

    voltage_now=$(read_sysfs "$BATTERY_PATH/voltage_now")
    voltage_v=$((voltage_now / 1000))
    voltage_v="${voltage_v%???}.${voltage_v: -3}"

    temp=$(read_sysfs "$BATTERY_PATH/temp")
    temp_c=$((temp / 10))
    temp_c="${temp_c%?}.${temp_c: -1}"

    brightness=$(read_sysfs "$FRONTLIGHT_PATH")

    echo "$capacity,$charge_now_mah,$charge_full_mah,$status,$current_avg_ma,$voltage_v,$temp_c,$brightness"
}

log_data() {
    local timestamp="$(date '+%Y-%m-%dT%H:%M:%S')"
    local date_str="$(date +%Y-%m-%d)"
    local log_file="$SCRIPT_DIR/battery_log_${date_str}.csv"
    local data="$(get_battery_data)"

    if [[ ! -f "$log_file" ]]; then
        echo "timestamp,capacity_percent,charge_now_mah,charge_full_mah,status,current_avg_ma,voltage_v,temp_c,brightness" > "$log_file"
    fi

    echo "${timestamp},${data}" >> "$log_file"

    IFS=',' read -r capacity charge_now_mah charge_full_mah status current_avg_ma voltage_v temp_c brightness <<< "$data"
    echo "Logged: ${capacity}% ${charge_now_mah}mAh ${status} ${current_avg_ma}mA brightness:${brightness}"
}

main() {
    echo "Battery logger starting..."
    echo "Logging to directory: $SCRIPT_DIR"
    echo "Check interval: ${CHECK_INTERVAL}s, Log interval: ${LOG_INTERVAL}s"

    local last_log_time=0

    while [[ $RUNNING -eq 1 ]]; do
        local current_time=$(date +%s)

        if (( current_time - last_log_time >= LOG_INTERVAL )); then
            log_data
            last_log_time=$current_time
        fi

        sleep $CHECK_INTERVAL
    done
}

main "$@"