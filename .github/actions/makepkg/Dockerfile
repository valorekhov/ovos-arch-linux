FROM archlinux:base-devel

# Install dependencies
RUN pacman -Syu --needed --noconfirm pacman-contrib namcap git

COPY *.sh /usr/local/bin/
    
# Setup user
RUN useradd -m build && \
    echo 'build ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
WORKDIR /home/build
USER build

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]