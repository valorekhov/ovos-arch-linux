#!/bin/bash
# NEON AI (TM) SOFTWARE, Software Development Kit & Application Framework
# All trademark and other rights reserved by their respective owners
# Copyright 2008-2022 Neongecko.com Inc.
# Contributors: Daniel McKnight, Guy Daniels, Elon Gasper, Richard Leeds,
# Regina Bloomstine, Casimiro Ferreira, Andrii Pernatii, Kirill Hrymailo
# BSD-3 License
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This needs to run as root

# Init TI Amp
/opt/ovos/bin/sj201-tas5806
# Reset LEDs
# sj201 reset-led red

revision=$(/opt/ovos/bin/sj201-revisions.sh)
echo "Current SJ201 Revision: '$revision'"
# Reset fan speed
if [ "${revision}" != "r10" ]; then
    /opt/ovos/bin/sj201-rev6-fan.sh set_fan_speed 30
else
    if [ -f "/sys/firmware/devicetree/base/model" ]; then
        model=$(tr -d '\0'  < /sys/firmware/devicetree/base/model)
        if [[ $model == *"Raspberry Pi 4"* ]]; then
            if grep -Fxq "dtoverlay=sj201-rev10-pwm-fan" /boot/config.txt; then
                echo "dtoverlay=sj201-rev10-pwm-fan is already present in /boot/config.txt"
            else
                echo "" >> /boot/config.txt
                echo "# Installed by Package 'ovos-enclosure-rpi4-mark2-sj201-r10'" >> /boot/config.txt
                echo "dtoverlay=sj201-rev10-pwm-fan" >> /boot/config.txt
                echo "gpio=13=pu" >> /boot/config.txt
                echo "Added dtoverlay=sj201-rev10-pwm-fan to /boot/config.txt"
                echo
                echo "You are going to need to reboot your Mark II for the new PWM Fan logic to take effect..."
            fi
        else
            echo "Not Running On Raspberry Pi 4? Got '$model' instead..."
            echo "You may have to manually modify /boot/config.txt to include dtoverlay=sj201-rev10-pwm-fan at the end"
        fi
    else
            echo "Not running on an RPi / ARM device?"
    fi
fi
