if [ -f /scripts-common/packages.txt ]; then
    PACKAGES="$(cat /scripts-common/packages.txt)"
    echo "Found packages.txt"
    PACKAGES=($PACKAGES)
fi

PACKAGE_EXTRAS="$PACKAGE_EXTRAS linux python-ovos-stt-plugin-whispercpp"
PACKAGE_EXTRAS=($PACKAGE_EXTRAS)

echo "Packages to install: $ENCLOSURE_BASE ${PACKAGES[@]} ${PACKAGE_EXTRAS[@]}"

pacstrap -K /archlinux/rootfs \
        "$ENCLOSURE_BASE" \
        "${PACKAGES[@]}" \
        "${PACKAGE_EXTRAS[@]}"

cp /scripts/customize.sh /tmp/customize.sh
cp /scripts-common/customize.sh /tmp/customize-common.sh
arch-chroot /archlinux/rootfs /tmp/customize.sh
# rm /tmp/customize*.sh