#!/bin/bash
set -e

docker run --rm -it \
    -v "$HOME/.dotfiles:/root/.dotfiles" \
    archlinux:latest \
    bash -c "
        # Run the new install.sh script
        /root/.dotfiles/install.sh -y
        echo ''
        echo '==> Test complete!'
        echo 'Installed packages:'
        pacman -Qq | wc -l
        echo ''
        echo 'Symlinks created:'
        ls -la /root | grep -E '^l' || echo 'No symlinks in home'
        echo ''
        ls -la /root/.config | head -10 || echo 'No .config directory'
    "
