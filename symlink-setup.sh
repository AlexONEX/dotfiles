#!/bin/bash
# =============================================================================
# Restore dotfiles via symlinks — multi-machine aware
# Run: bash symlink-setup.sh
# =============================================================================

set -e
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# ─── Detect machine ────────────────────────────────────────────────────────────
detect_machine() {
  case "$(uname)" in
    Darwin) echo "workstation" ;;
    Linux)  echo "homelab" ;;
    *)      echo "unknown" ;;
  esac
}
MACHINE=$(detect_machine)
echo "🔧 Installing for: $MACHINE (from $DOTFILES)"

# =============================================================================
# [SHARED] — Installed on ALL machines
# =============================================================================

echo "  ── shared/ ──"

# DOTFILES env var convention ($HOME/.dotfiles)
[ -L ~/.dotfiles ] && rm -f ~/.dotfiles
ln -sf "$DOTFILES" ~/.dotfiles

# Zsh
ln -sf "$DOTFILES/shared/.zshrc"  ~/.zshrc
ln -sf "$DOTFILES/shared/.zshenv" ~/.zshenv

# Bash (used on Linux homelab server)
ln -sf "$DOTFILES/shared/.bash_aliases" ~/.bash_aliases

# Config dirs (nvim, tmux, alacritty, zathura)
for cfg in nvim tmux alacritty zathura; do
  target="$HOME/.config/$cfg"
  [ -d "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
  ln -sfn "$DOTFILES/shared/.config/$cfg" "$target"
done

# Git
ln -sf "$DOTFILES/shared/.gitconfig" ~/.gitconfig

# Zsh plugins dir
target="$HOME/.zsh"
[ -d "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
ln -sfn "$DOTFILES/shared/.zsh" "$target"

# Local bin scripts
mkdir -p ~/.local
target="$HOME/.local/bin"
[ -d "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
ln -sfn "$DOTFILES/shared/.local/bin" "$target"

# Stow config
ln -sf "$DOTFILES/shared/.stow-local-ignore" ~/.stow-local-ignore

# =============================================================================
# [WORKSTATION ONLY] — Mac with AI agentic stack
# =============================================================================

if [[ "$MACHINE" == "workstation" ]]; then

  echo "  ── workstation/ ──"

  # ─── OpenCode ──────────────────────────────────────────────────────────────
  mkdir -p ~/.config/opencode/agent ~/.config/opencode/skills

  ln -sf "$DOTFILES/workstation/opencode-config/opencode.json" ~/.config/opencode/opencode.json

  for f in "$DOTFILES/workstation/opencode-config/agent/"*.md; do
    [ -f "$f" ] && ln -sf "$f" ~/.config/opencode/agent/$(basename "$f")
  done

  for skill_dir in "$DOTFILES/workstation/opencode-config/skills/"*/; do
    skill=$(basename "$skill_dir")
    target="$HOME/.config/opencode/skills/$skill"
    [ -d "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
    ln -sfn "$skill_dir" "$target"
  done

  ln -sf "$DOTFILES/workstation/opencode-config/skills/init-secretary.sh" ~/.config/opencode/skills/init-secretary.sh
  ln -sf "$DOTFILES/workstation/opencode-config/skills/README.md" ~/.config/opencode/skills/README.md

  # ─── Meridian ──────────────────────────────────────────────────────────────
  mkdir -p ~/.config/meridian
  [ -f ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
  [ -L ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
  sed "s|\$HOME|$HOME|g" "$DOTFILES/workstation/meridian-config/profiles.json.tpl" > ~/.config/meridian/profiles.json
  ln -sf "$DOTFILES/workstation/meridian-config/settings.json" ~/.config/meridian/settings.json

  # ─── Work Skills (Allaria infra) ────────────────────────────────────────────
  mkdir -p ~/.agents/skills/allaria
  target="$HOME/.agents/skills/allaria/infra-allaria-skill"
  [ -d "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
  ln -sfn "$DOTFILES/workstation/opencode-skills/allaria/infra-allaria-skill" "$target"

  # ─── Claude Profiles ────────────────────────────────────────────────────────
  CLAUDE_PROFILES_DIR="$HOME/.config/claude-profiles"
  mkdir -p "$CLAUDE_PROFILES_DIR"

  cp "$DOTFILES/workstation/claude-config/switch-profile.sh" "$CLAUDE_PROFILES_DIR/switch-profile.sh"
  cp "$DOTFILES/workstation/claude-config/context-bar.sh"    "$CLAUDE_PROFILES_DIR/context-bar.sh"
  cp "$DOTFILES/workstation/claude-config/status.sh"         "$CLAUDE_PROFILES_DIR/status.sh"
  cp "$DOTFILES/workstation/claude-config/completion.zsh"    "$CLAUDE_PROFILES_DIR/completion.zsh"

  sed "s|\$HOME|$HOME|g" "$DOTFILES/workstation/claude-config/profiles.json.tpl" > "$CLAUDE_PROFILES_DIR/profiles.json"

  # Claude profile dirs & settings
  mkdir -p ~/.claude
  ln -sf "$DOTFILES/workstation/claude-config/settings.json" ~/.claude/settings.json

  mkdir -p ~/.claude-allaria
  ln -sf "$DOTFILES/workstation/claude-config/allaria.settings.json" ~/.claude-allaria/settings.json

  mkdir -p ~/.claude-alma
  ln -sf "$DOTFILES/workstation/claude-config/alma.settings.json" ~/.claude-alma/settings.json

fi

# =============================================================================
# [HOMELAB ONLY] — Debian server specific
# =============================================================================

if [[ "$MACHINE" == "homelab" ]]; then
  echo "  ── homelab/ ──"
  # Add homelab-specific symlinks here as needed
  # (nothing yet — shared/ covers zsh, git, nvim, tmux for SSH use)
fi

echo ""
echo "✅ Done! ($MACHINE)"
echo ""
