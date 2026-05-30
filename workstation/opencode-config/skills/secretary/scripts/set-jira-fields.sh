#!/usr/bin/env bash
#
# set-jira-fields.sh — Set arbitrary fields on a Jira issue via the REST API.
#
# Workaround: opencode's MCP wrapper for editJiraIssue/createJiraIssue fails
# (Expected object, received string) when the `fields`/`additional_fields`
# parameter contains certain values (primitives, integer customfields, etc.).
# This script PUTs directly to /rest/api/3/issue/{key} with arbitrary JSON.
#
# Usage:
#   set-jira-fields.sh <issueKey> '<json-fields-object>'
#
# Examples:
#   # Set labels + epic + story points + sprint in one call
#   set-jira-fields.sh DP-18128 '{
#     "labels":["platform"],
#     "customfield_10016":1.5,
#     "customfield_10020":1349,
#     "parent":{"key":"DP-16496"}
#   }'
#
#   # Only labels
#   set-jira-fields.sh DP-18128 '{"labels":["platform"]}'
#
# Common Allaria custom field IDs:
#   customfield_10016 → Story Points
#   customfield_10020 → Sprint  (use the numeric sprint id)
#
# Env overrides:
#   CLOUD_ID         - Atlassian cloud id (default: Allaria)
#   MCP_AUTH_FILE    - path to opencode MCP auth json
#   JIRA_TOKEN       - if set, used directly instead of MCP_AUTH_FILE

set -euo pipefail

CLOUD_ID="${CLOUD_ID:-91fb92aa-9455-4234-becd-7c1d232cdb46}"
MCP_AUTH_FILE="${MCP_AUTH_FILE:-$HOME/.local/share/opencode/mcp-auth.json}"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <issueKey> '<json-fields-object>'" >&2
  echo "example: $0 DP-18128 '{\"labels\":[\"platform\"],\"customfield_10016\":1.5}'" >&2
  exit 2
fi

KEY="$1"
FIELDS_JSON="$2"

# Validate JSON
if ! /usr/bin/python3 -c "import json,sys; json.loads(sys.argv[1])" "$FIELDS_JSON" 2>/dev/null; then
  echo "error: invalid JSON in fields argument" >&2
  echo "  given: $FIELDS_JSON" >&2
  exit 2
fi

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

BODY="$(/usr/bin/python3 -c "import json,sys; print(json.dumps({'fields': json.loads(sys.argv[1])}))" "$FIELDS_JSON")"

URL="https://api.atlassian.com/ex/jira/${CLOUD_ID}/rest/api/3/issue/${KEY}"

echo "→ patching $KEY"

HTTP_CODE=$(curl -sS -o /tmp/set-jira-fields-response.txt -w "%{http_code}" \
  -X PUT "$URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --data "$BODY")

if [[ "$HTTP_CODE" == "204" || "$HTTP_CODE" == "200" ]]; then
  echo "✓ $KEY updated"
  exit 0
else
  echo "✗ $KEY — HTTP $HTTP_CODE:" >&2
  cat /tmp/set-jira-fields-response.txt >&2
  echo >&2
  exit 1
fi
