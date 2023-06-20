This is an arch package for a fan included with the SJ201 rev10 HAT, part of the production Mycroft Mark II


This packages replaces `sj201 set-fan-speed 30` on startup with a kernel-managed `pwm_fan` driver monitoring the CPU thermal zone using 4 temperature+fan speed settings.

Manual installation shall also require adding to `/boot/config.txt`:
```
dtoverlay=sj201-rev10-pwm-fan
```

To confirm the driver loaded:
```sh
sudo cat /sys/kernel/debug/pwm
```
Should include
```
pwm-1   (sj201-rev10-pwm-fan       ): requested enabled period: 1000000 ns duty: 752941 ns polarity: normal
```
Current fan speed zone may be monitored via:

```sh
watch cat /sys/class/thermal/cooling_device0/cur_state
watch cat /sys/class/thermal/thermal_zone0/temp
```
N.B: It is important that `sj201 set-fan-speed 30` is not ran on startup as it replaces GPIO13 pin 
configuration from hardware to software PWM. 

N.B2: PWM signal logic is inverted. 100% duty (logic 1) means fan is OFF, 0% duty (logic 0) means fan is ON. I couldn't figure out how to invert the PWM via the device tree, Therefore cooling levels are configured in the decreasing order:

```
cooling-levels = <255 192 129 66 0>;
```
