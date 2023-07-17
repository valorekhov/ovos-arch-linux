set -o errexit
set -o pipefail

WORKDIR="$1"

ensure_srcinfo() {
    local pkg_build="$1"
    local src_info_path="${pkg_build%/*}/.SRCINFO"
    local src_info_exists=false

    if [ -f "$src_info_path" ]; then
        src_info_exists=true
        src_info_last_write=$(stat -c %Y "$src_info_path")
        pkg_last_write=$(stat -c %Y "$pkg_build")

        # if the PKGBUILD is newer than the .SRCINFO, then we need to re-generate the .SRCINFO
        # or if "$INPUT_REBUILD_ALL" = 1 to update all packages
        
        if [ "$pkg_last_write" -gt "$src_info_last_write" ] || [ "$INPUT_REBUILD_ALL" = 1 ]; then
            pushd "${pkg_build%/*}" > /dev/null
            echo "Generating SRCINFO for ${pkg_build%/*}"
            makepkg --printsrcinfo > "$src_info_path" 
            popd > /dev/null
        fi
    fi
}

echo "WORKDIR: $WORKDIR"
echo "Running as: $(whoami) with UID: $UID"

echo "Ensuring Makefile dependencies ..."
export -f ensure_srcinfo
find "$WORKDIR/"PKGBUILDs{,-extra} -type f -name "PKGBUILD" -exec bash -c 'ensure_srcinfo "$0"' {} \;
