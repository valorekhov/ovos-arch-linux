```sh
pacman -S qemu-user-static qemu-user-static-binfmt
podman pull --arch arm64 manjarolinux/base:latest
podman tag manjarolinux/base:latest manjaro-arm64
```

Getting the build image for aarch64/arm64v8:
```sh
wget http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
gzip -d ArchLinuxARM-aarch64-latest.tar.gz
podman import ArchLinuxARM-aarch64-latest.tar archlinux-arm64v8:latest
```

Building requires rootful containers due to use of `mknod` in the script.????
```sh
sudo podman build --cap-add mknod ./aarch64 -t manjaro-build-arm64
```