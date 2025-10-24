# Helper functions for main/develop branches
function current_branch() {
  git_current_branch
}

function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return 0
    fi
  done
  echo dev
  return 1
}

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done
  echo main
  return 1
}

# Rename branch locally and on remote
function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"
    return 1
  fi
  git branch -m "$1" "$2"
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

# Delete all merged branches except main/develop
function gbda() {
  git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2>/dev/null
}

# Delete squashed branches
function gbds() {
  local default_branch=$(git_main_branch)
  (( ! $? )) || default_branch=$(git_develop_branch)

  git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch; do
      local merge_base=$(git merge-base $default_branch $branch)
      if [[ $(git cherry $default_branch $(git commit-tree $(git rev-parse $branch\^{tree}) -p $merge_base -m _)) = -* ]]; then
        git branch -D $branch
      fi
    done
}

# Unwip all recent --wip-- commits
function gunwipall() {
  local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H)
  if [[ "$_commit" != "$(git rev-parse HEAD)" ]]; then
    git reset $_commit || return 1
  fi
}

# Warn if current branch is WIP
function work_in_progress() {
  command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- "--wip--" && echo "WIP!!"
}

# Pull and push in one command
function ggpnp() {
  if [[ "$#" == 0 ]]; then
    ggl && ggp
  else
    ggl "${*}" && ggp "${*}"
  fi
}

# Pull rebase on current branch
function ggu() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git pull --rebase origin "${b:=$1}"
}

# Pull on current branch or specified branch
function ggl() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git pull origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git pull origin "${b:=$1}"
  fi
}

# Force push to current branch
function ggf() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git push --force origin "${b:=$1}"
}

# Force push with lease to current branch
function ggfl() {
  [[ "$#" != 1 ]] && local b="$(git_current_branch)"
  git push --force-with-lease origin "${b:=$1}"
}

# Push to current branch or specified branch
function ggp() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git push origin "${b:=$1}"
  fi
}

# Clone and cd into directory
function gccd() {
  setopt localoptions extendedglob
  local repo="${${@[(r)(ssh://*|git://*|ftp(s)#://*|http(s)#://*|*@*)(.git/#)#]}:-$_}"
  command git clone --recurse-submodules "$@" || return
  [[ -d "$_" ]] && cd "$_" || cd "${${repo:t}%.git/#}"
}

# Git diff with viewer
function gdv() { git diff -w "$@" | view - }

# Git diff excluding lock files
function gdnolock() {
  git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}

# Pretty git log
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}

# Create GitHub repo from current directory
function create_git_repo() {
    command -v git >/dev/null 2>&1 || {
        echo "Error: git is not installed"
        return 1
    }
    command -v gh >/dev/null 2>&1 || {
        echo "Error: GitHub CLI (gh) is not installed"
        return 1
    }
    git rev-parse --git-dir > /dev/null 2>&1 || {
        echo "Error: Not a git repository"
        return 1
    }
    remote_url=$(git config --get remote.origin.url 2>/dev/null)
    if [ -z "$remote_url" ]; then
        git_root=$(git rev-parse --show-toplevel)
        repo_name=${git_root:t}
        git_user=$(git config user.name)
        if [ -z "$git_user" ]; then
            echo "Error: Git username not found in config. Please set it with: git config --global user.name 'username'"
            return 1
        fi
        echo "Creating repository on GitHub..."
        gh repo create "$repo_name" --private --source=. --push || {
            echo "Error: Failed to create repository on GitHub"
            return 1
        }
        echo "Successfully created repository $repo_name"
        return 0
    else
        echo "Remote repository already exists"
        return 0
    fi
}

# FZF Git Functions (NEW)
# Change branch with fzf
ch() {
    local branch
    branch=$(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/ | head -n 20 | fzf)
    if [[ -n "$branch" ]]; then
        git checkout "$branch"
    fi
}

# Add files with fzf (multiple selection)
fadd() {
    local files
    files=$(git status -s | awk '{print $2}' | fzf -x -m)
    if [[ -n "$files" ]]; then
        echo "$files" | xargs git add --all
    fi
}

# Fixup commit with fzf
ffix() {
    local hash
    hash=$(git log --pretty=oneline | head | fzf | awk '{print $1}')
    if [[ -n "$hash" ]]; then
        git commit --fixup="$hash"
        GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash "$hash~1"
    fi
}

# Show commit with fzf
fshow() {
    local hash
    hash=$(git log --pretty=oneline | head | fzf | awk '{print $1}')
    if [[ -n "$hash" ]]; then
        git show "$hash"
    fi
}

# Copy commit hash to clipboard with fzf
flog() {
    local hash
    hash=$(git log --pretty=oneline | head | fzf | awk '{print $1}')
    if [[ -n "$hash" ]]; then
        echo -n "$hash" | pbcopy
        echo "Copied to clipboard: $hash"
    fi
}

# Interactive rebase with fzf
frebase() {
    local hash
    hash=$(git log --pretty=oneline | head -n 50 | fzf | awk '{print $1}')
    if [[ -n "$hash" ]]; then
        git rebase -i "$hash^"
    fi
}

# Edit files with vim using fzf (multiple selection)
fvim() {
    local files
    files=$(git status -s | awk '{print $2}' | fzf -x -m)
    if [[ -n "$files" ]]; then
        vim $files
    fi
}

# Grep and edit files with vim
gfgrep() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: gfgrep <search_term> [path]"
        return 1
    fi
    local files
    files=$(git grep -l -A 0 -B 0 "$1" ${2:-.} | fzf -x -m)
    if [[ -n "$files" ]]; then
        vim $files
    fi
}

