# OVOS Arch Linux

> Fleeting pre-built image delight, eternal OVOS Arch insight.

This repository contains the Arch Linux packages required to run OpenVoiceOS on Arch Linux. Supported architectures are x86_64, aarch64 and armv7h.

This is a community project and is not officially supported by the OpenVoiceOS project. Do not create issues in the OpenVoiceOS project 
for issues related to this repository. 

## Why another OVOS distribution?
- It is Arch!
- It is not Buildroot. 
- Builds from soruce on a Raspberry PI4 in under 120 minutes with the config of Mimic1, Vosk, and Precise Wake Word Engine.
- Rolling release means you don't need to download an image every time you want to update.

### Other perks:
- Less performance overhead than Docker or VMs, same performance as Buildroot, Raspbian, and others running software directly on your (underpowered) device.
- Comes pre-packaged with Mimic3 on-device TTS
- Start with a basic config and build up from there as you get comfortable with OVOS.
- Did I mention it is Arch? (I know, I know, I am biased)

### Existential FAQ:
- Q1: When will it have Spotify, and turn on the lights at my house?
- A: NOW! (well, not really, but you can install it yourself given that you have access to all the Arch Linux packages)
     
     In all seriousness, the goal of this repo is to provide a base system for OVOS on a well-mainained set of Arch packages and nothing more.

- Q2: When will it have <insert awesome community skill> available?
- A: Pick one of:
     - Now: if you install it through `osm`. 
            HELP WANTED: Suggestions welcome for another method to install "user contributed" skills into the home directory of the mycroft/ovos user.
     - Somewhat later: if you are willing to submit a PR to this repo with a reasonable number of dependencies.
     - Never: unless OVOS desides to onboard it into their official repos. 

         We reviewed every PKGBUILD included in this repo, including a limited set of pinned AUR package versions. 
         Think of this as doing a `yay` source review on 200+ packages. Since OVOS and Mycroft skills are (presently) developed in Python,
         AND we have to distribute every python package as its own sepearate Arch package, we have to be very selective about what we include.  

         This is the reason why the Wikipedia and Wolfram Alpha skills are not presently included in this repo. 
     
- Q3: When can I download a pre-built image?
- A: We may provide a convenience image later. However, expect it to look more like ArchLinuxARM -- a starting point for you to build your own system.
     See Q1 above. HOWEVER, nothing is stopping you from doing a full Manjaro, EndeavourOS, etc. and creating your own image project based on this repo. 


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

### Installing from the OVOS Arch package repository:
Pre-built packages are available for architectures x86_64, aarch64 and armv7h. This is a convenient way to install OVOS Arch on a new system and keeping it up to date.
However, the package build facility is still being worked on, so do expect some instability as we work through the kinks.

Edit `/etc/pacman.conf` and add the following repository:
```
[ovos-arch]
SigLevel = Optional TrustAll
Server = https://ovosarchlinuxpackages.blob.core.windows.net/ovos-arch/$arch
```
Run `pacman -Sy ovos-enclosure-base` to download the ovos-arch repo and install the base system. You may replace `ovos-enclosure-base` with `ovos-enclosure-rpi4-mark2` if you are installing on a Mark II device.
The installation process will guide you through selection of a few options. Be sure to select:
- the 'dinkum-listener' and its corresponding 'alsa microphone plugin' option (tested and working)
- 'python-ovos-messagebus' as the bus server option
- TODO: add more options here

You will note that the above repository is unsigned at this time.

> HELP WANTED: If you are interested in helping to figure out a way to sign packages in an unattended format using a hosted HSM, such as the KeyVault, reach out to me on the Matrix chat. 

If installing unsigned packages from a random Azure location is not your thing, head over to the next section. 


### Building From Source
Kudos to you for being an OSS purist!

In order to avoid rebuilding previously-created packages, Makefile is configured to look for files ending with .pkg.tar.zst in a folder belonging to a given package.
This behaviour simplifies the process of re-running `make`, making sure you are able to restart your last build where it was interrupted (most of the time). 
However, on ArchLinuxARM, the default package extension produced by `makepkg` is, .pkg.tar.xz. You will therefore  want to edit `/etc/makepkg.conf` to change 
PKGEXT='.pkg.tar.xz' to PKGEXT='.pkg.tar.zst' for consistent rebuilds. 

For installation on all targets:
```sh
git clone https://github.com/valorekhov/ovos-arch-linux.git
cd ovos-arch-linux
make ovos-enclosure-base
```
For installation onto Mark II hardware, be sure to also `make ovos-enclosure-rpi4-mark2` (reboot is necessary to activate device overlays loaded through `/boot/config.txt`).

The above command will execute `makepkg` according to OVOS package dependencies and will install them directly onto your system. This also, unfortunately, means a set of makepkg dependencies.


#### Troubleshooting incomplete builds
The build process is not perfect. If you encounter an issue, you will usually be given an error as to why the CURRENT package may not proceed with the build. Ususally this is due to missing dependencies that
get built and installed in a previous step. Read the error message carefully and try to determine which packages are missing. On the example below, the lines containing 'error: target not found:' provide a clue.
Do note there is another longer list of 'Missing dependencies:' underneath, which is misleading and lists packages readily available in Arch repos.
```
==> Checking runtime dependencies...
==> Installing missing dependencies...
error: target not found: mycroft-gui
==> ERROR: 'pacman' failed to install missing dependencies.
==> Missing dependencies:
```

Once you know which packages are missing, you can run `make <package-name>` to build and install the missing package. Observe the output carefully for clues and fix accordingly. One very common issue is that
a package may be built successfully, but not installed due to a timed out sudo prompt to perform the actual installation. In this state `make` will skip the package build as it sees already-built package files.
Fix this by either running `pacman -U` to the files located in the package folder, or by deleting them and re-running `make <package-name>`.

## Post-installation

### Sound System
Consider how OVOS will communicate with the sound system. `ovos-enclosure-rpi4-mark2` makes an opinionated choice to use `ovos-enclosure-audio-pulse`, which provides multi-seat Pulse Server functionality appropriate
for embedded systems. However, `ovos-enclosure-base` installs make no such choice leaving it up to the user to decide how to configure the sound system. 

### Installing Skills
The official OVOS skills, which are few, may be installed directly using `pacman`, for example:
```sh
pacman -S ovos-official-skill-weather
```

For user-contributed skills, you may use `osm` to install them. The `python-ovos-core` package has been configured to provision
a virtual environment for use of the skills manager and skills message bus. It also patches the `osm` command to use the same virtual environment: ```/home/ovos/.local/share/OpenVoiceOS/.venv```. Due to a yet-to-be-resolved issue with ovos-core file locking, if you intened to run `osm` as a user other than `ovos`, the best way to execute it is to use `sudo su`, i.e.:

```sh
sudo su - ovos -c "osm install https://github.com/NeonGeckoCom/skill-ip_address"
```
