WORKDIR="$1"

export ONLINE_REPO_URI="$INPUT_REPOURL"

if [ -n "$INPUT_REPOURL" ] ; then 
    echo "Building repo with repo url: $ONLINE_REPO_URI"
    MODE="repo" make -C "$WORKDIR" -f "$WORKDIR/Makefile" create-repo
fi 
# Otherwise, presuming the package dbs are already in place

echo "Deleting packages: $INPUT_PACKAGES"
archs=(x86_64 aarch64 armv7h)
for arch in "${archs[@]}"; do
    for pkg in $INPUT_PACKAGES; do
        echo "Processing $pkg in $arch DB"
        repo-remove "$WORKDIR/.repo/$arch/ovos-arch.db.tar.gz" "$pkg"
    done
done
