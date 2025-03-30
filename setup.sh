#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print formatted message
print_message() {
    echo -e "${GREEN}[DOTFILES]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to install Ansible
install_ansible() {
    print_message "Installing Ansible..."

    # Detect operating system
    if [ -f /etc/debian_version ]; then
        print_info "Detected Debian/Ubuntu system."
        sudo apt update && sudo apt install -y ansible
    elif [ -f /etc/fedora-release ]; then
        print_info "Detected Fedora system."
        sudo dnf install -y ansible
    elif [ -f /etc/arch-release ]; then
        print_info "Detected Arch Linux system."
        sudo pacman -S --noconfirm ansible
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_info "Detected macOS system."
        brew install ansible
    else
        print_error "Could not determine the operating system to install Ansible automatically."
        print_info "Please install Ansible manually and run this script again."
        exit 1
    fi

    # Install necessary collections
    print_message "Installing required Ansible collections..."
    ansible-galaxy collection install community.general
}

# Check if stow is installed
check_stow() {
    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow is not installed."
        print_info "Stow is required for managing symlinks."

        read -p "Would you like to install Stow now? (y/n): " install_choice
        if [[ $install_choice == "y" || $install_choice == "Y" ]]; then
            # Detect operating system
            if [ -f /etc/debian_version ]; then
                print_info "Installing Stow on Debian/Ubuntu..."
                sudo apt update && sudo apt install -y stow
            elif [ -f /etc/fedora-release ]; then
                print_info "Installing Stow on Fedora..."
                sudo dnf install -y stow
            elif [ -f /etc/arch-release ]; then
                print_info "Installing Stow on Arch Linux..."
                sudo pacman -S --noconfirm stow
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                print_info "Installing Stow on macOS..."
                brew install stow
            else
                print_error "Could not determine the operating system to install Stow automatically."
                print_info "Please install Stow manually and run this script again."
                exit 1
            fi
        else
            print_error "Stow installation was declined. Exiting."
            exit 1
        fi
    fi
}

# Check if Ansible is installed, install if not
if ! command -v ansible &> /dev/null; then
    print_error "Ansible is not installed."
    print_info "Ansible is required to continue."

    read -p "Would you like to install Ansible now? (y/n): " install_choice
    if [[ $install_choice == "y" || $install_choice == "Y" ]]; then
        install_ansible
    else
        print_error "Ansible installation was declined. Exiting."
        exit 1
    fi
fi

# Check if stow is installed for options that need it
case $option in
    1|2|3|5)
        check_stow
        ;;
esac

# Show available options
echo ""
echo -e "${GREEN}======= DOTFILES CONFIGURATION =======${NC}"
echo "1. Install everything (packages and symlinks)"
echo "2. Create symlinks only"
echo "3. Test setup (dry-run to check for potential conflicts)"
echo "4. Show available stow packages"
echo "5. Remove symlinks"
echo "6. Exit"

# Ask user for action
read -p "Select an option (1-6): " option

# Check if stow is installed for options that need it
case $option in
    1|2|3|5)
        check_stow
        ;;
esac

case $option in
    1)
        print_message "Installing packages and creating symlinks..."
        ansible-playbook bootstrap.yml --ask-become-pass
        ;;
    2)
        print_message "Creating symlinks..."
        ansible-playbook bootstrap.yml --tags symlink
        ;;
    3)
        print_message "Testing setup (checking for potential conflicts)..."
        ansible-playbook test-playbook.yml --ask-become-pass
        ;;
    4)
        print_message "Showing available stow packages..."
        ansible-playbook bootstrap.yml --tags info
        ;;
    5)
        print_message "Removing symlinks..."
        ansible-playbook bootstrap.yml --tags delete -e "delete_dotfiles=true"
        ;;
    6)
        print_message "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac

print_message "Process completed!"
