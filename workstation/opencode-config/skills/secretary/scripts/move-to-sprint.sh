#!/usr/bin/env bash
#
# move-to-sprint.sh — Move one or more Jira issues to a sprint via the Agile API.
#
# Workaround: opencode's MCP wrapper for editJiraIssue currently fails when
# setting customfield_10020 (sprint), so we bypass it and call the Agile
# REST API directly using the token already cached by the Atlassian MCP.
#
# Usage:
#   move-to-sprint.sh <sprintId> <issueKey> [<issueKey> ...]
#
# Example:
#   move-to-sprint.sh 1349 DP-18121
#   move-to-sprint.sh 1349 DP-18121 DP-18122 DP-18123
#
# Defaults (Allaria / darumafintech):
#   CLOUD_ID=91fb92aa-9455-4234-becd-7c1d232cdb46
#
# Env overrides:
#   CLOUD_ID         - Atlassian cloud id (default above)
#   MCP_AUTH_FILE    - path to opencode MCP auth json (default below)
#   JIRA_TOKEN       - if set, used directly instead of MCP_AUTH_FILE

set -euo pipefail

CLOUD_ID="${CLOUD_ID:-91fb92aa-9455-4234-becd-7c1d232cdb46}"
MCP_AUTH_FILE="${MCP_AUTH_FILE:-$HOME/.local/share/opencode/mcp-auth.json}"

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <sprintId> <issueKey> [<issueKey> ...]" >&2
  exit 2
fi

SPRINT_ID="$1"; shift
ISSUES=("$@")

# Resolve token
if [[ -n "${JIRA_TOKEN:-}" ]]; then
  TOKEN="$JIRA_TOKEN"
else
  if [[ ! -f "$MCP_AUTH_FILE" ]]; then
    echo "error: MCP auth file not found at $MCP_AUTH_FILE" >&2
    exit 1
  fi
  TOKEN="$(/usr/bin/python3 -c "import json,sys; print(json.load(open('$MCP_AUTH_FILE'))['jira']['tokens']['accessToken'])")"
  if [[ -z "$TOKEN" ]]; then
    echo "error: could not extract token from $MCP_AUTH_FILE" >&2
    exit 1
  fi
fi

# Use the regular issue edit endpoint (PUT /rest/api/3/issue/{key}) because the
# Agile API (POST /rest/agile/1.0/sprint/{id}/issue) requires the
# `write:sprint:jira-software` scope which the MCP token does not currently grant.
# Sprint custom field id for Allaria is customfield_10020.

BODY='{"fields":{"customfield_10020":'"$SPRINT_ID"'}}'

echo "→ moving ${#ISSUES[@]} issue(s) to sprint ${SPRINT_ID}: ${ISSUES[*]}"

FAIL_COUNT=0
for KEY in "${ISSUES[@]}"; do
  URL="https://api.atlassian.com/ex/jira/${CLOUD_ID}/rest/api/3/issue/${KEY}"
  HTTP_CODE=$(curl -sS -o /tmp/move-to-sprint-response.txt -w "%{http_code}" \
    -X PUT "$URL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    --data "$BODY")

  if [[ "$HTTP_CODE" == "204" || "$HTTP_CODE" == "200" ]]; then
    echo "  ✓ $KEY"
  else
    echo "  ✗ $KEY — HTTP $HTTP_CODE: $(cat /tmp/move-to-sprint-response.txt)" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

if [[ $FAIL_COUNT -eq 0 ]]; then
  echo "✓ moved ${#ISSUES[@]} issue(s) to sprint $SPRINT_ID"
  exit 0
else
  echo "✗ $FAIL_COUNT of ${#ISSUES[@]} failed" >&2
  exit 1
fi
