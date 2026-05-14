#!/bin/bash
# =============================================================================
# Restore agentic config from dotfiles via symlinks
# Run: bash symlink-setup.sh
# =============================================================================

set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "🔗 Linking agentic configs from $DOTFILES"

# ─── OpenCode ────────────────────────────────────────────────────────────────
mkdir -p ~/.config/opencode/agent ~/.config/opencode/skills

ln -sf "$DOTFILES/opencode-config/opencode.json" ~/.config/opencode/opencode.json

for f in "$DOTFILES/opencode-config/agent/"*.md; do
  [ -f "$f" ] && ln -sf "$f" ~/.config/opencode/agent/$(basename "$f")
done

for skill_dir in "$DOTFILES/opencode-config/skills/"*/; do
  skill=$(basename "$skill_dir")
  target="$HOME/.config/opencode/skills/$skill"
  # Remove real dir so symlink can take its place
  [ -d "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
  ln -sfn "$skill_dir" "$target"
done

# Also symlink the init script
ln -sf "$DOTFILES/opencode-config/skills/init-secretary.sh" ~/.config/opencode/skills/init-secretary.sh
ln -sf "$DOTFILES/opencode-config/skills/README.md" ~/.config/opencode/skills/README.md

# ─── Meridian ────────────────────────────────────────────────────────────────
mkdir -p ~/.config/meridian
ln -sf "$DOTFILES/meridian-config/profiles.json" ~/.config/meridian/profiles.json
ln -sf "$DOTFILES/meridian-config/settings.json" ~/.config/meridian/settings.json

# ─── Claude ──────────────────────────────────────────────────────────────────
mkdir -p ~/.claude
ln -sf "$DOTFILES/claude-config/settings.json" ~/.claude/settings.json

echo ""
echo "✅ Done. Verify: ls -la ~/.config/opencode/opencode.json"
echo ""
