#!/usr/bin/env bash

set -o errexit
set -o pipefail

# base directory
BASEDIR=$(pwd)

# working directory
WORKDIR="$(pwd)/${INPUT_WORKING_DIR}"

echo "Base directory: $BASEDIR"
echo "Working directory: $WORKDIR"

ensure_srcinfo() {
    local pkg_build="$1"
    local src_info_path="${pkg_build%/*}/.SRCINFO"
    local src_info_exists=false

    if [ -f "$src_info_path" ]; then
        src_info_exists=true
        src_info_last_write=$(stat -c %Y "$src_info_path")
        pkg_last_write=$(stat -c %Y "$pkg_build")

        if ((src_info_last_write < pkg_last_write)); then
            pushd "${pkg_build%/*}" > /dev/null
            echo "Generating SRCINFO for ${pkg_build%/*}"
            makepkg --printsrcinfo > "$src_info_path" 
            popd > /dev/null
        fi
    fi
}

#
makefile(){
    ls -la "$WORKDIR"

    echo "Ensuring Makefile dependencies ..."
    export -f ensure_srcinfo
    find "$WORKDIR/"PKGBUILDs{,-extra} -type f -name "PKGBUILD" -exec bash -c 'ensure_srcinfo "$0"' {} \;
}

#The $INPUT_OPERATION is the operation to perform, i.e. makefile, repo
echo "Operation: $INPUT_OPERATION"
case "$INPUT_OPERATION" in
    makefile)
        makefile
        ;;
    repo)
        repo
        ;;
    *)
        echo "Invalid operation: $INPUT_OPERATION"
        exit 1
        ;;
esac
