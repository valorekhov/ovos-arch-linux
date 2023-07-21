set -o errexit
set -o pipefail

WORKDIR="$1"

ensure_srcinfo() {
    local pkg_build="$1"
    local force_rebuild="${2:-${INPUT_REBUILDALL:-"0"}}"
    local src_info_path="${pkg_build%/*}/.SRCINFO"
    local src_info_exists=false

    if [ -f "$src_info_path" ]; then
        src_info_exists=true
        src_info_last_write=$(stat -c %Y "$src_info_path")
        pkg_last_write=$(stat -c %Y "$pkg_build")

        if  [ $force_rebuild = 1 ]; then
            echo "Forcing rebuild of $pkg_build"
        fi
        
        if [ "$pkg_last_write" -gt "$src_info_last_write" ] || [ "$force_rebuild" = 1 ]; then
            pushd "${pkg_build%/*}" > /dev/null
            echo "Generating SRCINFO for ${pkg_build%/*}"
            makepkg --printsrcinfo > "$src_info_path" 
            popd > /dev/null
        fi
    fi
}

echo "WORKDIR: $WORKDIR"
echo "Running as: $(whoami) with UID: $UID"

echo "Makefile dependencies RebuildAll: $INPUT_REBUILDALL; Packages: $INPUT_PACKAGES"

# if $INPUT_REBUILDALL is set to 1 or $INPUT_PACKAGES is not set or empty, then we need to ensure that the .SRCINFO files are up to date
# Otherwise, we iterate over the packages in $INPUT_PACKAGES and explicitly re-generate the .SRCINFO files for those packages

if [ "$INPUT_REBUILDALL" = 1 ] || [ -z "$INPUT_PACKAGES" ]; then
    echo "Rebuilding all packages"
    export -f ensure_srcinfo
    find "$WORKDIR/"PKGBUILDs{,-extra} -type f -name "PKGBUILD" -exec bash -c 'ensure_srcinfo "$0"' {} \;
else
    echo "Updating SRCINFO for packages: $INPUT_PACKAGES"
    for pkg in $INPUT_PACKAGES; do
        # the $pkg may not end with `PKGBUILD`, so we need to append it
        if [ "${pkg: -9}" != "PKGBUILD" ]; then
            pkg="$pkg/PKGBUILD"
        fi
        ensure_srcinfo "$WORKDIR/$pkg" 1
    done
fi 


