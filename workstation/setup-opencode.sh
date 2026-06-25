#!/bin/bash
# =============================================================================
# OpenCode Skills Setup - Workstation
# =============================================================================
# Sets up symlinks in ~/.config/opencode/skills for workstation environment
# Includes workstation-specific skills only
# Usage: bash ~/Github/dotfiles/workstation/setup-opencode.sh
# =============================================================================

set -e

SKILLS_DIR="$HOME/.config/opencode/skills"
WORKSTATION_SKILLS="$HOME/Github/dotfiles/workstation/opencode-skills"

echo "🔧 Setting up OpenCode skills for workstation..."
echo ""

# Check if workstation skills exist
if [ ! -d "$WORKSTATION_SKILLS" ]; then
    echo "❌ Error: workstation skills not found at $WORKSTATION_SKILLS"
    exit 1
fi

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

# Remove old/broken symlinks
cd "$SKILLS_DIR"
find . -maxdepth 1 -type l -delete 2>/dev/null || true
echo "✓ Cleaned old symlinks"

# Create symlinks for workstation skills
if [ "$(ls -A "$WORKSTATION_SKILLS")" ]; then
    for item in "$WORKSTATION_SKILLS"/*; do
        name=$(basename "$item")
        ln -s "$item" . && echo "  ✓ $name"
    done
else
    echo "⚠️  No skills found in workstation directory"
fi

echo ""
echo "✅ Workstation OpenCode skills setup complete!"
echo "   Skills directory: $SKILLS_DIR"
echo "   Total skills: $(ls -d */ 2>/dev/null | wc -l)"
