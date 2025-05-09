if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*'  list-colors '=*=80'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-.]=** r:|=**'
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' menu select=5
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

autoload -U colors && colors
autoload -Uz compinit
compinit

bindkey -v

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS

typeset -U PATH path

# virtualenvwrapper
source /usr/bin/virtualenvwrapper.sh

#goto
source ~/.local/bin/goto.sh

#-------------------------------#
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 13

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# if ~/secure/ exists, source all files in it
if [ -d ~/secure ]; then
    chmod 600 ~/secure/*
    export $(grep -v '^#' ~/secure/credentials.env | xargs)
fi

if command -v nvim &>/dev/null; then
  export VISUAL=nvim
else
  export VISUAL=vim
fi
export EDITOR="${VISUAL}"

if command -v fd &>/dev/null; then
