PKG_ARCH=$(grep "arch =" ".SRCINFO" | sed 's/arch = //g')

if ! echo "$PKG_ARCH" | grep -qE "(any|$(uname -m))" ; then
    echo "##### Skipping build for $(uname -m) as arch is not supported"
    exit 0
fi

makepkg -srif --noconfirm