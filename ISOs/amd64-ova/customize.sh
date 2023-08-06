#!/bin/sh

echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen  

printf "\n\n[ovos-arch]\nSigLevel = Optional TrustAll\nServer = ${REPO_URL}/\$arch" >> /etc/pacman.conf 

/usr/bin/systemctl enable sshd.service 
/usr/bin/systemctl enable NetworkManager.service || echo "NetworkManager.service not found"

echo "root:openvoiceos" | chpasswd

mkinicpio -p ovos-arch

echo 
echo "##### Finished image customization"