# Arch Package Builder Container
The container is intended to be used as a "clean chroot" for building & testing packages.
Tested with podman.

To build:
Prior to building this container a tagged `archlinux` container is expected on the system.
* For x86_64 / amd64 on a host of the same architecture:  
```sh
podman pull archlinux:base-devel
podman tag archlinux:base-devel archlinux-:base-devel
```
????

To run for the current architecture:
```sh
podman run --userns keep-id:uid=$UID,gid=$GID -ti -v $PWD:/build archlinux-builder
```

To run aarch64 / arm64v8 on an x86_64 host:
```sh
podman run --arch arm64v8 --userns keep-id:uid=$UID,gid=$GID -ti -v $PWD:/build archlinux-builder
```
... which will likely fail with the following message:
```
sudo: effective uid is not 0, is /usr/bin/sudo on a file system with the 'nosuid' option set or an NFS file system without root privileges
```
due to bugs described in: https://bbs.archlinux.org/viewtopic.php?id=242708. The solution is to edit the `/usr/lib/binfmt.d/qemu-aarch64-static.conf` file adding 'OC' flags in addition to the current 'FP' flags at the end of the line, to the full 
flag set of `FPOC`. After editing, restart the  `systemd-binfmt` system service



