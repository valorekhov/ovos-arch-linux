FLAVOR=${1:-generic}
echo "Building flavor: $FLAVOR"

PACKAGE_EXTRAS="raspberrypi-bootloader linux-rpi python-ovos-stt-plugin-server"

# for mark2 we need to install the ovos-enclosure-rpi4-mark2 and ovos-shell-standalone package 
if [ "$FLAVOR" == "mark2" ]; then
    echo "Installing mark2 packages"
    ENCLOSURE_BASE="ovos-enclosure-rpi4-mark2"
    PACKAGE_EXTRAS="$PACKAGE_EXTRAS linux-rpi-headers ovos-shell-standalone"
else
    ENCLOSURE_BASE="ovos-enclosure-base"
fi
PACKAGE_EXTRAS=($PACKAGE_EXTRAS)

# read ../common/packages.txt, which is a list of packages to install, one package per line
if [ -f /scripts-common/packages.txt ]; then
    PACKAGES="$(cat /scripts-common/packages.txt)"
    echo "Found packages.txt"
    PACKAGES=($PACKAGES)
fi

echo "Packages to install: $ENCLOSURE_BASE ${PACKAGES[@]} ${PACKAGE_EXTRAS[@]}"

pacstrap -K /archlinux/rootfs \
        "$ENCLOSURE_BASE" \
        "${PACKAGES[@]}" \
        "${PACKAGE_EXTRAS[@]}"

# pacstrap -K /archlinux/rootfs \
#         linux-rpi raspberrypi-bootloader bash # boot-firmware-rpi4

cp /scripts/customize.sh /archlinux/rootfs/root/customize.sh
cp /scripts-common/customize.sh /archlinux/rootfs/root/customize-common.sh
ls /archlinux/rootfs/root/*
arch-chroot /archlinux/rootfs /root/customize.sh
rm /archlinux/rootfs/root/customize*.sh