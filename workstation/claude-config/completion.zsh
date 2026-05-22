#compdef claude-use
# ZSH completion for claude-use command

_claude_use_completion() {
    local -a profiles
    if [[ -f "$HOME/.config/claude-profiles/profiles.json" ]]; then
        profiles=($(jq -r 'keys[]' "$HOME/.config/claude-profiles/profiles.json"))
    fi
    _describe 'claude profile' profiles
}

compdef _claude_use_completion claude-use
