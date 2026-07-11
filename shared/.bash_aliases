# =============================================================================
# .bash_aliases — shared between macOS (bash) & Linux (Debian server)
# =============================================================================
# Sourced from ~/.bashrc via: [ -f ~/.bash_aliases ] && . ~/.bash_aliases
# =============================================================================

# ─── General ─────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias mkdir='mkdir -pv'
alias external='cd /mnt/external'
alias ls='eza -al'
alias cp='cp -iv'
alias mv='mv -iv'
alias disks='df -h / /srv /var /mnt/external && echo "---" && du -hx --max-depth=1 /srv /mnt/external 2>/dev/null | sort -rh'
alias clean='sudo systemctl start weekly-maintenance'

# ─── Package management ──────────────────────────────────────────────────────
alias u='sudo apt update -y && sudo apt upgrade -y'
alias p='sudo apt autoremove --purge'

# ─── Reload config ───────────────────────────────────────────────────────────
alias vim='nvim'
alias r='source ~/.bashrc'
alias a='nvim ~/.bash_aliases'

# ─── OpenCode / Meridian Profile Switching ───────────────────────────────────
# Switch profiles at runtime — OpenCode picks it up automatically via Meridian

_oc_switch() {
    local profile=$1
    meridian profile switch "$profile" \
        && echo "Switched to: $profile" \
        || echo "Meridian not running? Try: meridian-restart"
}

alias oc-self='_oc_switch personal'
alias oc-alma='_oc_switch alma'

oc-status() {
    local active
    active=$(python3 -c "
import json, sys
try:
    with open('$HOME/.config/meridian/settings.json') as f:
        print(json.load(f).get('activeProfile', 'none'))
except:
    print('none')
" 2>/dev/null)
    echo "Currently active: $active"
    echo ""
    meridian profile list 2>/dev/null || echo "Meridian not running on :3456"
}

meridian-restart() {
    echo "Killing existing Meridian instances..."
    local pids
    pids=$(lsof -ti :3456 2>/dev/null)
    if [[ -n "$pids" ]]; then
        kill "$pids" 2>/dev/null
        echo "Waiting for port 3456 to be free..."
        local waited=0
        while lsof -ti :3456 >/dev/null 2>&1; do
            sleep 1
            waited=$((waited + 1))
            if [[ $waited -ge 5 ]]; then
                kill -9 $pids 2>/dev/null
                sleep 1
                break
            fi
        done
        echo "Port 3456 is free"
    else
        echo "No Meridian found on port 3456"
    fi
    echo "Starting fresh..."
    NODE_NO_WARNINGS=1 nohup meridian &>/dev/null &
    sleep 3
    echo "Meridian running at http://127.0.0.1:3456"
    echo ""
    oc-status
}

# ─── Navigation & general ────────────────────────────────────────────────────
alias c='clear'
alias rf='rm -rf'
alias dsize='du -hsx * | sort -rh'

# ─── fzf integrations ────────────────────────────────────────────────────────
alias vif='vim $(fzf)'
alias rgf='vim $(rg . | fzf | cut -d ":" -f 1)'
alias rgfzf='rg . | fzf'
alias fzfcalibre='fzf-calibre'
alias b='fzf-calibre'

# ─── System info ─────────────────────────────────────────────────────────────
alias df='df -h'
alias free='free -m'
alias kernel='uname -r'
alias version='lsb_release -a'
alias localip='ip -brief -color address'
alias wttr='curl -4 wttr.in'
alias ip_info='curl -qs https://ifconfig.co/json | jq -r ".ip,.city,.country,.hostname,.asn_org"'

# ─── Process management ──────────────────────────────────────────────────────
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias k='pkill -9'

# ─── Systemd ─────────────────────────────────────────────────────────────────
alias jctl="journalctl -p 3 -xb"
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'

# ─── Grep ────────────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias g='grep --color=auto -i'

# ─── GPG ─────────────────────────────────────────────────────────────────────
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# ─── Shell switching ─────────────────────────────────────────────────────────
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"

# ─── Docker compose ──────────────────────────────────────────────────────────
if command -v docker-compose &>/dev/null; then _dccmd='docker-compose'; else _dccmd='docker compose'; fi

alias dco="$_dccmd"
alias dcb="$_dccmd build"
alias dce="$_dccmd exec"
alias dcps="$_dccmd ps"
alias dcrestart="$_dccmd restart"
alias dcrm="$_dccmd rm"
alias dcr="$_dccmd run"
alias dcstop="$_dccmd stop"
alias dcup="$_dccmd up"
alias dcupb="$_dccmd up --build"
alias dcupd="$_dccmd up -d"
alias dcupdb="$_dccmd up -d --build"
alias dcdn="$_dccmd down"
alias dcl="$_dccmd logs"
alias dclf="$_dccmd logs -f"
alias dclF="$_dccmd logs -f --tail 0"
alias dcpull="$_dccmd pull"
alias dcstart="$_dccmd start"
alias dck="$_dccmd kill"
alias docstats="docker ps -q | xargs docker stats --no-stream"

unset _dccmd

# ─── Docker utils ────────────────────────────────────────────────────────────
docker-clean() {
    docker ps -aq | xargs -r docker stop
    docker ps -a -q | xargs -r docker rm
    docker builder prune
}

docker-clean-images() {
    docker rmi $(docker images -q)
}

# ─── Clipboard ───────────────────────────────────────────────────────────────
if command -v xclip >/dev/null 2>&1; then
    alias tocp='xclip -selection clipboard'
    alias fromcp='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
    alias tocp='xsel --clipboard --input'
    alias fromcp='xsel --clipboard --output'
fi

# ─── File utilities ──────────────────────────────────────────────────────────
bak() { cp -r "$1" "$1.bak"; }

logcmd() { "$@" > log_output.txt 2>&1; }

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xvjf "$1"   ;;
            *.tar.gz)  tar xvzf "$1"   ;;
            *.bz2)     bunzip2 "$1"    ;;
            *.rar)     unrar x "$1"    ;;
            *.gz)      gunzip "$1"     ;;
            *.tar)     tar xvf "$1"    ;;
            *.tbz2)    tar xvjf "$1"   ;;
            *.tgz)     tar xvzf "$1"   ;;
            *.zip)     unzip "$1"      ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1"       ;;
            *)         echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

