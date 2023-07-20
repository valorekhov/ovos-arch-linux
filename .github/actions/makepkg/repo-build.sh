set -o errexit
set -o pipefail

WORKDIR="$1"

MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" repo
sudo make -C "$WORKDIR" -f "$WORKDIR/Makefile" sync-repo
MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" all