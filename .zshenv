PATH="$HOME/.local/bin:$HOME/.cargo/bin:$(go env GOPATH)/bin:$HOME/.spicetify:$HOME/.npm-global/bin:$PATH"
DOTFILES="${HOME}/.dotfiles"
PATH="$HOME/.local/bin:$HOME/.cargo/bin:$(go env GOPATH)/bin:$HOME/.spicetify:$HOME/.npm-global/bin:$PATH"
BC_ENV_ARGS="$HOME/.bc"
TERMINAL="alacritty"
EDITOR="nvim"
HISTFILE=/dev/null
LISTEN_ADDR="127.0.0.1:9021"

# Then export them
export DOTFILES
export PATH
export BC_ENV_ARGS
export TERMINAL
export EDITOR
export HISTFILE
export LISTEN_ADDR
export LEDGER_FILE=~/OneDrive/Backups/finance.journal
