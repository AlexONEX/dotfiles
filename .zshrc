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

if [ -f ~/.zsh/aliases.zsh ]; then
    . ~/.zsh/aliases.zsh
fi

if [ -f ~/.zsh/git.plugin.zsh ]; then
    . ~/.zsh/git.plugin.zsh
fi

#-------Plugin Management-------#
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
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'

export PATH=$PATH:/home/mars/.spicetify
export HISTFILE=/dev/null

# if ~/secure/ exists, source all files in it
if [ -d ~/secure ]; then
    for file in ~/secure/*; do
        source $file
    done
fi
