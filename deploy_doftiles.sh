#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

# Clonar el repositorio si no existe
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone https://github.com/tu_usuario/dotfiles.git "$DOTFILES_DIR"
else
  cd "$DOTFILES_DIR" && git pull origin main
fi

# Función para desplegar un archivo o directorio
deploy_file() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$1"
  mkdir -p "$(dirname "$dest")"
  rsync -av "$src" "$dest"
}

# Lista de archivos y directorios para desplegar
files=(
  ".zshrc"
  ".zsh/aliases.zsh"
  ".config/alacritty"
  ".config/easyeffects"
  ".config/i3"
  ".config/flameshot"
  ".config/polybar"
  ".config/tmux/tmux.conf"
  ".config/zathura"
  ".config/nvim/lua/custom"
)

# Desplegar archivos
for file in "${files[@]}"; do
  deploy_file "$file"
done

echo "Dotfiles desplegados con éxito!"
