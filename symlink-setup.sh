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
echo "Installing for: $MACHINE (from $DOTFILES)"

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
# [OPENSKILLS SHARED] — Skills instalados en TODAS las máquinas
# =============================================================================

link_openskill() {
  local skill_name="$1"
  local skill_path="$2"
  local target="$HOME/.config/opencode/skills/$skill_name"
  [ -d "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$skill_path" "$target"
}

echo "  ── openskills (shared) ──"
mkdir -p ~/.config/opencode/skills

for skill_dir in "$DOTFILES/shared/opencode-skills/"*/; do
  skill=$(basename "$skill_dir")
  link_openskill "$skill" "$skill_dir"
done

# Archivos sueltos (init-secretary.sh, README.md)
for f in "$DOTFILES/shared/opencode-skills/"*.sh "$DOTFILES/shared/opencode-skills/"*.md; do
  [ -f "$f" ] && ln -sf "$f" ~/.config/opencode/skills/$(basename "$f")
done

# =============================================================================
# [MACHINE-SPECIFIC OPENSKILLS] — Dependen de la máquina
# =============================================================================

if [[ "$MACHINE" == "workstation" ]]; then
  echo "  ── openskills (workstation) ──"
  for skill_dir in "$DOTFILES/workstation/opencode-skills/"*/; do
    skill=$(basename "$skill_dir")
    link_openskill "$skill" "$skill_dir"
  done
  # java-quarkus está en un subdirectorio
  for skill_dir in "$DOTFILES/workstation/opencode-skills/java-quarkus/"*/; do
    skill=$(basename "$skill_dir")
    link_openskill "$skill" "$skill_dir"
  done
fi

if [[ "$MACHINE" == "homelab" ]]; then
  echo "  ── openskills (homelab) ──"
  for skill_dir in "$DOTFILES/homelab/opencode-skills/"*/; do
    skill=$(basename "$skill_dir")
    link_openskill "$skill" "$skill_dir"
  done
fi

# =============================================================================
# [WORKSTATION ONLY] — Mac with AI agentic stack
# =============================================================================

if [[ "$MACHINE" == "workstation" ]]; then

  echo "  ── workstation/ ──"

  # ─── OpenCode config ──────────────────────────────────────────────────────
  mkdir -p ~/.config/opencode/agent
  ln -sf "$DOTFILES/workstation/opencode-config/opencode.json" ~/.config/opencode/opencode.json
  ln -sf "$DOTFILES/shared/opencode-config/ponytail"           ~/.config/opencode/ponytail

  for f in "$DOTFILES/workstation/opencode-config/agent/"*.md; do
    [ -f "$f" ] && ln -sf "$f" ~/.config/opencode/agent/$(basename "$f")
  done

  # ─── Meridian ──────────────────────────────────────────────────────────────
  mkdir -p ~/.config/meridian
  [ -f ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
  [ -L ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
  sed "s|\$HOME|$HOME|g" "$DOTFILES/workstation/meridian-config/profiles.json.tpl" > ~/.config/meridian/profiles.json
  ln -sf "$DOTFILES/workstation/meridian-config/settings.json" ~/.config/meridian/settings.json

  # ─── Meridian token refresh launch agent ────────────────────────────────
  mkdir -p ~/Library/LaunchAgents
  ln -sf "$DOTFILES/workstation/meridian-config/com.rynfar.meridian-refresh-all.plist" \
         ~/Library/LaunchAgents/com.rynfar.meridian-refresh-all.plist
  launchctl unload ~/Library/LaunchAgents/com.rynfar.meridian-refresh-all.plist 2>/dev/null
  launchctl load   ~/Library/LaunchAgents/com.rynfar.meridian-refresh-all.plist

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

  mkdir -p ~/.claude-alma
  ln -sf "$DOTFILES/workstation/claude-config/alma.settings.json" ~/.claude-alma/settings.json

fi

# =============================================================================
# [HOMELAB ONLY] — Debian server specific
# =============================================================================

if [[ "$MACHINE" == "homelab" ]]; then
  echo "  ── homelab/ ──"

  # ─── OpenCode config (sin MCPs) ──────────────────────────────────────────
  mkdir -p ~/.config/opencode/agent
  ln -sf "$DOTFILES/homelab/opencode-config/opencode.json" ~/.config/opencode/opencode.json
  ln -sf "$DOTFILES/shared/opencode-config/ponytail"       ~/.config/opencode/ponytail

  # ─── Meridian ──────────────────────────────────────────────────────────────
  mkdir -p ~/.config/meridian
  [ -f ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
  [ -L ~/.config/meridian/profiles.json ] && rm -f ~/.config/meridian/profiles.json
  sed "s|\$HOME|$HOME|g" "$DOTFILES/workstation/meridian-config/profiles.json.tpl" > ~/.config/meridian/profiles.json
  ln -sf "$DOTFILES/workstation/meridian-config/settings.json" ~/.config/meridian/settings.json

fi

echo ""
echo "Done! ($MACHINE)"
echo ""
