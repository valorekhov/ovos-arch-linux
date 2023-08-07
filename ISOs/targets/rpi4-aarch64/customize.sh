#!/bin/sh

./customize-common.sh

/usr/bin/systemctl enable pulseaudio.service || echo "pulseaudio.service not found"

echo 
echo "##### Finished image customization"