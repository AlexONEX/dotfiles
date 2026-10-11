if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors '=*=80'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-.]=** r:|=**'
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' menu select=5
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

autoload -U colors && colors
unset LC_CTYPE

autoload -Uz compinit
_zcd=(${ZDOTDIR:-$HOME}/.zcompdump(N.mh-20))
if (( $#_zcd )); then
  compinit -C
else
  compinit -i
fi

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS

typeset -U PATH path

export JAVA_HOME="/Users/alex/Library/Java/JavaVirtualMachines/corretto-21.0.4/Contents/Home"

bindkey -v

ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.zsh}/plugins}
if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
  mkdir -p $ZPLUGINDIR
  git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.zsh

repos=(
    romkatv/powerlevel10k
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
)
plugin-load $repos

function plugin-update {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.zsh/plugins}
  for d in $ZPLUGINDIR/*/.git(/); do
    echo "Updating ${d:h:t}"
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

if [[ -f $ZPLUGINDIR/powerlevel10k/powerlevel10k.zsh-theme ]]; then
    source $ZPLUGINDIR/powerlevel10k/powerlevel10k.zsh-theme
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ "$INSIDE_EMACS" == *vterm* ]]; then
  _vterm_sh=(~/.config/emacs/elpa/vterm-*/etc/emacs-vterm-zsh.sh(N))
  [[ -n "$_vterm_sh" ]] && source "${_vterm_sh[-1]}"
  find_file() { vterm_cmd find-file "$(realpath "${@:-.}")"; }
  alias o='find_file'
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
  (( $+functions[p10k] )) && p10k reload
fi

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

export NVM_DIR="$HOME/.nvm"
_nvm_lazy_load() {
  unset -f nvm node npm npx 2>/dev/null
  [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && . "/opt/homebrew/opt/nvm/nvm.sh"
  [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm() { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; command node "$@"; }
npm() {
  _nvm_lazy_load
  command npm "$@"
  if [[ "$1" == "install" || "$1" == "i" || "$1" == "ci" ]]; then
    [[ -d node_modules ]] && touch node_modules/.metadata_never_index
  fi
}
npx() { _nvm_lazy_load; command npx "$@"; }

if command -v nvim &>/dev/null; then
  export VISUAL=nvim
else
  export VISUAL=vim
fi
export EDITOR="ec"

{
  if ! emacsclient -w 2 -e t &>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      open -ga /Applications/Emacs.app
    elif command -v emacs &>/dev/null; then
      emacs --daemon &>/dev/null
    fi
  fi
} &!

if [ -f ~/.zsh/aliases.zsh ]; then
    . ~/.zsh/aliases.zsh
fi

if [ -f ~/.zsh/git.plugin.zsh ]; then
    . ~/.zsh/git.plugin.zsh
fi

if [ -f ~/.zsh/infra-aliases.zsh ]; then
    . ~/.zsh/infra-aliases.zsh
fi

if [ -f ~/.zsh/database.zsh ]; then
    . ~/.zsh/database.zsh
fi

export SDKMAN_DIR="$HOME/.sdkman"
sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}

alias gwip="git add . && git commit -m 'WIP'"
alias secretary="opencode --agent secretary"
alias sec="opencode --agent secretary"

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

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"

export EMACS_MAC_OPTION_MODIFIER=meta

alias mails='gmail.py'
alias gmail='gmail-tui.py'
alias mails-ari='gmail.py --account allaria'
alias mails-alm='gmail.py --account almafintech'
alias mails-unread='gmail.py --unread'
alias mails-aws='gmail.py --label AWS'
alias mails-github='gmail.py --label GitHub'
alias mails-jira='gmail.py --label Jira'
alias mails-short='gmail.py --short'
alias mails-inbox='gmail.py --unread --label INBOX'
alias gmail-ari='gmail-tui.py --account allaria'
alias gmail-alm='gmail-tui.py --account almafintech'
alias gmail-reauth='gmail-reauth.py'
export PATH="$HOME/bin:$PATH"
alias mu='meridian-usage'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

export PATH="$HOME/.local/bin:$PATH"
export PROTONMAIL_USERNAME="josephcopertars@proton.me"
export PROTONMAIL_SMTP_PORT=1025

autoload -Uz add-zsh-hook
_deferred_init() {
  add-zsh-hook -d precmd _deferred_init
  export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null || echo "$JAVA_HOME")"
  export GITLAB_TOKEN="$(security find-generic-password -s "gitlab-allaria" -a "alex" -w 2>/dev/null)"
  export PROTONMAIL_PASSWORD="$(security find-generic-password -s "protonmail-smtp" -a "alex" -w 2>/dev/null)"
}
add-zsh-hook precmd _deferred_init

export PATH="/Users/alex/.local/bin:$PATH"

alias net-rescue="~/bin/net-rescue"

controlx-db-route() {
  local rds=10.20.180.209 iface=""
  for i in ${(f)"$(ifconfig -l | tr ' ' '\n' | grep utun)"}; do
    ifconfig "$i" 2>/dev/null | grep -qE 'inet 192\.168\.[0-3]\.' && { iface="$i"; break; }
  done
  if [[ -z "$iface" ]]; then
    echo "controlx-db-route: no encuentro el túnel PROD (192.168.0.0/22). ¿VPN PROD conectada?" >&2
    return 1
  fi
  sudo route -n delete -host "$rds" 2>/dev/null
  sudo route -n add -host "$rds" -interface "$iface" >/dev/null && echo "controlx RDS -> $iface"
}