compress() {
    [ $# -eq 0 ] && { echo "Usage: compress <dir>"; return 1; }
    [ ! -d "$1" ] && { echo "'$1' is not a directory"; return 1; }
    local name
    name=$(basename "$1")
    zip -r "${name}.zip" "$1" && echo "Compressed to ${name}.zip"
}

# ─── Tmux ────────────────────────────────────────────────────────────────────
t() {
    local s=${1:-main}
    tmux new-session -A -s "$s"
}
#─── String Search───────────────────────────────────────────────────────────────────
fstring() {
  local file_and_line=$(
    rg --follow --no-messages --color=always --line-number --no-heading --smart-case "${1:-}" |
      fzf --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'f=$(echo {1} | sed "s/\x1b\[[0-9;]*m//g"); n=$(echo {2} | sed "s/\x1b\[[0-9;]*m//g"); bat --style=numbers --color=always --highlight-line "$n" "$f"' \
          --preview-window 'right,60%,border-bottom,+{2}+3/3,~3'
  )

  if [[ -n $file_and_line ]]; then
    local file=$(echo "$file_and_line" | sed 's/\x1b\[[0-9;]*m//g' | cut -d: -f1)
    local line=$(echo "$file_and_line" | sed 's/\x1b\[[0-9;]*m//g' | cut -d: -f2)
    if [[ -n $EDITOR ]]; then
      $EDITOR "$file" +$line
    else
      vim "$file" +$line
    fi
  fi
}

FSTRING() {
  local file_and_line=$(
    rg --follow --no-messages --color=always \
       --line-number \
       --no-heading \
       --case-sensitive \
       --fixed-strings \
       --word-regexp \
       "${1:-}" |
      fzf --ansi \
          --exact \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'f=$(echo {1} | sed "s/\x1b\[[0-9;]*m//g"); n=$(echo {2} | sed "s/\x1b\[[0-9;]*m//g"); bat --style=numbers --color=always --highlight-line "$n" "$f"' \
          --preview-window 'right,60%,border-bottom,+{2}+3/3,~3'
  )
  if [[ -n $file_and_line ]]; then
    local file=$(echo "$file_and_line" | sed 's/\x1b\[[0-9;]*m//g' | cut -d: -f1)
    local line=$(echo "$file_and_line" | sed 's/\x1b\[[0-9;]*m//g' | cut -d: -f2)
    if [[ -n $EDITOR ]]; then
      $EDITOR "$file" +$line
    else
      vim "$file" +$line
    fi
  fi
}

# =============================================================================
# ─── Git (ported from zsh oh-my-zsh) ─────────────────────────────────────────
# =============================================================================

# --- helpers ---
git_current_branch() {
  git branch --show-current 2>/dev/null
}

git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/heads/main refs/heads/trunk refs/heads/mainline refs/heads/default refs/heads/master \
             refs/remotes/origin/main refs/remotes/origin/trunk refs/remotes/origin/mainline \
             refs/remotes/origin/default refs/remotes/origin/master \
             refs/remotes/upstream/main refs/remotes/upstream/trunk refs/remotes/upstream/mainline \
             refs/remotes/upstream/default refs/remotes/upstream/master; do
    if command git show-ref -q --verify "$ref"; then
      basename "$ref"
      return 0
    fi
  done
  echo master
  return 1
}

