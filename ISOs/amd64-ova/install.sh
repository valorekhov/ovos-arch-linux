pacstrap -K /archlinux/rootfs \
        base linux linux-firmware sudo nano vi \
        ufw networkmanager openssh noto-fonts  \
        ovos-enclosure-base python-ovos-messagebus ovos-shell-standalone \
        python-ovos-dinkum-listener python-ovos-microphone-plugin-alsa ovos-enclosure-audio-pulse \
        python-ovos-tts-plugin-mimic3 python-ovos-stt-plugin-server \
        python-ovos-ww-plugin-vosk python-ovos-ww-plugin-precise-lite

cp /scripts/customize.sh /archlinux/rootfs/root/customize.sh
arch-chroot /archlinux/rootfs /root/customize.sh
rm /archlinux/rootfs/root/customize.sh