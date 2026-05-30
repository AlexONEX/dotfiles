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
    meridian profile switch "$profile" 2>/dev/null \
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
