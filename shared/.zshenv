# =============================================================================
# .zshenv — shared between macOS (Alex) & Linux (Debian server)
# =============================================================================

# ─── XDG ──────────────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME=$HOME/.config

# ─── PATH ─────────────────────────────────────────────────────────────────────
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.config/emacs/bin"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# macOS-specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="$PATH:/opt/local/bin"
  export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
  export PATH="$PATH:/usr/local/texlive/2025basic/bin/universal-darwin"

  # Python virtualenvwrapper
  export WORKON_HOME=$HOME/.virtualenvs
  export VIRTUALENVWRAPPER_PYTHON=$(which python3 2>/dev/null)
  if command -v virtualenvwrapper.sh &>/dev/null; then
    source virtualenvwrapper.sh
  elif [[ -f /opt/homebrew/bin/virtualenvwrapper.sh ]]; then
    source /opt/homebrew/bin/virtualenvwrapper.sh
  fi

  # pyenv
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Linux-specific (Debian server)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
  eval "$(go env GOPATH)" &>/dev/null
  export PATH="$(go env GOPATH)/bin:$PATH"
fi

# ─── EDITOR ───────────────────────────────────────────────────────────────────
export EDITOR="nvim"

# ─── AWS ──────────────────────────────────────────────────────────────────────
export AWS_REGION="us-east-1"

# ─── FZF ──────────────────────────────────────────────────────────────────────
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git --color=always'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_DEFAULT_OPTS='--ansi'
elif command -v rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --bind ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-/:toggle-preview --border --height 50% --min-height 20 --preview-window right,40%,follow"

# ─── MISC ─────────────────────────────────────────────────────────────────────
export DOTFILES="${HOME}/.dotfiles"
export BC_ENV_ARGS="$HOME/.bc"
export CLI_THEME=dark
