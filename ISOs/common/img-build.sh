function prepare_image(){
    local target_dir=${1:-/target}
    local size_mb=${2:-8192}
    local boot_mount_point={3:-boot}

    mkdir -p $target_dir/
    dd if=/dev/zero of=$target_dir/ovos-arch.raw bs=1M count=$size_mb
    sudo losetup -fP $target_dir/ovos-arch.raw
    sudo parted -s /dev/loop0 mklabel msdos
    # make 2 partitions, 1 for boot (200 MB), 1 for root (rest of disk)
    sudo parted -s /dev/loop0 mkpart primary 2048s 200M
    sudo parted -s /dev/loop0 set 1 boot on
    sudo parted -s /dev/loop0 mkpart primary 200M 100%
    sudo mkfs.fat -F 32 /dev/loop0p1
    sudo mkfs.ext4 /dev/loop0p2
    sudo mount /dev/loop0p2 /tmp/docker-build/
    sudo mkdir -p "/tmp/docker-build/$boot_mount_point"
    sudo mount /dev/loop0p1 "/tmp/docker-build/$boot_mount_point"
}

function unmount_image(){
    local boot_mount_point={2:-boot}
    sync
    sudo umount "/tmp/docker-build/$boot_mount_point" 
    sudo umount /tmp/docker-build
    sudo losetup -d /dev/loop0
}