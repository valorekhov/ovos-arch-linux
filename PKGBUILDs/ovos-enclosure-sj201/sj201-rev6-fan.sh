#!/bin/bash

# Constants
HDW_MIN=0
HDW_MAX=255
SFW_MIN=0
SFW_MAX=100

# Function to convert speed to hardware value
speed_to_hdw_val() {
    local speed=$1
    local out_steps=$((HDW_MAX - HDW_MIN))
    local in_steps=$((SFW_MAX - SFW_MIN))
    local ratio=$((out_steps / in_steps))

    # Force compliance
    if ((speed > SFW_MAX)); then
        speed=$SFW_MAX
    fi
    if ((speed < SFW_MIN)); then
        speed=$SFW_MIN
    fi

    local hdw_val=$((speed * ratio + HDW_MIN))
    echo "$hdw_val"
}

# Function to set hardware speed
hdw_set_speed() {
    local hdw_speed=$1

    # Force compliance
    if ((hdw_speed > HDW_MAX)); then
        hdw_speed=$HDW_MAX
    fi
    if ((hdw_speed < HDW_MIN)); then
        hdw_speed=$HDW_MIN
    fi

    local cmd=("i2cset" "-a" "-y" "1" "0x04" "101" "$hdw_speed" "i")
    local output=$( "${cmd[@]}" 2>&1 )
    echo "$output"
}

# Function to set fan speed
set_fan_speed() {
    local speed=$1
    local fan_speed=$(speed_to_hdw_val "$speed")
    echo "Setting speed of $speed / $fan_speed"
    hdw_set_speed "$fan_speed"
}

# Call the appropriate function based on the first argument
case "$1" in
    set_fan_speed)
        set_fan_speed "$2"
        ;;
    *)
        echo "Invalid function name: $1"
        exit 1
        ;;
esac