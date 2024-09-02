#!/bin/bash

# Function to find the correct input device
find_input_device() {
    for dev in /dev/input/event*; do
        if udevadm info -q property -n "$dev" | grep -q "soc:sj201_buttons"; then
            echo "$dev"
            return 0
        fi
    done
    return 1
}

# Function to handle short KEY_WAKEUP press
handle_short_wakeup() {
    echo "Performing dummy action for short press"
    WAKEUP_SCRIPTS_DIR="/etc/sj201-wakeup.d"
    if [ -d "$WAKEUP_SCRIPTS_DIR" ]; then
        for script in $(ls -1 "$WAKEUP_SCRIPTS_DIR" | sort); do
            if [ -x "$WAKEUP_SCRIPTS_DIR/$script" ]; then
                "$WAKEUP_SCRIPTS_DIR/$script"
            fi
        done
    else
        echo "Wakeup scripts directory not found: $WAKEUP_SCRIPTS_DIR"
    fi
}

# Function to handle long KEY_WAKEUP press
handle_long_wakeup() {
    echo "Long KEY_WAKEUP press detected at $(date). Initiating system shutdown..." >> /var/log/wakeup_events.log
    echo "Initiating system shutdown..."
    sudo shutdown -h now
}

# Find the correct input device
INPUT_DEVICE=$(find_input_device)

if [ -z "$INPUT_DEVICE" ]; then
    echo "Error: Could not find the input device."
    exit 1
fi

echo "Using input device: $INPUT_DEVICE"

# Variables for KEY_WAKEUP handling
WAKEUP_START_TIME=0
LONG_PRESS_THRESHOLD=10  # seconds

# Monitor for KEY_WAKEUP events
evtest "$INPUT_DEVICE" | while read -r line; do
    if echo "$line" | grep -q "type 1 (EV_KEY)"; then
        if echo "$line" | grep -q "code 143 (KEY_WAKEUP), value 1"; then
            WAKEUP_START_TIME=$(date +%s)
        elif echo "$line" | grep -q "code 143 (KEY_WAKEUP), value 0"; then
            WAKEUP_END_TIME=$(date +%s)
            PRESS_DURATION=$((WAKEUP_END_TIME - WAKEUP_START_TIME))

            if [ $PRESS_DURATION -ge $LONG_PRESS_THRESHOLD ]; then
                handle_long_wakeup
            else
                handle_short_wakeup
            fi
        fi
    fi
done