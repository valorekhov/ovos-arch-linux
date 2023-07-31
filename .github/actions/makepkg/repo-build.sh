set -o errexit
set -o pipefail

WORKDIR="$1"

export ONLINE_REPO_URI="$INPUT_REPOURL"
export SKIP_LOCAL_PKG_CHECK=1

echo "Building repo with arch $INPUT_ARCH and repo url: $ONLINE_REPO_URI"

ARCH="$INPUT_ARCH" MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" create-repo
echo "Repo DBs created successfully"
sudo ARCH="$INPUT_ARCH" make -C "$WORKDIR" -f "$WORKDIR/Makefile" sync-repo
echo "OVOS online repo synced"

if [ "$INPUT_REBUILDALL" = 1 ] || [ -z "$INPUT_PACKAGES" ]; then
    echo "Rebuilding all packages"
    ARCH="$INPUT_ARCH" MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" all
else
    # The incoming $INPUT_PACKAGES will contain entries formatted PKGBUILDs{,-extra}/<package>/PKGBUILD
    # We need to extract the <package> name from each entry, and then feed it into make

    pkglist=()
    for pkg in $INPUT_PACKAGES; do
        pkglist+=("$(basename "$(dirname "$pkg")")")
    done

    echo "Building packages: $pkglist"
    ARCH="$INPUT_ARCH" MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" "$pkglist[@]"
fi