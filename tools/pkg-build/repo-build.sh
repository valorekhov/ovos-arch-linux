REPO_DIR=$1
REPO_NAME="ovos-arch"
LOCAL_PACMAN=${2:-"$REPO_DIR/../pacman-wrapper-$(uname -m).sh"}
REPO_DB_FILE="$REPO_DIR/${3:-$REPO_NAME.db.tar.gz}"

PKGVER=$(grep -m1 "pkgver =" ".SRCINFO" | sed 's/.*pkgver = //g')
PKGREL=$(grep -m1 "pkgrel =" ".SRCINFO" | sed 's/.*pkgrel = //g')
PKG_NAMES=$(grep "pkgname =" ".SRCINFO" | sed 's/pkgname = //g')
PKG_ARCH=$(grep "arch =" ".SRCINFO" | sed 's/arch = //g')

echo "$PKG_NAMES"

DO_BUILD=false
if test -f "$REPO_DB_FILE" ; then
    for PKGNAME in $PKG_NAMES; do
        echo "##### Checking if $PKGNAME-$PKGVER-$PKGREL is in the DB: $REPO_DB_FILE"
        
        if tar -tf "$REPO_DB_FILE" | grep -m1 -F "$PKGNAME-$PKGVER-$PKGREL" ; then
            echo " ...... $PKGNAME-$PKGVER-$PKGREL exists in the DB"
        else
            echo " ...... $PKGNAME-$PKGVER-$PKGREL is not found. Will rebuild the entire (split) package."
            DO_BUILD=true
        fi
        echo "DO_BUILD=$DO_BUILD"
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

    PACMAN="$LOCAL_PACMAN" makepkg --syncdeps --noconfirm --force || exit 13

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
