#!/bin/bash

detect_sj201_revision() {
    # Defined I2C addresses
    tiny_address="04"
    xmos_address="2c"
    ti_address="2f"

    i2c_addresses=$(i2cdetect -a -y 1)

    if grep -q "$tiny_address" <<< "$i2c_addresses"; then
        tiny_is_present=true
    else
        tiny_is_present=false
    fi

    if grep -q "$xmos_address" <<< "$i2c_addresses"; then
        xmos_is_present=true
    else
        xmos_is_present=false
    fi

    if grep -q "$ti_address" <<< "$i2c_addresses"; then
        ti_is_present=true
    else
        ti_is_present=false
    fi

    if [[ $ti_is_present && $xmos_is_present ]]; then
        if $tiny_is_present; then
            revision="r6"
        else
            revision="r10"
        fi
    fi

    echo -n "$revision"
}

detect_sj201_revision