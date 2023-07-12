# Params: AUR_REPO_DIR - the directory to clone the AUR packages into
#          AUR_LOCK_FILE - the path to the aur.lock file

AUR_REPO_DIR=$1
AUR_LOCK_FILE=$2

# Enumerate aur.lock and clone all specified packages
# the format of aur.lock is:
#   <aur-package>:<commit>
#   <aur-package> is the name of the package in the AUR
# 	<commit> is the specficif version of the aur package to use, it is always required in order for the dependency to be pinned

echo "Cloning AUR packages to $AUR_REPO_DIR"
mkdir -p $AUR_REPO_DIR

while read -r line; do 
    printf "Processing $line\n"; 
    package=$(echo "$line" | cut -d: -f1); 
    commit=$(echo "$line" | cut -d: -f2); 

    # if commit is empty, skip this line
    if [ -z "$commit" ]; then 
        printf "Skipping $package due to missing commit\n"; 
        continue; 
    fi;

    printf "\n\n### Processing $package, $commit\n"

    mkdir -p "$AUR_REPO_DIR/$package" 
    pushd "$AUR_REPO_DIR/$package"
    # check if aur-$commit.tar.gz exists, if not download it
    if [ ! -f "aur-$commit.tar.gz" ]; then 
        printf "Downloading aur-$commit.tar.gz\n"; 
        wget https://aur.archlinux.org/cgit/aur.git/snapshot/aur-$commit.tar.gz
    fi;

    if [ ! -f "PKGBUILD" ]; then 
        # extract the tarball to the current directory
        printf "Extracting aur-$commit.tar.gz\n";
        tar -xvf aur-$commit.tar.gz -C . --strip-components=1
        # # check if the package name in PKGBUILD matches the $package, if not replace the line with our package name
        # if ! grep -q "pkgname=\"$package\"" PKGBUILD; then 
        #     printf "Replacing pkgname in PKGBUILD for $package\n"; 
        #     sed -i "s/pkgname=.*/pkgname=\"$package\"/" PKGBUILD; 
        # fi;
    fi;

    if [ ! -f ".SRCINFO" ]; then
        # generate the .SRCINFO file
        printf "Generating .SRCINFO\n"; 
        makepkg --printsrcinfo > .SRCINFO
    fi; 
    popd

        
done < $AUR_LOCK_FILE