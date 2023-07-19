FROM archlinux:base-devel

# Install dependencies
RUN pacman -Syu --needed --noconfirm pacman-contrib namcap git arch-install-scripts jq

COPY *.sh /usr/local/bin/
    
# Setup user
RUN useradd -m build \
    && echo 'build ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build \
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