git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify "refs/heads/$branch"; then
      echo "$branch"
      return 0
    fi
  done
  echo develop
  return 1
}

# --- functions ---
grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: grename old_branch new_branch"
    return 1
  fi
  git branch -m "$1" "$2"
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

gbda() {
  git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs -r git branch --delete 2>/dev/null
}

ggl() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git pull origin "$*"
  else
    local b=""
    [[ "$#" == 0 ]] && b="$(git_current_branch)"
    git pull origin "${b:-$1}"
  fi
}

ggp() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "$*"
  else
    local b=""
    [[ "$#" == 0 ]] && b="$(git_current_branch)"
    git push origin "${b:-$1}"
  fi
}

ggf() {
  local b=""
  [[ "$#" != 1 ]] && b="$(git_current_branch)"
  git push --force origin "${b:-$1}"
}

ggfl() {
  local b=""
  [[ "$#" != 1 ]] && b="$(git_current_branch)"
  git push --force-with-lease origin "${b:-$1}"
}

ggu() {
  local b=""
  [[ "$#" != 1 ]] && b="$(git_current_branch)"
  git pull --rebase origin "${b:-$1}"
}

ggpnp() {
  if [[ "$#" == 0 ]]; then
    ggl && ggp
  else
    ggl "$*" && ggp "$*"
  fi
}

gccd() {
  command git clone --recurse-submodules "$@" || return
  local repo last_arg dir
  last_arg="${@: -1}"
  repo="$last_arg"
  dir="${repo##*/}"
  dir="${dir%.git}"
  if [[ -d "$dir" ]]; then
    cd "$dir"
  fi
}

gdv() { git diff -w "$@" | view -; }

gdnolock() {
  git diff "$@" -- ":(exclude)package-lock.json" ":(exclude)*.lock"
}

_git_log_prettily() {
  if [[ -n "$1" ]]; then
    git log --pretty="$1"
  fi
}

create_git_repo() {
  command -v git >/dev/null 2>&1 || { echo "Error: git is not installed"; return 1; }
  command -v gh >/dev/null 2>&1 || { echo "Error: GitHub CLI (gh) is not installed"; return 1; }
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Error: Not a git repository"; return 1; }
  local remote_url
  remote_url=$(git config --get remote.origin.url 2>/dev/null)
  if [[ -z "$remote_url" ]]; then
    local git_root repo_name git_user
    git_root=$(git rev-parse --show-toplevel)
    repo_name=$(basename "$git_root")
    git_user=$(git config user.name)
    if [[ -z "$git_user" ]]; then
      echo "Error: Git username not found in config. Please set it with: git config --global user.name 'username'"
      return 1
    fi
    echo "Creating repository on GitHub..."
    gh repo create "$repo_name" --private --source=. --push || { echo "Error: Failed to create repository on GitHub"; return 1; }
    echo "Successfully created repository $repo_name"
    return 0
  else
    echo "Remote repository already exists"
    return 0
  fi
}

# --- fzf git functions ---
ch() {
  local branch
  branch=$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ | head -n 20 | fzf)
  [[ -n "$branch" ]] && git checkout "$branch"
}

fadd() {
  local files
  files=$(git status -s | awk '{print $2}' | fzf -m)
  [[ -n "$files" ]] && echo "$files" | xargs -r git add --all
}

