ARG REPO=library 
# ARG ARCH_SUFFIX # Used for local builds with a formats of '-x86_64' or '-aarch64'
ARG ARCH_SUFFIX
ARG LABEL=base-devel

FROM $REPO/archlinux$ARCH_SUFFIX:$LABEL

# Install dependencies
RUN pacman -Syu --needed --noconfirm pacman-contrib namcap git arch-install-scripts jq wget \
    # && (pacman -S --noconfirm archlinuxarm-keyring || true) \ # archlinuxarm-keyring is already added by ARM base-devel images in the GHCR
    && rm -rf rootfs/var/lib/pacman/sync/* # Clean up pacman cache to save on image size

COPY *.sh /usr/local/bin/
    
# Setup user
RUN useradd -m build \
    && echo 'build ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build \
    && echo 'build-gha ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build-gha \
    && mkdir -p /build && chown build:build /build \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen \
    && printf "\nPKGEXT='.pkg.tar.zst'\n" >> /etc/makepkg.conf

WORKDIR /build
USER build

RUN mkdir /home/build/.gnupg && \
    touch /home/build/.gnupg/gpg.conf && \
    echo "keyserver-options auto-key-retrieve" > /home/build/.gnupg/gpg.conf

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]