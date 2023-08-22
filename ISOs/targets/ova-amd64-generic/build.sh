TARGET_DIR=${1:-/target}
TARGET_NAME=${2:-ovos-arch}
SIZE_MB=${3:-8192}

source ../../common/img-build.sh

if [ -n "$PACKAGE_CACHE_URI" ]; then
    PACKAGE_CACHE_URI="$PACKAGE_CACHE_URI/\$repo/os/\$arch"
    echo "Using package cache: $PACKAGE_CACHE_URI"
fi

docker build --build-arg PACKAGE_CACHE_URI="$PACKAGE_CACHE_URI" -t archlinux-install-builder -f Containerfile .

prepare_image $TARGET_DIR $SIZE_MB efi

sudo cp -r ./overlay/* /tmp/docker-build/
docker run --privileged -e PACKAGE_CACHE_URI="$PACKAGE_CACHE_URI" -e REPO_URL="$REPO_URL" -v $PWD:/scripts -v $PWD/../../common:/scripts-common -v /tmp/docker-build/:/archlinux/rootfs archlinux-install-builder bash /scripts/install.sh 
sudo cp -r ./overlay_overrides/* /tmp/docker-build/

# sudo cp -r /tmp/docker-build-rootfs/rootfs/* /tmp/docker-build/
unmount_image efi

# convert to vmdk
qemu-img convert -f raw -O vmdk $TARGET_DIR/ovos-arch.raw $TARGET_DIR/ovos-arch.vmdk && rm $TARGET_DIR/ovos-arch.raw

# create the ovf
cp ovos-arch.ovf $TARGET_DIR/ovos-arch.ovf

# Generate the manifest file containing SHA sums of the OVF and VMDK files
echo "SHA256 (ovos-arch.ovf) = $(sha256sum $TARGET_DIR/ovos-arch.ovf | cut -d ' ' -f 1)" > $TARGET_DIR/ovos-arch.mf
echo "SHA256 (ovos-arch.vmdk) = $(sha256sum $TARGET_DIR/ovos-arch.vmdk | cut -d ' ' -f 1)" >> $TARGET_DIR/ovos-arch.mf

# create the ova
pushd $TARGET_DIR > /dev/null
tar -cf "$TARGET_NAME.ova" ovos-arch.ovf ovos-arch.mf ovos-arch.vmdk
sha256sum "$TARGET_NAME.ova" > "$TARGET_NAME.ova.sha256"
popd > /dev/null
