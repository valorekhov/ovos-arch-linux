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

# Function to change volume
change_volume() {
    local change=$1
    # local current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
    pactl set-sink-volume @DEFAULT_SINK@ $change
    new_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
    echo "New Volume: $new_volume%"
    play_ding "$new_volume"
}

# Function to play ding sound
play_ding() {
    local volume=$1

    if [ -f "$sound_file" ]; then
        paplay "$sound_file"
    else
        echo "Warning: Sound file not found at $sound_file"
    fi
}

# Set default sound file
default_sound_file="${HOME}/wyoming/sounds/start_listening.wav"

# Check if a custom sound file is provided as an argument
if [ $# -eq 1 ]; then
    sound_file="$1"
else
    sound_file="$default_sound_file"
fi

echo "Using sound file: $sound_file"

# Find the correct input device
INPUT_DEVICE=$(find_input_device)

if [ -z "$INPUT_DEVICE" ]; then
    echo "Error: Could not find the input device."
    exit 1
fi

echo "Using input device: $INPUT_DEVICE"

# Monitor for volume key events
evtest "$INPUT_DEVICE" | while read -r line; do
    if echo "$line" | grep -q "type 1 (EV_KEY)"; then
        current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
        if echo "$line" | grep -q "code 115 (KEY_VOLUMEUP), value 1"; then
            echo "Volume up key pressed. Current volume: $current_volume%"
            change_volume +10%
        elif echo "$line" | grep -q "code 114 (KEY_VOLUMEDOWN), value 1"; then
            echo "Volume down key pressed. Current volume: $current_volume%"
            change_volume -10%
        fi
    fi
done