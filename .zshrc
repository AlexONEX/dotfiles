if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Zstyle Completions ──────────────────────────────────────────────────────
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors '=*=80'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-.]=** r:|=**'
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' menu select=5
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

autoload -U colors && colors

# Define compinit function first but don't run it yet
autoload -Uz compinit

# Basic history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Ensure PATH has unique entries
typeset -U PATH path

# Vim keybindings (optional - comment out if you prefer emacs bindings)
bindkey -v

# Plugin management with zsh_unplugged
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.zsh}/plugins}
if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  mkdir -p $ZPLUGINDIR
  git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh

# Essential plugins
repos=(
    romkatv/powerlevel10k
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
)
plugin-load $repos

# Plugin update helper
function plugin-update {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.zsh/plugins}
  for d in $ZPLUGINDIR/*/.git(/); do
    echo "Updating ${d:h:t}"
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

# Initialize Powerlevel10k
if [[ -f $ZPLUGINDIR/powerlevel10k/powerlevel10k.zsh-theme ]]; then
    source $ZPLUGINDIR/powerlevel10k/powerlevel10k.zsh-theme
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Homebrew (macOS)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Now run compinit after everything else is set up
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  compinit
else
  compinit -i  # Use -i flag to ignore insecure directories/files
fi

if command -v nvim &>/dev/null; then
  export VISUAL=nvim
else
  export VISUAL=vim
fi
export EDITOR="${VISUAL}"

# ===== USER ALIASES =====
if [ -f ~/.zsh/aliases.zsh ]; then
    . ~/.zsh/aliases.zsh
fi

# ===== GIT PLUGIN =====
if [ -f ~/.zsh/git.plugin.zsh ]; then
    . ~/.zsh/git.plugin.zsh
fi

# ===== INFRA ALIASES ====
if [ -f ~/.zsh/infra-aliases.zsh ]; then
    . ~/.zsh/infra-aliases.zsh
fi

# ===== DATABASE ALIASES ====
if [ -f ~/.zsh/database.zsh ]; then
    . ~/.zsh/database.zsh
fi

if [ -f ~/secure/zsh_credentials.env ]; then
    source ~/secure/zsh_credentials.env
fi
# goto lazy-load — se carga en el primer uso
goto() {
  unset -f goto
  source /opt/homebrew/etc/bash_completion.d/goto.sh
  goto "$@"
}
# SDKMAN lazy-load — se activa solo al primer `sdk` o `java` etc
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

GITSTATUS_LOG_LEVEL=DEBUG
alias gwip="git add . && git commit -m 'WIP'"
alias secretary="opencode --agent secretary"
alias sec="opencode --agent secretary"

# ===== SECRETARY TASKS =====
_SECRETARY_DB="$HOME/.config/opencode/secretary/secretary.db"

alias tasks='sqlite3 -column -header "$_SECRETARY_DB" \
  "SELECT id, substr(title,1,70) AS task, priority, substr(created_at,1,10) AS date FROM commitments WHERE status = '\''pending'\'' ORDER BY
   CASE priority WHEN '\''high'\'' THEN 1 WHEN '\''medium'\'' THEN 2 WHEN '\''low'\'' THEN 3 ELSE 4 END, created_at;"'
alias tasks-all='sqlite3 -column -header "$_SECRETARY_DB" \
  "SELECT id, substr(title,1,70) AS task, priority, status, substr(created_at,1,10) AS date FROM commitments ORDER BY
   CASE status WHEN '\''pending'\'' THEN 0 WHEN '\''active'\'' THEN 1 ELSE 2 END,
   CASE priority WHEN '\''high'\'' THEN 1 WHEN '\''medium'\'' THEN 2 WHEN '\''low'\'' THEN 3 ELSE 4 END, created_at;"'

task-done() {
  if [ $# -eq 0 ]; then
    echo "Uso: task-done <id>"
    echo "Ej:  task-done C-0006"
    return 1
  fi
  local id="$1"
  local now=$(date '+%Y-%m-%d %H:%M:%S')
  sqlite3 "$_SECRETARY_DB" "UPDATE commitments SET status = 'completed', completed_at = '$now', updated_at = '$now' WHERE id = '$id' AND status != 'completed';"
  if [ $? -eq 0 ] && [ "$(sqlite3 "$_SECRETARY_DB" "SELECT changes();")" -gt 0 ]; then
    echo "✅ $id completado"
  else
    echo "⚠️  $id no encontrado o ya estaba completado"
  fi
}

task-cancel() {
  if [ $# -eq 0 ]; then
    echo "Uso: task-cancel <id>"
    echo "Ej:  task-cancel C-0006"
    return 1
  fi
  local id="$1"
  local now=$(date '+%Y-%m-%d %H:%M:%S')
  sqlite3 "$_SECRETARY_DB" "UPDATE commitments SET status = 'cancelled', updated_at = '$now' WHERE id = '$id' AND status NOT IN ('completed', 'cancelled');"
  if [ $? -eq 0 ] && [ "$(sqlite3 "$_SECRETARY_DB" "SELECT changes();")" -gt 0 ]; then
    echo "❌ $id cancelado"
  else
    echo "⚠️  $id no encontrado o ya estaba finalizado"
  fi
}

task-add() {
  if [ $# -eq 0 ]; then
    echo "Uso: task-add <descripción>"
    echo "Ej:  task-add Revisar PR de infraestructura"
    return 1
  fi
  local title="$*"
  local next_id=$(sqlite3 "$_SECRETARY_DB" "
    SELECT printf('C-%04d', COALESCE(
      (SELECT MAX(CAST(SUBSTR(id,3) AS INTEGER)) FROM commitments), 0
    ) + 1);
  ")
  sqlite3 "$_SECRETARY_DB" "INSERT INTO commitments (id, title, status, priority) VALUES ('$next_id', '$title', 'pending', 'medium');"
  echo "📌 $next_id — $title (medium)"
}

CREDENTIALS_FILE="$HOME/Github/Me/dotfiles/.password-store/credentials.env"
if [ -f "$CREDENTIALS_FILE" ] && [ -r "$CREDENTIALS_FILE" ]; then
  source "$CREDENTIALS_FILE"
fi

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# Add JBang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"

# Emacs Mac keyboard fix
export EMACS_MAC_OPTION_MODIFIER=meta
