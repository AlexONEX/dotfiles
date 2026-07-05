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
unset LC_CTYPE

# Initialize completions BEFORE loading plugins (plugins call compdef)
autoload -Uz compinit
# Usar dump cacheado si fue generado hace <20h, regenerar si es más viejo
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh-20)" ]]; then
  compinit -C
else
  compinit -i
fi

# Basic history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Ensure PATH has unique entries
typeset -U PATH path

# Java
export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || echo "/Users/alex/Library/Java/JavaVirtualMachines/corretto-21.0.4/Contents/Home")

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

# Virtualenvwrapper — lazy-load (solo cuando usás workon/mkvirtualenv/etc)
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/opt/homebrew/bin/python3
_venv_lazy_init() {
  unset -f workon mkvirtualenv rmvirtualenv deactivate lsvirtualenv cpvirtualenv allvirtualenv
  local _vw
  _vw="$(command -v virtualenvwrapper.sh 2>/dev/null)" || _vw=/opt/homebrew/bin/virtualenvwrapper.sh
  [[ -f "$_vw" ]] && source "$_vw"
}
workon()       { _venv_lazy_init; workon "$@"; }
mkvirtualenv() { _venv_lazy_init; mkvirtualenv "$@"; }
rmvirtualenv() { _venv_lazy_init; rmvirtualenv "$@"; }
lsvirtualenv() { _venv_lazy_init; lsvirtualenv "$@"; }
cpvirtualenv() { _venv_lazy_init; cpvirtualenv "$@"; }
allvirtualenv() { _venv_lazy_init; allvirtualenv "$@"; }
deactivate()   { _venv_lazy_init; deactivate "$@"; }

# Auto-excluir node_modules de Spotlight después de npm install
npm() {
  command npm "$@"
  if [[ "$1" == "install" || "$1" == "i" || "$1" == "ci" ]]; then
    [[ -d node_modules ]] && touch node_modules/.metadata_never_index
  fi
}

# NVM — lazy-load (solo cuando usás node/npm/npx/nvm)
export NVM_DIR="$HOME/.nvm"
_nvm_lazy_load() {
  unset -f nvm node npm npx 2>/dev/null
  [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && . "/opt/homebrew/opt/nvm/nvm.sh"
  [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm() { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; command node "$@"; }
npm() { _nvm_lazy_load; command npm "$@"; }
npx() { _nvm_lazy_load; command npx "$@"; }

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
# SDKMAN lazy-load — se activa solo al primer `sdk` o `java` etc
export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

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
     echo "Usage: task-done <id>"
     echo "Ex:    task-done C-0006"
     return 1
   fi
   local id="$1"
   local now=$(date '+%Y-%m-%d %H:%M:%S')
   sqlite3 "$_SECRETARY_DB" "UPDATE commitments SET status = 'completed', completed_at = '$now', updated_at = '$now' WHERE id = '$id' AND status != 'completed';"
   if [ $? -eq 0 ] && [ "$(sqlite3 "$_SECRETARY_DB" "SELECT changes();")" -gt 0 ]; then
     echo "DONE: $id completed"
   else
     echo "WARN: $id not found or already completed"
   fi
}

task-cancel() {
   if [ $# -eq 0 ]; then
     echo "Usage: task-cancel <id>"
     echo "Ex:    task-cancel C-0006"
     return 1
   fi
   local id="$1"
   local now=$(date '+%Y-%m-%d %H:%M:%S')
   sqlite3 "$_SECRETARY_DB" "UPDATE commitments SET status = 'cancelled', updated_at = '$now' WHERE id = '$id' AND status NOT IN ('completed', 'cancelled');"
   if [ $? -eq 0 ] && [ "$(sqlite3 "$_SECRETARY_DB" "SELECT changes();")" -gt 0 ]; then
     echo "CANCEL: $id cancelled"
   else
     echo "WARN: $id not found or already finished"
   fi
}

task-add() {
   if [ $# -eq 0 ]; then
     echo "Usage: task-add <description>"
     echo "Ex:    task-add Review infrastructure PR"
     return 1
   fi
   local title="$*"
   local next_id=$(sqlite3 "$_SECRETARY_DB" "
     SELECT printf('C-%04d', COALESCE(
       (SELECT MAX(CAST(SUBSTR(id,3) AS INTEGER)) FROM commitments), 0
     ) + 1);
   ")
   sqlite3 "$_SECRETARY_DB" "INSERT INTO commitments (id, title, status, priority) VALUES ('$next_id', '$title', 'pending', 'medium');"
   echo "TASK: $next_id — $title (medium)"
}

CREDENTIALS_FILE="$DOTFILES/.password-store/credentials.env"
if [ -f "$CREDENTIALS_FILE" ] && [ -r "$CREDENTIALS_FILE" ]; then
  source "$CREDENTIALS_FILE"
fi

# Source local env file if present (generated by mise/asdf/pyenv etc.)
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# Add JBang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"

# Emacs Mac keyboard fix
export EMACS_MAC_OPTION_MODIFIER=meta

# ─── Gmail CLI/TUI (usa credenciales de opencode, zero extra config) ─────────
alias mails='gmail.py'                              # CLI — ultimos 15 (default: allaria)
alias gmail='gmail-tui.py'                          # TUI interactiva con vim keys
alias mails-ari='gmail.py --account allaria'        # CLI — Allaria
alias mails-alm='gmail.py --account almafintech'    # CLI — Almafintech
alias mails-unread='gmail.py --unread'              # CLI — solo no leidos
alias mails-aws='gmail.py --label AWS'              # CLI — filtro AWS
alias mails-github='gmail.py --label GitHub'        # CLI — filtro GitHub
alias mails-jira='gmail.py --label Jira'            # CLI — filtro Jira
alias mails-short='gmail.py --short'                # CLI — modo compacto
alias mails-inbox='gmail.py --unread --label INBOX' # CLI — inbox pendiente
alias gmail-ari='gmail-tui.py --account allaria'    # TUI — Allaria
alias gmail-alm='gmail-tui.py --account almafintech' # TUI — Almafintech
alias gmail-reauth='gmail-reauth.py'                  # Re-autenticacion OAuth
# ─── Meridian usage ────────────────────────────────────────────────────────────
export PATH="$HOME/bin:$PATH"
alias mu='meridian-usage'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

export GITLAB_TOKEN=$(security find-generic-password -s "gitlab-allaria" -a "alex" -w 2>/dev/null)
