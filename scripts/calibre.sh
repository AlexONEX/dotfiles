#!/bin/bash

# Set variables
ONEDRIVE_PATH="/home/mars/OneDrive/Libraries/myLibrary"
CALIBRE_PATH="/home/mars/Calibre Library"

# Ensure the OneDrive directory exists
mkdir -p "$ONEDRIVE_PATH"

# Check if Calibre Library already exists
if [ -d "$CALIBRE_PATH" ]; then
  # If it exists and is not a symlink, move it to OneDrive
  if [ ! -L "$CALIBRE_PATH" ]; then
    echo "Moving existing Calibre Library to OneDrive..."
    mv "$CALIBRE_PATH" "$ONEDRIVE_PATH"
  else
    echo "Calibre Library is already a symlink. No action needed."
    exit 0
  fi
elif [ -L "$CALIBRE_PATH" ]; then
  echo "Removing existing symlink..."
  rm "$CALIBRE_PATH"
fi

# Create the symlink
echo "Creating symlink..."
ln -s "$ONEDRIVE_PATH" "$CALIBRE_PATH"

echo "Setup complete. Calibre Library is now linked to OneDrive."

# Adjust Calibre's library path if necessary
calibre-debug --with-library="$CALIBRE_PATH"

echo "Calibre library path updated."
