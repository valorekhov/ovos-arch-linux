# Wraps build in system pacman in order to be able to override the config path
# Intended to be used with makepkg, which does not expose this option

# Usage: pacman-wrapper.sh [command]

pacman --config "/etc/pacman.conf" "$@"