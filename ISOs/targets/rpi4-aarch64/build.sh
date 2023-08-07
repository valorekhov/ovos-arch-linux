FLAVOR=${1:-generic}
TARGET_DIR=${2:-/target}
TARGET_NAME=${3:-ovos-arch}
SIZE_MB=${4:-8192}

source ../common/img-build.sh

docker build -t archlinux-install-builder -f Containerfile .

prepare_image $TARGET_DIR $SIZE_MB boot

sudo cp -r ./overlay/* /tmp/docker-build/
docker run --privileged -v $PWD:/scripts -v $PWD/../../common:/scripts-common -v /tmp/docker-build/:/archlinux/rootfs archlinux-install-builder bash /scripts/install.sh "$FLAVOR"
sudo cp -r ./overlay_overrides/* /tmp/docker-build/

unmount_image boot

mv "$TARGET_DIR/ovos-arch.raw" "$TARGET_DIR/$TARGET_NAME.img"

pushd $TARGET_DIR > /dev/null
tar -czvf "$TARGET_NAME.img.tar.gz" "$TARGET_DIR/$TARGET_NAME.img"
sha256sum "$TARGET_NAME.img.tar.gz" > "$TARGET_NAME.img.tar.gz.sha256"
popd > /dev/null
