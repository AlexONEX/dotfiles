if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

source /usr/bin/virtualenvwrapper.sh

#goto
source ~/.local/bin/goto.sh

#-------------------------------#
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 13

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# if ~/secure/ exists, source all files in it
if [ -d ~/.dotfiles/.password-store/ ]; then
    export $(grep -v '^#' ~/.dotfiles/.password-store/credentials.env | xargs)
fi

if command -v nvim &>/dev/null; then
  export VISUAL=nvim
else
  export VISUAL=vim
fi
export EDITOR="${VISUAL}"

if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git --color=always'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_DEFAULT_OPTS='--ansi'
elif command -v rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --bind ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-/:toggle-preview --border --height 50% --min-height 20 --preview-window right,40%,follow"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/mars/.dart-cli-completion/zsh-config.zsh ]] && . /home/mars/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# ------------------------------------------------------------------------
# | Load external modules
# ------------------------------------------------------------------------
#
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.zsh}/plugins}

if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
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
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in $ZPLUGINDIR/*/.git(/); do
    echo "Updating ${d:h:t}"
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

# Load user aliases
if [ -f ~/.zsh/aliases.zsh ]; then
    . ~/.zsh/aliases.zsh
fi

if [ -f ~/.zsh/git.plugin.zsh ]; then
    . ~/.zsh/git.plugin.zsh
fi

if [ -f ~/.zsh/mappings.sh ]; then
    . ~/.zsh/mappings.sh
fi

# Source fzf and cargo
command -v fzf &>/dev/null && eval "$(fzf --zsh)"
[[ -f ${HOME}/.cargo/env ]] && source "${HOME}/.cargo/env"
eval "$(zoxide init zsh)"
