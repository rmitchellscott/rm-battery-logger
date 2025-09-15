#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGGER_SCRIPT="$SCRIPT_DIR/battery_logger.sh"
PID_FILE="$SCRIPT_DIR/battery_logger.pid"
LOG_FILE="$SCRIPT_DIR/battery_logger.log"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Battery logger is already running (PID: $PID)"
        exit 1
    else
        echo "Removing stale PID file"
        rm -f "$PID_FILE"
    fi
fi

if [ ! -f "$LOGGER_SCRIPT" ]; then
    echo "Error: Logger script not found at $LOGGER_SCRIPT"
    exit 1
fi

echo "Starting battery logger..."
nohup bash "$LOGGER_SCRIPT" > "$LOG_FILE" 2>&1 &
PID=$!

echo "$PID" > "$PID_FILE"
echo "Battery logger started with PID: $PID"
echo "Logs will be saved to: $SCRIPT_DIR"
echo "Runtime log: $LOG_FILE"