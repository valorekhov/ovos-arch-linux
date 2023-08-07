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