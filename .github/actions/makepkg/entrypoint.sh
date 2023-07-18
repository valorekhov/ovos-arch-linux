#!/usr/bin/env bash

# The why: makepkg requires to be run as an un-previleged user. ...even for a 'makepkg --printsrcinfo' operation.
# The `build` user created in this container may have a UID mismatch with the GHA host.
# GH Actions do not currently support supplying build-arg values to the container, which would be a traditional
# way to solve this problem.
# The majoirity of "Arch Makepkg" actions on the marketplace address this issue by a compbinaiton of
# messing with file permissions of the checked out repo, or by copying the repo to a new location.
#
# In the alternate, We shall attempt to re-create the "user-ns keepId" behaviour here:
# 1. compare the UID of the `build` user in the container with the effective permissions of the WORKDIR
# 2. in the case of a mismatch, sudo-provision a new user with the same UID as the WORKDIR's owning UID
# 3. run the following 'makefile' and 'repo' operations as the new user.

# base directory
BASEDIR=$(pwd)

# to support local dev, checking here if PWD contains .github/actions, 
# if so, setting BASEDIR to the parent of the .github directory
if [[ "$BASEDIR" == *".github/actions"* ]]; then
    BASEDIR="$(dirname $(dirname "$(dirname "$(pwd)")"))"
fi

# working directory
WORKDIR="$BASEDIR/${INPUT_WORKING_DIR}"

echo "Base directory: $BASEDIR"
echo "Working directory: $WORKDIR"

ensure_user_ns(){
    local script_to_run="$1"

    REPO_UID=$(stat -c %u "$WORKDIR")
    echo "Repo UID: $REPO_UID vs Container UID: $UID"
    # if the UID of the repo is not the same as the UID of the container, then we need to provision a new user, unless the UID is 0 (root)

    if [ "$REPO_UID" != "$UID" ] && [ "$REPO_UID" -gt 999 ] && [ "$REPO_UID" -lt 65000 ] ; then
        echo "UID mismatch detected. Provisioning new user with UID: $REPO_UID"
        sudo useradd -u "$REPO_UID" build-gha
        
        # run the script as the new user, while passing down the environment variables
        sudo -E -u build-gha bash -c "$script_to_run $WORKDIR"
    else
        echo "UID match detected. Running script as current user."
        bash -c "$script_to_run $WORKDIR"
    fi
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#id
#ls -la

# $INPUT_PACKAGES is supplied as either a space-separated string or a JSON-encoded array
# if it is a JSON-encoded array, then we need to decode it
if [[ "$INPUT_PACKAGES" == "["* ]]; then
    INPUT_PACKAGES=$(echo "$INPUT_PACKAGES" | jq -r '.[]')
fi

echo "Operation: $INPUT_OPERATION RebuildAll: $INPUT_REBUILDALL Packages: $INPUT_PACKAGES"
case "$INPUT_OPERATION" in
    "makefile-update")
        ensure_user_ns "$SCRIPT_DIR/makefile-update.sh"
        ;;
    "repo-build")
        ensure_user_ns "$SCRIPT_DIR/repo-build.sh"
        ;;
    *)
        echo "Invalid operation: $INPUT_OPERATION"
        exit 1
        ;;
esac
