#!/bin/bash
# =============================================================================
# Claude Code MCP servers — reproducible setup (no secrets on disk)
# Run: bash setup-mcp.sh
#
# Claude stores user-scoped MCP in ~/.claude.json (machine state, not
# version-controlled), so this script is the canonical, re-runnable source.
# Mirrors the MCP servers configured for opencode (workstation/opencode-config).
# =============================================================================
set -e

GOG_ACCOUNT="${GOG_ACCOUNT:-alejandro.schwartzmann@almafintech.com.ar}"

echo "── Claude MCP setup ──"

# Jira — remote OAuth (authv2). No API token on disk; auth via `/mcp` in Claude.
claude mcp remove jira -s user 2>/dev/null || true
claude mcp add -s user -t http jira https://mcp.atlassian.com/v1/mcp/authv2
echo "  ✔ jira (remote OAuth) — run /mcp inside Claude to authenticate"

# gogcli — local stdio server (Homebrew: gogcli-mcp)
claude mcp remove gogcli -s user 2>/dev/null || true
claude mcp add gogcli -s user -e "GOG_ACCOUNT=$GOG_ACCOUNT" -- gogcli-mcp
echo "  ✔ gogcli (local stdio)"

echo ""
echo "Done. Verify with: claude mcp list"
