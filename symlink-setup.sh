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
# Remove old symlink/file so we can write fresh
[ -f ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
[ -L ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
sed "s|\$HOME|$HOME|g" "$DOTFILES/meridian-config/profiles.json.tpl" > ~/.config/meridian/profiles.json
ln -sf "$DOTFILES/meridian-config/settings.json" ~/.config/meridian/settings.json

# ─── OpenCode Agent Skills (Allaria infra) ────────────────────────────────────
mkdir -p ~/.agents/skills/allaria
# Remove real dir so symlink can take its place
[ -d ~/.agents/skills/allaria/infra-allaria-skill ] && [ ! -L ~/.agents/skills/allaria/infra-allaria-skill ] && rm -rf ~/.agents/skills/allaria/infra-allaria-skill
ln -sfn "$DOTFILES/opencode-skills/allaria/infra-allaria-skill" ~/.agents/skills/allaria/infra-allaria-skill

# ─── Claude Profiles ──────────────────────────────────────────────────────────
CLAUDE_PROFILES_DIR="$HOME/.config/claude-profiles"
mkdir -p "$CLAUDE_PROFILES_DIR"

# Copy profile scripts (so they work without dotfiles path)
cp "$DOTFILES/claude-config/switch-profile.sh" "$CLAUDE_PROFILES_DIR/switch-profile.sh"
cp "$DOTFILES/claude-config/context-bar.sh" "$CLAUDE_PROFILES_DIR/context-bar.sh"
cp "$DOTFILES/claude-config/status.sh" "$CLAUDE_PROFILES_DIR/status.sh"
cp "$DOTFILES/claude-config/completion.zsh" "$CLAUDE_PROFILES_DIR/completion.zsh"

# Generate profiles.json from template (resolves $HOME to actual path)
sed "s|\$HOME|$HOME|g" "$DOTFILES/claude-config/profiles.json.tpl" > "$CLAUDE_PROFILES_DIR/profiles.json"

# ─── Claude Profile Dirs & Settings ──────────────────────────────────────────
# personal
mkdir -p ~/.claude
ln -sf "$DOTFILES/claude-config/settings.json" ~/.claude/settings.json

# allaria
mkdir -p ~/.claude-allaria
ln -sf "$DOTFILES/claude-config/allaria.settings.json" ~/.claude-allaria/settings.json

# alma
mkdir -p ~/.claude-alma
ln -sf "$DOTFILES/claude-config/alma.settings.json" ~/.claude-alma/settings.json

echo ""
echo "✅ Done!"
echo "   Profiles: personal, allaria, alma"
echo "   Switch:   bash ~/.config/claude-profiles/switch-profile.sh <name>"
echo "   Verify:   ls -la ~/.claude ~/.claude-allaria ~/.claude-alma"
echo ""
