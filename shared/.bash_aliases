# =============================================================================
# .bash_aliases — shared between macOS (bash) & Linux (Debian server)
# =============================================================================
# Sourced from ~/.bashrc via: [ -f ~/.bash_aliases ] && . ~/.bash_aliases
# =============================================================================

# ─── General ─────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'

# ─── Package management ──────────────────────────────────────────────────────
alias u='sudo apt update -y && sudo apt upgrade -y'
alias p='sudo apt autoremove --purge'

# ─── Reload config ───────────────────────────────────────────────────────────
alias r='source ~/.bashrc'
alias a='vim ~/.bash_aliases'

# ─── OpenCode / Meridian Profile Switching ───────────────────────────────────
# Switch profiles at runtime — OpenCode picks it up automatically via Meridian

_oc_switch() {
    local profile=$1
    meridian profile switch "$profile" \
        && echo "Switched to: $profile" \
        || echo "Meridian not running? Try: meridian-restart"
}

alias oc-self='_oc_switch personal'
alias oc-allaria='_oc_switch allaria'
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
