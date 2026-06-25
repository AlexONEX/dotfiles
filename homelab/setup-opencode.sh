#!/bin/bash
# =============================================================================
# OpenCode Skills Setup - Homelab
# =============================================================================
# Sets up symlinks in ~/.config/opencode/skills for homelab environment
# Includes all shared skills + homelab-specific skills (manage-server)
# Usage: bash ~/Github/dotfiles/homelab/setup-opencode.sh
# =============================================================================

set -e

SKILLS_DIR="$HOME/.config/opencode/skills"
SHARED_SKILLS="$HOME/Github/dotfiles/shared/opencode-skills"
HOMELAB_SKILLS="$HOME/Github/dotfiles/homelab/opencode-skills"

echo "🔧 Setting up OpenCode skills for homelab..."
echo ""

# Check if dotfiles exist
if [ ! -d "$SHARED_SKILLS" ]; then
    echo "❌ Error: shared skills not found at $SHARED_SKILLS"
    exit 1
fi

if [ ! -d "$HOMELAB_SKILLS" ]; then
    echo "❌ Error: homelab skills not found at $HOMELAB_SKILLS"
    exit 1
fi

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

# Remove old/broken symlinks
cd "$SKILLS_DIR"
find . -maxdepth 1 -type l -delete 2>/dev/null || true
echo "✓ Cleaned old symlinks"

# Create symlinks for shared skills
for skill in assistant executive secretary prototype setup-matt-pocock-skills \
             tdd to-issues to-prd triage diagnose grill-with-docs \
             improve-codebase-architecture zoom-out; do
    ln -s "$SHARED_SKILLS/$skill" . && echo "  ✓ $skill"
done

# Create symlink for homelab-specific skill
ln -s "$HOMELAB_SKILLS/manage-server" . && echo "  ✓ manage-server (homelab)"

# Symlink supporting files
ln -s "$SHARED_SKILLS/README.md" . && echo "  ✓ README.md"
ln -s "$SHARED_SKILLS/init-secretary.sh" . && echo "  ✓ init-secretary.sh"

echo ""
echo "✅ Homelab OpenCode skills setup complete!"
echo "   Skills directory: $SKILLS_DIR"
echo "   Total skills: $(ls -d */ 2>/dev/null | wc -l)"
