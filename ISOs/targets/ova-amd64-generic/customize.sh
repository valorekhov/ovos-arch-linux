#!/bin/sh

./customize-common.sh

# replace QT_QPA_PLATFORM=eglfs with QT_QPA_PLATFORM=linuxfb for non-accelerated graphics in VMs
sed -i 's/=eglfs/=linuxfb/g' /home/ovos/.config/ovos-shell/.env

/usr/bin/systemctl enable pulseaudio.service || echo "pulseaudio.service not found"

mkinitcpio -p ovos-arch

echo 
echo "##### Finished image customization"