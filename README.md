# OVOS Arch Linux
This repository contains the Arch Linux packages required to run OpenVoiceOS on Arch Linux. Supported architectures are x86_64 and AArch64.

## Intalling Onto a New / Bare System
While x84_64 architecture is supported, the following instructions have been prepared for a Raspberry PI4. 

1. Perform AArch64 setup instructions described here: https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
   NB> Be sure to download the AArch64 tarball. The project has not been yet tested on armv7hf
2. Boot into your RPi4 and perform initial networking setup (however you know and whatever your setup). Be sure
   to init the `pacman-key` per the instructions.
```sh
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu iwd ufw networkmanager base-devel git openssh
systemctl enable iwd
systemctl enable NetworkManager
systemctl enable sshd
ufw enable
ufw allow ssh
```
3. If running a Mycroft Mark II setup, the LCD screen has been ovserved not to work with the mainline kernel, resulting 
   in a screen which cycles through colors. To get the LCD to work replace the kernel with `linux-rpi` and also install
   the corresponding `linux-rpi-headers` package. You should also install `raspberrypi-bootloader` and uninstall `uboot` 
   which will place the "traditional" bootloader folder structure on the /boot partition. This is required for the 
   SJ201 overlays to work. 
```sh
pacman -R linux-aarch64 uboot-raspberrypi
pacman -S linux-rpi linux-rpi-headers 
```
    Edit `/boot/cmdline.txt` and replace `root=/dev/mmcblk0p2` with `root=/dev/sda2` (or whatever your root partition is)

    To perform the above steps, use of a chroot will likely be is required. If you have access to another running AArch64 system 
    (another RPi4, for example), mount the new USB drive and chroot into it. If you do not have access to another AArch64 system,
    you can use qemu to emulate one following these instructions: https://wiki.archlinux.org/title/QEMU#Chrooting_into_arm/arm64_environment_from_x86_64. You can also use the `arch-chroot` script from the `arch-install-scripts` package.

    To simpile the process, you can use the wired ethernet port on the RPi4 to connect to the internet and configure the
    wireless interface later. Use of a USB keyboard is also recommended before you are able to log in via SSH.



### Building From Source
For installation on all taegets:
```sh
git clone https://github.com/valorekhov/ovos-arch-linux.git
cd ovos-arch-linux
make ovos-enclosure-base
```
The above command will execute `makepkg` according to OVOS package dependencies and will install them onto your system.

For installation onto Mark II hardware, be sure to also `make ovos-enclosure-rpi4-mark2` and reboot.

