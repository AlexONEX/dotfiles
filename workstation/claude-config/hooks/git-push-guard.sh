#!/bin/bash
# PreToolUse(Bash) — safety net for git push.
# Hard-blocks force pushes; reminds (non-blocking) on normal pushes.
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)

case "$cmd" in
  *"git push"*) ;;
  *) exit 0 ;;   # not a push — allow
esac

if printf '%s' "$cmd" | grep -qE '(--force|--force-with-lease|(^| )-f( |$))'; then
  echo "[git-push-guard] Force-push blocked. Confirm explicitly with the user first." >&2
  exit 2
fi

echo "[git-push-guard] About to 'git push' — ensure the user asked and branch/remote are correct." >&2
exit 0
