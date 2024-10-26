#!/bin/bash

# Source the config file to get the FILES array
source "$(dirname "$0")/../dotfiles_config.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Dotfiles repository path
DOTFILES_DIR="$HOME/dotfiles"

# Function to sync a single file/directory
sync_file() {
  local source="$HOME/$1"
  local target="$DOTFILES_DIR/$1"
  local target_dir=$(dirname "$target")

  # Check if source exists
  if [ ! -e "$source" ]; then
    echo -e "${RED}Warning: Source $source does not exist${NC}"
    return 1
  fi

  # Create target directory if it doesn't exist
  mkdir -p "$target_dir"

  # Sync the file/directory
  if [ -d "$source" ]; then
    # For directories, use rsync to copy
    rsync -av --delete "$source/" "$target/"
  else
    # For files, use cp to copy
    cp -f "$source" "$target"
  fi

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Synced: $1${NC}"
  else
    echo -e "${RED}Failed to sync: $1${NC}"
  fi
}

# Main sync function
main() {
  echo "Starting dotfiles sync..."

  # Check if dotfiles directory exists
  if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${RED}Error: Dotfiles directory not found at $DOTFILES_DIR${NC}"
    exit 1
  fi

  # Sync each file/directory in the FILES array
  for file in "${FILES[@]}"; do
    sync_file "$file"
  done

  # Change to dotfiles directory for git operations
  cd "$DOTFILES_DIR" || exit 1

  # Check if there are any changes to commit
  if [[ -n $(git status -s) ]]; then
    echo "Changes detected, creating commit..."
    git add .
    git commit -m "Update dotfiles: $(date +%Y-%m-%d)"
    echo -e "${GREEN}Changes committed successfully${NC}"
  else
    echo -e "${GREEN}No changes to commit${NC}"
  fi
}

# Run the main function
main