ffix() {
  local hash
  hash=$(git log --pretty=oneline | head | fzf | awk '{print $1}')
  if [[ -n "$hash" ]]; then
    git commit --fixup="$hash"
    GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash "$hash~1"
  fi
}

fshow() {
  local hash
  hash=$(git log --pretty=oneline | head | fzf | awk '{print $1}')
  [[ -n "$hash" ]] && git show "$hash"
}

flog() {
  local hash
  hash=$(git log --pretty=oneline | head | fzf | awk '{print $1}')
  if [[ -n "$hash" ]]; then
    echo -n "$hash" | tocp 2>/dev/null || echo -n "$hash" | xclip -selection clipboard 2>/dev/null
    echo "Copied to clipboard: $hash"
  fi
}

frebase() {
  local hash
  hash=$(git log --pretty=oneline | head -n 50 | fzf | awk '{print $1}')
  [[ -n "$hash" ]] && git rebase -i "$hash^"
}

fvim() {
  local files
  files=$(git status -s | awk '{print $2}' | fzf -m)
  [[ -n "$files" ]] && echo "$files" | xargs -r vim
}

gfgrep() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: gfgrep <search_term> [path]"
    return 1
  fi
  local files
  files=$(git grep -l -A 0 -B 0 "$1" "${2:-.}" | fzf -m)
  [[ -n "$files" ]] && echo "$files" | xargs -r vim
}

fvimlog() {
  local hash files
  hash=$(git log --pretty=oneline | head -n 50 | fzf | awk '{print $1}')
  if [[ -n "$hash" ]]; then
    files=$(git show --pretty='format:' --name-only "$hash" | fzf -m)
    [[ -n "$files" ]] && echo "$files" | xargs -r vim
  fi
}

freset() {
  local hash
  hash=$(git log --pretty=oneline | head -n 50 | fzf | awk '{print $1}')
  [[ -n "$hash" ]] && git reset --soft "$hash^"
}

# --- aliases ---
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbm='git branch --move'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gcb='git checkout -b'
alias gcB='git checkout -B'
alias back='git checkout -'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'
alias gcmsg='git commit --message'
alias gcsm='git commit --signoff --message'
alias gc!='git commit --verbose --amend'
alias gca!='git commit --verbose --all --amend'
alias gcan!='git commit --verbose --all --no-edit --amend'
alias gcn!='git commit --verbose --no-edit --amend'
alias gd='git diff'
alias gdca='git diff --cached'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdh='git diff HEAD^ HEAD'
alias gdup='git diff @{upstream}'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glo='git log --oneline --decorate'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias glp='_git_log_prettily'
alias last='git log -1 HEAD'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms='git merge --squash'
alias gl='git pull'
alias gpr='git pull --rebase'
alias gpra='git pull --rebase --autostash'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpv='git push --verbose'
alias gpoat='git push origin --all && git push origin --tags'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias gr='git remote'
alias grv='git remote --verbose'
alias gra='git remote add'
alias grrm='git remote remove'
alias grmv='git remote rename'
alias grset='git remote set-url'
alias grup='git remote update'
alias grh='git reset'
alias gru='git reset --'
alias grhh='git reset --hard'
alias grhs='git reset --soft'
alias gpristine='git reset --hard && git clean --force -dfx'
alias gwipe='git reset --hard && git clean --force -df'
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'
alias grev='git revert'
alias greva='git revert --abort'
alias grevc='git revert --continue'
alias gs='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'
alias gsta='git stash push'
alias gstall='git stash --all'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --patch'
alias gstu='git stash --include-untracked'
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'
alias gta='git tag --annotate'
alias gts='git tag --sign'
alias gtv='git tag | sort -V'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
alias gcf='git config --list'
alias gclean='git clean --interactive -d'
alias gcl='git clone --recurse-submodules'
alias gcount='git shortlog --summary --numbered'
alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias gfg='git ls-files | grep'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
alias gls='git ls-files'
alias glsm='git ls-files -m'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias grf='git reflog'
alias grm='git rm'
alias grmc='git rm --cached'
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias gsi='git submodule init'
alias gsu='git submodule update'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'
alias git-clean='git branch --format="%(if)%(HEAD)%(then)%(else)%(refname:short)%(end)" | grep -v "^$" | grep -v -e "^dev$" -e "^main$" | xargs -r git branch -D'
alias ghh='git help'
alias diffw='git diff --word-diff'
alias wdiff='git diff --word-diff'
