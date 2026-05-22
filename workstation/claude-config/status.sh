#!/bin/bash
# =============================================================================
# status.sh — Show current Claude profile status
# =============================================================================

PROFILES_JSON="$HOME/.config/claude-profiles/profiles.json"
ACTIVE_PROFILE=""
ACTIVE_COLOR=""

# Check CLAUDE_CONFIG_DIR env var
if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
    # Figure out which profile this config dir corresponds to
    if [[ -f "$PROFILES_JSON" ]]; then
        ACTIVE_PROFILE=$(jq -r --arg d "$CLAUDE_CONFIG_DIR" '
            to_entries[] | select(.value.config_dir == $d) | .key
        ' "$PROFILES_JSON" 2>/dev/null)
    fi
fi

# Fallback: check .claude-profile marker
if [[ -z "$ACTIVE_PROFILE" || "$ACTIVE_PROFILE" == "null" ]]; then
    if [[ -f "$HOME/.claude-profile" ]]; then
        ACTIVE_PROFILE=$(cat "$HOME/.claude-profile")
    fi
fi

if [[ -z "$ACTIVE_PROFILE" || "$ACTIVE_PROFILE" == "null" ]]; then
    if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
        ACTIVE_PROFILE="custom ($CLAUDE_CONFIG_DIR)"
    else
        ACTIVE_PROFILE="default (~/.claude.json)"
    fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Profile Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ -f "$PROFILES_JSON" ]]; then
    jq -r --arg a "$ACTIVE_PROFILE" '
        to_entries[] |
        "  " + (if .key == $a then "▶" else " " end) + " \(.key)" +
        "  \(.value.emoji // "")" +
        "  \(.value.description // "")"
    ' "$PROFILES_JSON"
else
    echo "  Active: $ACTIVE_PROFILE"
fi

echo ""
echo "  CLAUDE_CONFIG_DIR=${CLAUDE_CONFIG_DIR:-"(not set)"}"
echo ""
  echo "  Commands:"
    echo "    claude-personal    → personal profile"
    echo "    claude-allaria     → Allaria profile"
    echo "    claude-alma        → Alma fintech profile"
    echo "    claude-use <name>  → switch to named profile"
    echo "    claude-profiles    → list all profiles"
