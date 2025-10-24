#!/bin/bash
# Install packages and deploy dotfiles with stow
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

echo -e "${BLUE}==> Detected OS: $OS${NC}"

# Install packages based on OS
install_packages() {
    case $OS in
        arch)
            echo -e "${BLUE}==> Installing packages on Arch Linux${NC}"
            sudo pacman -Syu --needed --noconfirm \
                git stow zsh curl vim tmux ripgrep aerc \
                base-devel python-pip
            ;;
        debian)
            echo -e "${BLUE}==> Installing packages on Debian/Ubuntu${NC}"
            sudo apt update
            sudo apt install -y \
                git stow zsh curl vim tmux ripgrep aerc \
                build-essential python3-pip
            ;;
        macos)
            echo -e "${BLUE}==> Installing packages on macOS${NC}"
            if ! command -v brew &> /dev/null; then
                echo -e "${RED}Homebrew not found. Please install it first:${NC}"
                echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi
            brew update
            brew install git stow zsh curl vim tmux ripgrep aerc coreutils python3
            ;;
        *)
            echo -e "${RED}Unsupported OS${NC}"
            exit 1
            ;;
    esac
}

# Create necessary directories
create_directories() {
    echo -e "${BLUE}==> Creating necessary directories${NC}"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.config/aerc"
    mkdir -p "$HOME/.local"
    mkdir -p "$HOME/.local/bin"
}

# Deploy dotfiles with stow
deploy_dotfiles() {
    echo -e "${BLUE}==> Deploying dotfiles with stow${NC}"
    cd "$DOTFILES_DIR"
    stow --target="$HOME" --restow --verbose=2 .
}

# Main
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Dotfiles Installation Script       ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""

    # Ask for confirmation unless -y flag is passed
    if [[ "$1" != "-y" && "$1" != "--yes" ]]; then
        echo -e "${YELLOW}This script will:${NC}"
        echo "  1. Install packages (git, stow, zsh, vim, tmux, etc.)"
        echo "  2. Create necessary directories"
        echo "  3. Deploy dotfiles with stow"
        echo ""
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    fi

    install_packages
    create_directories
    deploy_dotfiles

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Installation Complete! 🎉           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Change shell: chsh -s \$(which zsh)"
    echo "  2. Restart your terminal"
}

main "$@"
