#!/bin/bash
# =============================================================================
# switch-profile.sh — Switch Claude Code profiles
#
# Usage:
#   switch-profile.sh personal   → switches to personal account
#   switch-profile.sh allaria    → switches to Allaria account
#   switch-profile.sh alma       → switches to Alma fintech account
#   switch-profile.sh            → lists available profiles
# =============================================================================

PROFILES_JSON="$HOME/.config/claude-profiles/profiles.json"

if [[ ! -f "$PROFILES_JSON" ]]; then
    echo "Error: profiles.json not found at $PROFILES_JSON" >&2
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "Available Claude profiles:"
    echo ""
    jq -r '
        to_entries[] | 
        "  \(.key)" +
        "  [\(.value.color)]" +
        "  \(.value.emoji // "")" +
        "  \(.value.description // "")"
    ' "$PROFILES_JSON" | column -t -s ' '
    echo ""
    echo "Usage: claude-use <profile-name>"
    echo "   or:  claude-<profile-name>"
    exit 0
fi

PROFILE="$1"

# Validate profile exists
if ! jq -e --arg p "$PROFILE" '.[$p]' "$PROFILES_JSON" > /dev/null 2>&1; then
    echo "Error: Unknown profile '$PROFILE'" >&2
    echo "Available profiles:" >&2
    jq -r 'keys[] | "  - \(.)"' "$PROFILES_JSON" >&2
    exit 1
fi

CONFIG_DIR=$(jq -r --arg p "$PROFILE" '.[$p].config_dir' "$PROFILES_JSON")
LABEL=$(jq -r --arg p "$PROFILE" '.[$p].label' "$PROFILES_JSON")
DESC=$(jq -r --arg p "$PROFILE" '.[$p].description' "$PROFILES_JSON")

echo "🔄 Switching to Claude profile: $PROFILE ($DESC)"
echo "   Config dir: $CONFIG_DIR"

# Set the env var for the current shell and export
export CLAUDE_CONFIG_DIR="$CONFIG_DIR"

# Create/update the .claude-profile marker
mkdir -p "$CONFIG_DIR"
echo "$PROFILE" > "$CONFIG_DIR/.claude-profile" 2>/dev/null
echo "$PROFILE" > "$HOME/.claude-profile" 2>/dev/null

echo "✅ Profile '$LABEL' active. Run: claude"
echo ""
echo "   Or for a single command: CLAUDE_CONFIG_DIR=$CONFIG_DIR claude <cmd>"
