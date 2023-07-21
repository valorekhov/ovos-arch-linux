set -o errexit
set -o pipefail

WORKDIR="$1"

MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" repo
sudo make -C "$WORKDIR" -f "$WORKDIR/Makefile" sync-repo

if [ "$INPUT_REBUILDALL" = 1 ] || [ -z "$INPUT_PACKAGES" ]; then
    echo "Rebuilding all packages"
    MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" all
else
    echo "Updating SRCINFO for packages: $INPUT_PACKAGES"
    for pkg in $INPUT_PACKAGES; do
        echo "Processing $pkg"
        MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" "$pkg"
    done
fi