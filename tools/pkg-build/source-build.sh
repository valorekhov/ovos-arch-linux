PKG_ARCH=$(grep "arch =" ".SRCINFO" | sed 's/arch = //g')

carch=${ARCH:-$(uname -m)}
echo "##### Building for $carch"
if [ "$carch" = "armv7l" ] ; then
    carch="armv7h"
fi
if ! echo "$PKG_ARCH" | grep -qE "(any|$carch)" ; then
    echo "##### Skipping build for $carch as arch is not supported"
    exit 0
fi

makepkg -srif --noconfirm 
# if makepkg fails, specifically due to timing out on a credential prompt to install successfully-built packages,
# then let's delete the packages so that rerunning 'make' will rebuild and properly install them
if [ $? -ne 0 ]; then
    rm *.pkg.tar.{zst,xz} || true
    exit 13
fi