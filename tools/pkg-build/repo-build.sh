REPO_DIR=${1%/}
REPO_ARCH=$(basename "$REPO_DIR")
REPO_NAME="ovos-arch"
LOCAL_PACMAN=${2:-"$REPO_DIR/../pacman-wrapper-$(uname -m).sh"}
REPO_DB_NAME=${3:-$REPO_NAME.db.tar.gz}
REPO_DB_FILE="$REPO_DIR/$REPO_DB_NAME"
ARM_ARCHS=("aarch64" "armv7h")

PKGVER=$(grep -m1 "pkgver =" ".SRCINFO" | sed 's/.*pkgver = //g')
PKGREL=$(grep -m1 "pkgrel =" ".SRCINFO" | sed 's/.*pkgrel = //g')
PKG_NAMES=$(grep "pkgname =" ".SRCINFO" | sed 's/pkgname = //g')
PKG_ARCH=$(grep "arch =" ".SRCINFO" | sed 's/arch = //g')
PKG_BASE=$(grep "pkgbase =" ".SRCINFO" | sed 's/pkgbase = //g')

echo "Package name(s): $PKG_NAMES"
local do_build=0
if test -f "$REPO_DB_FILE" ; then
    for PKGNAME in $PKG_NAMES; do
        echo "##### Checking if $PKGNAME-$PKGVER-$PKGREL is already stored in local or online repos"
        if [ "$SKIP_LOCAL_PKG_CHECK" != 1 ] && tar -tf "$REPO_DB_FILE" | grep -m1 -qF "$PKGNAME-$PKGVER-$PKGREL" ; then
            echo " ...... $PKGNAME-$PKGVER-$PKGREL exists in the DB"
        else
            # Now, if $ONLINE_REPO_URI is defined, let's check using pacman if the exact version of the package is already in the online repo
            # This is mostly needed to speed up CI builds where we only need to re-build the specific package targets that have changed
            # In this case, target dependencies will be pulled from the online repo, while the target will be built locally
            if [ -n "$ONLINE_REPO_URI" ] ; then
                echo " ...... Checking if $PKGNAME-$PKGVER-$PKGREL is in the online repo: $ONLINE_REPO_URI"
                if "$LOCAL_PACMAN" -Sl "$REPO_NAME" | grep -m1 -qF "$PKGNAME $PKGVER-$PKGREL"; then
                    echo " ...... and it is found. Skipping build"
                else 
                    echo " ...... $PKGNAME-$PKGVER-$PKGREL is not found online. Will rebuild the entire (split) package."
                    do_build=1
                fi
            else
                echo " ...... $PKGNAME-$PKGVER-$PKGREL is not found locally. Will rebuild the entire (split) package."
                do_build=1
            fi
        fi
    done
else
    echo "##### No DB file NOT found: $REPO_DB_FILE"
fi

if [ "$do_build" = 0 ] ; then
    echo "##### Skipping build as the entire package base $PKGNAME-$PKGVER-$PKGREL is already in the repo"
    exit 0
fi

carch=${ARCH:-$(uname -m)}
echo "##### Building for $carch"
if [ "$carch" = "armv7l" ] ; then
    carch="armv7h"
fi
# if PKG_ARCH array does not contain the current architecture or 'any', skip the build
if ! echo "$PKG_ARCH" | grep -qE "(any|$carch)" ; then
    echo "##### Skipping build for $carch as arch is not supported"
    exit 0
fi

# If REPO_ARCH is not x86_64, AND the package arch is 'any', AND we are not building a split package (PKG_NAMES length is 1)
# check if the package is already built for x86_64, in which case we can copy it here and skip the build
if [ "$REPO_ARCH" != "x86_64" ] && [ $(echo "$PKG_NAMES" | wc -w) -eq 1 ] && [ -f "$REPO_DIR/../x86_64/$PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{zst,xz}" ] ; then
    echo " ...... $PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{zst,xz} exists in the x86_64 repo. Copying it here and skipping the build"
    cp "$REPO_DIR/../x86_64/$PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{zst,xz}" "$REPO_DIR/"
    cp "$REPO_DIR/../x86_64/$PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{xst,xz}.sig" "$REPO_DIR/" || true
else
    MAKEFLAGS="-j$(nproc)" PACMAN="$LOCAL_PACMAN" makepkg --syncdeps --install --noconfirm --force || exit 13
fi

add_to_repo() {
    local repodir="$1"
    local pkg="$2"

    if [ -f "$repodir/$REPO_DB_NAME" ] ; then
        echo "##### Adding $pkg to the DB: $repodir/$pkg"
        cp -v $pkg $repodir
        cp -v $pkg.sig $repodir || true
        repo-add "$repodir/$REPO_DB_NAME" "$repodir/$pkg"
    else
        echo "##### $pkg not found in source package DB $repodir/$REPO_DB_NAME"
    fi
}

shopt -s nullglob 
pkg_files=( *.pkg.tar.zst )
pkg_files+=( *.pkg.tar.xz )
shopt -u nullglob 
echo "##### Found ${#pkg_files[@]} packages to add to the repo"
if (( ${#pkg_files[@]} )) ; then
    for pkg in "${pkg_files[@]}"; do
        add_to_repo "$REPO_DIR" "$pkg"
        # If we are building on/for x86_64, and the package is 'any', and if $REPO_DIR../{$ARM_ARCHS} exists, 
        # Distribute the new 'any' arcihtecture package to hose ARM repos as well so as to speed up CI builds.
        # This is the inverse of the above check for local builds, where we check if the package is already built for x86_64
        # and pull it from there if it exists
        if [ "$REPO_ARCH" = "x86_64" ] && [[ "$pkg" == *"-any.pkg.tar."* ]] ; then
            for arch in "${ARM_ARCHS[@]}" ; do
                if [ -d "$REPO_DIR/../$arch" ] ; then
                    # echo "##### Also distributing $pkg to $arch"
                    add_to_repo "$REPO_DIR/../$arch" "$pkg"
                fi
            done
        fi
        rm $pkg
    done
else
    echo "##### No *.pkg.tar.zst or *.pkg.tar.xz found"
    exit 1
fi

# If $LOCAL_PACMAN is defined, and $ONLINE_REPO_URI is not defined, update the system-wide packages.
# In the event that $ONLINE_REPO_URI is defined, pacman conf will be pointing to the online repo, 
# and the local $REPO_DIR will not be used for package search & installation, so there is no point in updating the system-wide packages
if [ -f "$LOCAL_PACMAN" ] && [ -z "$ONLINE_REPO_URI" ] ; then
        echo "##### Updating system-wide packages"
        sudo "$LOCAL_PACMAN" -Syy 
fi

echo "#####  Package successfully built and added to the local repo DBs"
