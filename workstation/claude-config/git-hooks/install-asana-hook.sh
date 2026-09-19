#!/usr/bin/env bash
# =============================================================================
# install-asana-hook.sh — enable the Asana post-commit hook in a repo
#
# Usage:
#     install-asana-hook.sh [path-to-repo]   # defaults to current directory
#
# Symlinks the shared post-commit-asana hook into <repo>/.git/hooks/post-commit.
# If a post-commit hook already exists, it is preserved: the existing hook is
# renamed to post-commit.local and both are run via a small dispatcher.
# =============================================================================
set -euo pipefail

readonly HOOK_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/post-commit-asana"
readonly TARGET_REPO="${1:-$PWD}"

die() { printf '\033[31m✗ %s\033[0m\n' "$1" >&2; exit 1; }
ok()  { printf '\033[32m✓ %s\033[0m\n' "$1"; }

[[ -f "$HOOK_SRC" ]] || die "no encuentro el hook fuente: $HOOK_SRC"
chmod +x "$HOOK_SRC"

git_dir="$(git -C "$TARGET_REPO" rev-parse --git-dir 2>/dev/null)" \
  || die "'$TARGET_REPO' no es un repo git"
# Normalize to absolute path.
git_dir="$(cd "$TARGET_REPO" && cd "$git_dir" && pwd)"
hooks_dir="$git_dir/hooks"
mkdir -p "$hooks_dir"

dest="$hooks_dir/post-commit"

# Already pointing at our hook? Idempotent no-op.
if [[ -L "$dest" && "$(readlink "$dest")" == "$HOOK_SRC" ]]; then
  ok "el hook ya está instalado en $TARGET_REPO"
  exit 0
fi

# An unrelated post-commit exists → preserve it and chain via a dispatcher.
if [[ -e "$dest" && ! -L "$dest" ]]; then
  mv "$dest" "$hooks_dir/post-commit.local"
  cat > "$dest" <<'DISPATCH'
#!/usr/bin/env bash
# Dispatcher: run the pre-existing hook, then the Asana hook. Neither blocks.
d="$(dirname "$0")"
[[ -x "$d/post-commit.local" ]] && "$d/post-commit.local" "$@"
[[ -x "$d/post-commit.asana" ]] && "$d/post-commit.asana" "$@"
exit 0
DISPATCH
  chmod +x "$dest"
  ln -sf "$HOOK_SRC" "$hooks_dir/post-commit.asana"
  ok "hook Asana encadenado junto al post-commit existente en $TARGET_REPO"
  exit 0
fi

# Clean install (no existing hook, or a stale symlink) → direct symlink.
ln -sf "$HOOK_SRC" "$dest"
ok "hook Asana instalado en $TARGET_REPO/.git/hooks/post-commit"
