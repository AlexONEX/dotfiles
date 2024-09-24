#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

source "$DOTFILES_DIR/dotfiles_config.sh"

copy_file() {
  local src="$HOME/$1"
  local dest="$DOTFILES_DIR/$1"
  mkdir -p "$(dirname "$dest")"
  rsync -av --delete "$src" "$dest"
}

compress_images() {
  local dir="$DOTFILES_DIR/.local/share/wallpapers"
  if [ -d "$dir" ]; then
    find "$dir" -type f \( -name "*.jpg" -o -name "*.png" \) -print0 |
    while IFS= read -r -d '' file; do
      if git diff --quiet -- "$file"; then
        continue  # Skip if no changes
      fi
      echo "Compressing $file"
      if [[ "$file" == *.jpg ]]; then
        jpegoptim --strip-all --all-progressive "$file"
      elif [[ "$file" == *.png ]]; then
        optipng -o5 "$file"
      fi
    done
  fi
}

# Copy files
for file in "${FILES[@]}"; do
  copy_file "$file"
done

# Compress images if there are changes
compress_images

# Commit and push changes
cd "$DOTFILES_DIR" || exit
git add .
if ! git diff --quiet || ! git diff --staged --quiet; then
  commit_message="Updating dotfiles: $(date +"%Y-%m-%d %H:%M:%S")"
  git commit -m "$commit_message"
  git push origin main
else
  echo "No changes to commit."
fi
