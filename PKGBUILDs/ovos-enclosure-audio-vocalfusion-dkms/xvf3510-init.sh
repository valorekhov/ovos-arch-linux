#!/bin/bash

# Flash xmos firmware
/opt/ovos/bin/xvf3510-flash --direct /usr/lib/firmware/xvf3510/app_xvf3510_int_spi_boot_v4_2_0.bin
python /opt/ovos/bin/init_tas5806.py
# Init TI Amp
# sj201 init-ti-amp
