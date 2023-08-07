TARGET_DIR=${1:-/target}
TARGET_NAME=${2:-ovos-arch}
SIZE_MB=${3:-8192}

docker build -t archlinux-install-builder -f Containerfile .

# create an 8GB disk image
mkdir -p $TARGET_DIR/
dd if=/dev/zero of=$TARGET_DIR/ovos-arch.raw bs=1M count=$SIZE_MB
sudo losetup -fP $TARGET_DIR/ovos-arch.raw
sudo parted -s /dev/loop0 mklabel msdos
# make 2 partitions, 1 for boot (200 MB), 1 for root (rest of disk)
sudo parted -s /dev/loop0 mkpart primary 2048s 200M
sudo parted -s /dev/loop0 set 1 boot on
sudo parted -s /dev/loop0 mkpart primary 200M 100%
sudo mkfs.fat -F 32 /dev/loop0p1
sudo mkfs.ext4 /dev/loop0p2
sudo mount /dev/loop0p2 /tmp/docker-build/
sudo mkdir -p /tmp/docker-build/efi
sudo mount /dev/loop0p1 /tmp/docker-build/efi

sudo cp -r ./overlay/* /tmp/docker-build/
docker run --privileged -v $PWD:/scripts -v /tmp/docker-build/:/archlinux/rootfs archlinux-install-builder bash /scripts/install.sh 
sudo cp -r ./overlay_overrides/* /tmp/docker-build/

# sudo cp -r /tmp/docker-build-rootfs/rootfs/* /tmp/docker-build/
sync
sudo umount /tmp/docker-build/efi 
sudo umount /tmp/docker-build
sudo losetup -d /dev/loop0

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
