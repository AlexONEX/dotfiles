#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Backing up package lists..."

# Get all packages
pacman -Qqen > "$SCRIPT_DIR/pkglist.txt"
pacman -Qqem > "$SCRIPT_DIR/aurlist.txt"

# Classify
OFFICIAL="$SCRIPT_DIR/pkglist-official.txt"
ARCO="$SCRIPT_DIR/pkglist-arcolinux.txt"
AUR="$SCRIPT_DIR/aurlist-classified.txt"

> "$OFFICIAL" > "$ARCO" > "$AUR"

# Classify pkglist.txt
while IFS= read -r pkg; do
    if [[ "$pkg" =~ ^arco ]]; then
        # ArcoLinux repo
        echo "$pkg" >> "$ARCO"
    elif pacman -Sp "$pkg" &>/dev/null; then
        # Can download from sync repos (official Arch)
        echo "$pkg" >> "$OFFICIAL"
    else
        # Not in official repos (AUR or unavailable)
        echo "$pkg" >> "$AUR"
    fi
done < "$SCRIPT_DIR/pkglist.txt"

# Add packages from aurlist.txt
cat "$SCRIPT_DIR/aurlist.txt" >> "$AUR"
sort -u "$AUR" -o "$AUR"

echo "✓ Official: $(wc -l < "$OFFICIAL"), ArcoLinux: $(wc -l < "$ARCO"), AUR: $(wc -l < "$AUR")"
