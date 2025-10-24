#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ $EUID -eq 0 ]] && SUDO="" || SUDO="sudo"

echo "==> Restoring packages..."

# Update
$SUDO pacman -Syu --noconfirm

# Official packages
OFFICIAL="${SCRIPT_DIR}/pkglist-official.txt"
[[ -f "$OFFICIAL" ]] || OFFICIAL="${SCRIPT_DIR}/pkglist.txt"
echo "==> Installing $(wc -l < "$OFFICIAL") official packages..."
$SUDO pacman -S --needed --noconfirm - < "$OFFICIAL"

# Install AUR helper if not present
if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
    echo ""
    echo "==> Installing paru (AUR helper)..."

    # Install build dependencies
    $SUDO pacman -S --needed --noconfirm base-devel git

    # Clone and build paru (requires non-root user)
    if [[ $EUID -eq 0 ]]; then
        echo "Warning: Running as root, skipping paru installation (AUR packages must be built by non-root user)"
        echo "Install paru manually after first boot, then run: paru -S --needed - < ~/.dotfiles/arch/aurlist.txt"
    else
        cd /tmp
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ~
        rm -rf /tmp/paru
    fi
fi

# Determine which AUR helper to use
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
elif command -v yay &> /dev/null; then
    AUR_HELPER="yay"
else
    echo "Warning: No AUR helper found, skipping AUR packages"
    exit 0
fi

# Install AUR packages
echo ""
echo "==> Installing AUR packages ($(wc -l < "$SCRIPT_DIR/aurlist.txt") packages)..."
$AUR_HELPER -S --needed --noconfirm - < "$SCRIPT_DIR/aurlist.txt"

echo ""
echo "==> Package restoration complete!"
echo ""
echo "Next steps:"
echo "  1. Deploy dotfiles: cd ~/.dotfiles && ./install.sh"
echo "  2. Fix Proton Bridge: systemctl --user mask 'app-Proton\x20Mail\x20Bridge@autostart.service'"
echo "  3. Enable services: systemctl --user enable --now protonmail-bridge aria2"
