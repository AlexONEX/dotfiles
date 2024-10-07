bin/bash
DOTFILES_DIR="$HOME/dotfiles"
source "$DOTFILES_DIR/dotfiles_config.sh"

create_symlink() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$1"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    if [ "$(readlink -f "$dest")" = "$src" ]; then
      echo "Symlink ya existe y es correcto: $dest"
      return
    else
      rm "$dest"
    fi
  elif [ -e "$dest" ]; then
    echo "Haciendo backup de $dest a ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  ln -s "$src" "$dest"
  echo "Creado symlink: $dest -> $src"
}

setup_dotfiles() {
  for file in "${FILES[@]}"; do
    local src="$HOME/$file"
    local dest="$DOTFILES_DIR/$file"

    if [ -e "$src" ] && [ ! -L "$src" ]; then
      mkdir -p "$(dirname "$dest")"
      mv "$src" "$dest"
      echo "Movido $src a $dest"
    fi
  done

  for file in "${FILES[@]}"; do
    create_symlink "$file"
  done
}

compress_images() {
  local dir="$DOTFILES_DIR/.local/share/wallpapers"
  if [ -d "$dir" ]; then
    if ! git -C "$dir" diff --quiet; then
      echo "Cambios detectados en el directorio de wallpapers. Comprimiendo imágenes..."
      find "$dir" -type f \( -name "*.jpg" -o -name "*.png" \) -print0 |
      parallel -0 -j+0 '
        echo "Comprimiendo {}"
        if [[ "{}" == *.jpg ]]; then
          jpegoptim --strip-all --all-progressive "{}"
        elif [[ "{}" == *.png ]]; then
          optipng -o5 "{}"
        fi
      '
      git -C "$dir" add .
      echo "Imágenes comprimidas añadidas a git."
    else
      echo "No hay cambios en el directorio de wallpapers. Saltando compresión."
    fi
  fi
}

setup_dotfiles
compress_images

cd "$DOTFILES_DIR" || exit
git add .
if ! git diff --quiet || ! git diff --staged --quiet; then
  commit_message="Actualizando dotfiles: $(date +"%Y-%m-%d %H:%M:%S")"
  git commit -m "$commit_message"
  git push origin main
else
  echo "No hay cambios para hacer commit."
fi
