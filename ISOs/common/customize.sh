#!/bin/sh

echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen  

# printf "\n[ovos-arch]\nSigLevel = Optional TrustAll\nServer = ${REPO_URL}/\$arch" >> /etc/pacman.conf 
printf "\nStorage=Volatile\n" >> /etc/systemd/journald.conf

/usr/bin/systemctl enable sshd.service 
/usr/bin/systemctl enable NetworkManager.service || echo "NetworkManager.service not found"
# /usr/bin/systemctl enable pulseaudio.service || echo "pulseaudio.service not found"

useradd -m -G wheel -s /bin/bash uzanto
echo "uzanto:openvoiceos" | chpasswd
# include a note for the user to change the password
echo "Please change the uzanto password after first login!" > /etc/issue
echo 'printf "#####\n\nPlease change your password now!\n\n#####\n\n"' >> /home/uzanto/.bashrc
echo "uzanto ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/uzanto

echo 
echo "##### Finished common image customization"