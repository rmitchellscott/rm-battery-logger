#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/battery_logger.pid"

# Find all running battery_logger.sh processes
RUNNING_PIDS=$(ps | grep "battery_logger.sh" | grep -v grep | awk '{print $1}')

if [ -z "$RUNNING_PIDS" ]; then
    echo "Battery logger is not running"
    rm -f "$PID_FILE"
    exit 1
fi

echo "Stopping battery logger (PID(s): $RUNNING_PIDS)..."

# Kill all found processes
for PID in $RUNNING_PIDS; do
    kill -TERM "$PID" 2>/dev/null
done

# Wait for processes to stop gracefully
sleep 2

# Check if any are still running and force kill if needed
STILL_RUNNING=$(ps | grep "battery_logger.sh" | grep -v grep | awk '{print $1}')
if [ -n "$STILL_RUNNING" ]; then
    echo "Warning: Some processes didn't stop gracefully, forcing termination..."
    for PID in $STILL_RUNNING; do
        kill -KILL "$PID" 2>/dev/null
    done
    sleep 1
fi

# Verify all stopped
REMAINING=$(ps | grep "battery_logger.sh" | grep -v grep | awk '{print $1}')
if [ -n "$REMAINING" ]; then
    echo "Error: Could not stop all battery logger processes"
    exit 1
else
    echo "Battery logger stopped successfully"
    rm -f "$PID_FILE"
    exit 0
fi