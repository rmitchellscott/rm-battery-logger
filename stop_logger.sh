#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/battery_logger.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "Battery logger is not running (no PID file found)"
    exit 1
fi

PID=$(cat "$PID_FILE")

if ! kill -0 "$PID" 2>/dev/null; then
    echo "Battery logger is not running (process $PID not found)"
    rm -f "$PID_FILE"
    exit 1
fi

echo "Stopping battery logger (PID: $PID)..."
kill -TERM "$PID"

for i in {1..10}; do
    if ! kill -0 "$PID" 2>/dev/null; then
        echo "Battery logger stopped successfully"
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

echo "Warning: Process didn't stop gracefully, forcing termination..."
kill -KILL "$PID" 2>/dev/null

if kill -0 "$PID" 2>/dev/null; then
    echo "Error: Could not stop battery logger"
    exit 1
else
    echo "Battery logger force-stopped"
    rm -f "$PID_FILE"
fi