#!/bin/bash
# PreToolUse(Write) — block creation of stray .md/.txt documentation files.
# Claude tends to spawn unsolicited READMEs/notes/summaries; this stops it.
# Allows canonical docs and anything under structured doc locations.
input=$(cat)
path=$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)

case "$path" in
  *.md|*.txt) ;;
  *) exit 0 ;;   # not a doc file — allow
esac

# Canonical filenames always allowed
case "$(basename "$path")" in
  README.md|CLAUDE.md|AGENTS.md|CONTRIBUTING.md|CHANGELOG.md|LICENSE.md|SKILL.md|MEMORY.md|TODO.md) exit 0 ;;
esac

# Structured doc locations always allowed
case "$path" in
  */.claude/*|*/skills/*|*/agents/*|*/memory/*|*/docs/*|*/.opencode/*) exit 0 ;;
esac

echo "[doc-blocker] Blocked writing '$path'." >&2
echo "[doc-blocker] Create docs only when explicitly asked; use README.md or a docs/ dir." >&2
exit 2
