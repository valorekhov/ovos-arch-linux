FROM archlinux:base-devel

# Install dependencies
RUN pacman -Syu --needed --noconfirm pacman-contrib namcap git

COPY entrypoint.sh /entrypoint.sh
    
# Setup user
RUN groupadd -g 123 gh && useradd -m build && usermod -a -G gh build && \
    echo 'build ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
WORKDIR /home/build
USER build

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]