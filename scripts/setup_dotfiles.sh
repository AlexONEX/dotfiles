#!/bin/bash

source ~/dotfiles/dotfiles_config.sh
DOTFILES_DIR="$HOME/dotfiles"

create_symlink() {
    local source="$DOTFILES_DIR/$1"
    local target="$HOME/$1"

    mkdir -p "$(dirname "$target")"

    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
        echo "Eliminado $target existente"
    fi

    ln -s "$source" "$target"
    echo "Created symlink: $target -> $source"
}

for file in "${FILES[@]}"; do
    create_symlink "$file"
done

echo "Dotfile config setup up complete"
