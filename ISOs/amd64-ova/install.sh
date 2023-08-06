pacstrap -K /archlinux/rootfs \
        base linux linux-firmware archiso \
        ufw networkmanager openssh gnu-free-fonts \
        ovos-enclosure-base python-ovos-messagebus ovos-shell-standalone \
        python-ovos-dinkum-listener python-ovos-microphone-plugin-alsa \
        python-ovos-tts-plugin-mimic3 python-ovos-stt-plugin-server

cp /scripts/customize.sh /archlinux/rootfs/root/customize.sh
arch-chroot /archlinux/rootfs /root/customize.sh
rm /archlinux/rootfs/root/customize.sh