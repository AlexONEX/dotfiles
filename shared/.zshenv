export XDG_CONFIG_HOME=$HOME/.config

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.config/emacs/bin"

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/opt/emacs-plus@31/bin:$PATH"
  export PATH="$PATH:/opt/local/bin"
  export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
  export PATH="$PATH:/usr/local/texlive/2025basic/bin/universal-darwin"

  if command -v pyenv &>/dev/null; then
    export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
    export PATH="$PYENV_ROOT/bin:$PATH"
  fi
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
  eval "$(go env GOPATH)" &>/dev/null
  export PATH="$(go env GOPATH)/bin:$PATH"
fi

export EDITOR="ec"

export AWS_REGION="us-east-1"

if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git --color=always'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_DEFAULT_OPTS='--ansi'
elif command -v rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --bind ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-/:toggle-preview --border --height 50% --min-height 20 --preview-window right,40%,follow"

export DOTFILES="${HOME}/.dotfiles"
export BC_ENV_ARGS="$HOME/.bc"
export CLI_THEME=dark
