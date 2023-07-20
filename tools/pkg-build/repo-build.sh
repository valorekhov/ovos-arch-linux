REPO_DIR=${1%/}
REPO_ARCH=$(basename "$REPO_DIR")
REPO_NAME="ovos-arch"
LOCAL_PACMAN=${2:-"$REPO_DIR/../pacman-wrapper-$(uname -m).sh"}
REPO_DB_FILE="$REPO_DIR/${3:-$REPO_NAME.db.tar.gz}"

PKGVER=$(grep -m1 "pkgver =" ".SRCINFO" | sed 's/.*pkgver = //g')
PKGREL=$(grep -m1 "pkgrel =" ".SRCINFO" | sed 's/.*pkgrel = //g')
PKG_NAMES=$(grep "pkgname =" ".SRCINFO" | sed 's/pkgname = //g')
PKG_ARCH=$(grep "arch =" ".SRCINFO" | sed 's/arch = //g')
PKG_BASE=$(grep "pkgbase =" ".SRCINFO" | sed 's/pkgbase = //g')

echo "$PKG_NAMES"

DO_BUILD=false
if test -f "$REPO_DB_FILE" ; then
    for PKGNAME in $PKG_NAMES; do
        echo "##### Checking if $PKGNAME-$PKGVER-$PKGREL is in the $REPO_ARCH repo"
        
        if tar -tf "$REPO_DB_FILE" | grep -m1 -qF "$PKGNAME-$PKGVER-$PKGREL" ; then
            echo " ...... $PKGNAME-$PKGVER-$PKGREL exists in the DB"
        else
            echo " ...... $PKGNAME-$PKGVER-$PKGREL is not found. Will rebuild the entire (split) package."
            DO_BUILD=true
        fi
        # echo "DO_BUILD=$DO_BUILD"
    done
else
    echo "##### No DB file NOT found: $REPO_DB_FILE"
    DO_BUILD=true
fi

if $DO_BUILD ; then
    # if PKG_ARCH array does not contain the current architecture or 'any', skip the build
    if ! echo "$PKG_ARCH" | grep -qE "(any|$(uname -m))" ; then
        echo "##### Skipping build for $(uname -m) as arch is not supported"
        exit 0
    fi

    # If REPO_ARCH is not x86_64, AND the package arch is 'any', AND we are not building a split package (PKG_NAMES length is 1)
    # check if the package is already built for x86_64, in which case we can copy it here and skip the build

    if [ "$REPO_ARCH" != "x86_64" ] && [ $(echo "$PKG_NAMES" | wc -w) -eq 1 ] && [ -f "$REPO_DIR/../x86_64/$PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{zst,xz}" ] ; then
        echo " ...... $PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{zst,xz} exists in the x86_64 repo. Copying it here and skipping the build"
        cp "$REPO_DIR/../x86_64/$PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{zst,xz}" "$REPO_DIR/"
        cp "$REPO_DIR/../x86_64/$PKG_NAMES-$PKGVER-$PKGREL.any.pkg.tar.{xst,xz}.sig" "$REPO_DIR/" || true
    else
        MAKEFLAGS="-j$(nproc)" PACMAN="$LOCAL_PACMAN" makepkg --syncdeps --noconfirm --force || exit 13
    fi

    zst_files=( *.pkg.tar.zst )
    xz_files=( *.pkg.tar.xz )
    if (( ${#zst_files[@]} )) ; then
        cp *.pkg.tar.{zst,zst.sig} $REPO_DIR || true
        for pkg in *.pkg.tar.zst; do
            echo "##### Adding $pkg to the DB: $REPO_DB_FILE"
            repo-add "$REPO_DB_FILE" "$REPO_DIR/$pkg"
            rm $pkg
        done
    elif (( ${#xz_files[@]} )) ; then
        cp *.pkg.tar.{xz,xz.sig} $REPO_DIR || true
        for pkg in *.pkg.tar.zst; do
            echo "##### Adding $pkg to the DB: $REPO_DB_FILE"
            repo-add "$REPO_DB_FILE" "$REPO_DIR/$pkg"
            rm $pkg
        done
    else
        echo "##### No *.pkg.tar.zst or *.pkg.tar.xz found"
        exit 1
    fi


    if test -f "$LOCAL_PACMAN" ; then
            echo "##### Updating system-wide packages"
            sudo "$LOCAL_PACMAN" -Syy 
    fi

    echo "#####  Package successfully built and added to the repo"
else
    echo "#####  Nothing to do"
fi