# Edit files from a specific commit with fzf
fvimlog() {
    local hash files
    hash=$(git log --pretty=oneline | head -n 50 | fzf | awk '{print $1}')
    if [[ -n "$hash" ]]; then
        files=$(git show --pretty='format:' --name-only "$hash" | fzf -x -m)
        if [[ -n "$files" ]]; then
            vim $files
        fi
    fi
}

# Soft reset to a commit selected with fzf
freset() {
    local hash
    hash=$(git log --pretty=oneline | head -n 50 | fzf | awk '{print $1}')
    if [[ -n "$hash" ]]; then
        git reset --soft "$hash^"
    fi
}

# Git Aliases
# Basic git commands
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'

# Branches
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbgd='LANG=C git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | xargs git branch -d'
alias gbgD='LANG=C git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | xargs git branch -D'
alias gbm='git branch --move'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbg='LANG=C git branch -vv | grep ": gone\]"'

# Checkout and switch
alias gcor='git checkout --recurse-submodules'
alias gcb='git checkout -b'
alias gcB='git checkout -B'
alias gcd='git checkout $(git_develop_branch)'
alias gcm='git checkout $(git_main_branch)'
alias gsw='git switch'
alias gswc='git switch --create'
alias gswd='git switch $(git_develop_branch)'
alias gswm='git switch $(git_main_branch)'
alias back='git checkout -'

# Commits
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'
alias gcas='git commit --all --signoff'
alias gcasm='git commit --all --signoff --message'
alias gcmsg='git commit --message'
alias gcsm='git commit --signoff --message'
alias gcs='git commit --gpg-sign'
alias gcss='git commit --gpg-sign --signoff'
alias gcssm='git commit --gpg-sign --signoff --message'
alias gc!='git commit --verbose --amend'
alias gca!='git commit --verbose --all --amend'
alias gcan!='git commit --verbose --all --no-edit --amend'
alias gcans!='git commit --verbose --all --signoff --no-edit --amend'
alias gcann!='git commit --verbose --all --date=now --no-edit --amend'
alias gcn!='git commit --verbose --no-edit --amend'

# Diff
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdh='git diff HEAD^ HEAD'
alias gdup='git diff @{upstream}'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias diffw='git diff --word-diff'
alias wdiff='git diff --word-diff'

# Fetch
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'

# Log
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glo='git log --oneline --decorate'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glods='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias glod='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias glp='_git_log_prettily'
alias last='git log -1 HEAD'

# Merge
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms='git merge --squash'
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'

# Pull
alias gl='git pull'
alias gpr='git pull --rebase'
alias gprv='git pull --rebase -v'
alias gpra='git pull --rebase --autostash'
alias gprav='git pull --rebase --autostash -v'
alias gprom='git pull --rebase origin $(git_main_branch)'
alias gpromi='git pull --rebase=interactive origin $(git_main_branch)'
alias ggpull='git pull origin "$(git_current_branch)"'
alias gluc='git pull upstream $(git_current_branch)'
alias glum='git pull upstream $(git_main_branch)'
alias prebom='git pull --rebase origin master'
alias prebod='git pull --rebase origin dev'
alias prebodd='git pull --rebase origin develop'

# Push
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpv='git push --verbose'
alias gpoat='git push origin --all && git push origin --tags'
alias gpod='git push origin --delete'
alias ggpush='git push origin "$(git_current_branch)"'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease'
alias gpu='git push upstream'
alias fpush='git push --force-with-lease'

# Rebase
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grbd='git rebase $(git_develop_branch)'
alias grbm='git rebase $(git_main_branch)'
alias grbom='git rebase origin/$(git_main_branch)'

# Remote
alias gr='git remote'
alias grv='git remote --verbose'
alias gra='git remote add'
alias grrm='git remote remove'
alias grmv='git remote rename'
alias grset='git remote set-url'
alias grup='git remote update'

# Reset
alias grh='git reset'
alias gru='git reset --'
alias grhh='git reset --hard'
alias grhk='git reset --keep'
alias grhs='git reset --soft'
alias gpristine='git reset --hard && git clean --force -dfx'
alias gwipe='git reset --hard && git clean --force -df'
alias groh='git reset origin/$(git_current_branch) --hard'

# Restore
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'

# Revert
alias grev='git revert'
alias greva='git revert --abort'
alias grevc='git revert --continue'

# Status
alias gs='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'

# Stash
alias gsta='git stash push'
alias gstall='git stash --all'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --patch'
alias gstu='git stash --include-untracked'

# Show
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'

# Tags
alias gta='git tag --annotate'
alias gts='git tag --sign'
alias gtv='git tag | sort -V'

# Cherry-pick
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# Work in Progress
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message " wip"'
alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'

# Miscellaneous
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

# Clean up
alias git-clean='git branch | grep -v "dev" | grep -v "main" | xargs git branch -D'

# Git GUI
alias gg='git gui citool'
alias gga='git gui citool --amend'
alias gk='\gitk --all --branches &!'
alias gke='\gitk --all $(git log --walk-reflogs --pretty=%h) &!'

# Help
alias ghh='git help'

# Set completion for functions
compdef _git ggpnp=git-checkout
compdef _git ggu=git-checkout
compdef _git ggl=git-checkout
compdef _git ggf=git-checkout
compdef _git ggfl=git-checkout
compdef _git ggp=git-checkout
compdef _git gccd=git-clone
compdef _git gdv=git-diff
compdef _git gdnolock=git-diff
compdef _git _git_log_prettily=git-log

# Deprecated aliases with warnings
alias ggpur='ggu'
