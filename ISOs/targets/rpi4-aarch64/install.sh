FLAVOR=${1:-generic}
echo "Building flavor: $FLAVOR"

# for mark2 we need to install the ovos-enclosure-rpi4-mark2 and ovos-shell-standalone package 
if [ "$FLAVOR" == "mark2" ]; then
    echo "Installing mark2 packages"
    ENCLOSURE_BASE="ovos-enclosure-rpi4-mark2"
    PACKAGE_EXTRAS="ovos-shell-standalone"
else
    ENCLOSURE_BASE="ovos-enclosure-base"
    PACKAGE_EXTRAS=""
fi

# read ../common/packages.txt, which is a list of packages to install, one package per line
if [ -f ../common/packages.txt ]; then
    PACKAGES="$(cat ../common/packages.txt)"
    PACKAGES=($PACKAGES)
fi

echo "Packages to install: $ENCLOSURE_BASE ${PACKAGES[@]} $PACKAGE_EXTRAS"

pacstrap -K /archlinux/rootfs \
        "$ENCLOSURE_BASE" \
        "$PACKAGES[@]" \
        "$PACKAGE_EXTRAS"

cp /scripts/customize.sh /archlinux/rootfs/root/customize.sh
cp /scripts-common/customize.sh /archlinux/rootfs/root/customize-common.sh
arch-chroot /archlinux/rootfs /root/customize.sh
rm /archlinux/rootfs/root/customize*.sh