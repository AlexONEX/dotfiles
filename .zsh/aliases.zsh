# SHORTCUTS
alias hacker-news='hackernews_tui'
alias dotfiles='~/dotfiles/scripts/sync_dotfiles.sh'

paru() {
    command nice -n 10 ionice -c 3 /usr/bin/paru "$@"
}

paru-clean() {
  echo "Updating the system..."
  paru -Syu

  echo "Cleaning package cache..."
  paru -Sc

  echo "Cleaning entire cache..."
  paru -Scc

  echo "Removing orphaned packages..."
  paru -c

  echo "Searching for unused optional packages..."
  unused_pkgs=$(paru -Qdtq)
  jpegoptim optipng
  if [ -n "$unused_pkgs" ]; then
    echo "The following unused optional packages were found:"
    echo "$unused_pkgs"
    read -p "Do you want to remove them? (y/N) " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo "Removing unused optional packages..."
      paru -Rns $(paru -Qdtq)
    else
      echo "No optional packages were removed."
    fi
  else
    echo "No unused optional packages were found."
  fi

  echo "Cleanup completed."
}

alias r='exec zsh'
alias rf='rm -rf'
alias a='$EDITOR ~/.zsh/aliases.zsh'
alias t='$EDITOR $HOME/.config/tmux/tmux.conf'
alias j='goto'
mark() {
    if [ $# -eq 1 ]; then
        goto -r "$1" "$(pwd)"
    else
        echo "Usage: mark <alias>"
    fi
}

# Alias para saltar a un directorio marcado
alias j='goto'
alias zplugins='ls $ZPLUGINDIR'
alias dotsadd='cd $HOME && chezmoi add .zshrc .zsh/aliases.zsh && cd ~/.config && chezmoi add alacritty easyeffects i3 flameshot polybar tmux/tmux.conf zathura && cd nvim/lua/custom && cd /home/alex/.local/share/chezmoi'

alias z='$EDITOR ~/.zshrc'
alias ct='$EDITOR ~/.config/tmux/tmux.conf'

#list all installed packages
alias pkglist='paru -Qe > ~/pkglist.txt'
alias tocp='xclip -sel c'
alias calibre='fzf-calibre'

# fzz
alias vif='vim $(fzf)'
alias rgf='vim $(rg . | fzf | cut -d ":" -f 1)'
# Recursive search with rg and fzf
alias rgfzf='rg . | fzf'
# Search and cd into the directory
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

fstring() {
  local file_and_line=$(
    rg --color=always --line-number --no-heading --smart-case "${1:-}" |
      fzf --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
  )
  if [[ -n $file_and_line ]]; then
    local file=$(echo "$file_and_line" | cut -d: -f1)
    local line=$(echo "$file_and_line" | cut -d: -f2)
    if [[ -n $EDITOR ]]; then
      $EDITOR "$file" +$line
    else
      vim "$file" +$line
    fi
  fi
}

alias k='pkill -9'
alias bl='xbacklight -get'

alias dsize='du -hsx * | sort -rh'
alias neofetch='fastfetch'
alias open='handlr open'
alias c='clear'
alias vim='nvim'
alias cat='bat'

alias purge='paru -Rns'

#Alias cd
alias cd..='cd ..'
alias ..='cd..'

# Compress
alias zip='zip -r'
alias xz='xz -z -v -k -T 0'

# Docker
(( ${+commands[docker-compose]} )) && dccmd='docker-compose' || dccmd='docker compose'

alias dco="$dccmd"
alias dcb="$dccmd build"
alias dce="$dccmd exec"
alias dcps="$dccmd ps"
alias dcrestart="$dccmd restart"
alias dcrm="$dccmd rm"
alias dcr="$dccmd run"
alias dcstop="$dccmd stop"
alias dcup="$dccmd up"
alias dcupb="$dccmd up --build"
alias dcupd="$dccmd up -d"
alias dcupdb="$dccmd up -d --build"
alias dcdn="$dccmd down"
alias dcl="$dccmd logs"
alias dclf="$dccmd logs -f"
alias dclF="$dccmd logs -f --tail 0"
alias dcpull="$dccmd pull"
alias dcstart="$dccmd start"
alias dck="$dccmd kill"

unset dccmd

# Ip
alias ip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"
alias ip_info="curl -qs https://ifconfig.co/json | jq -r '.ip,.city,.country,.hostname,.asn_org'"

# Pacman stuff
alias u='paru -Syu'
alias i='paru'
alias purge='sudo pacman -Rns'

alias uAndroid='adb shell pm uninstall -k --user 0'
alias pullAndroid='cd $HOME/Pictures/Android && adb pull /storage/emulated/0/Pictures && adb pull /storage/emulated/0/Dcim'
alias network='nmtui'
alias version='lsb_release -a'
alias kernel='uname -r'
alias localip='ip -brief -color address'
alias wttr='curl -4 wttr.in'
alias rpolybar='~/.config/polybar/launch.sh'
alias webToPdf='curl -u 'api:

#Sudo
alias stopB='sudo systemctl stop bluetooth.service'
alias startB='sudo systemctl start bluetooth.service && bluetoothctl'
alias b='fzf-calibre'
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'

# MEDIA
alias pdfconvert='gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf'
alias ytp='yt-dlp -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'

# LS Stuff
alias ls='eza -al --color=always --group-directories-first' # my preferred listing
alias la='eza -a --color=always --group-directories-first'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first'  # long format
alias lt='eza -aT --color=always --group-directories-first' # tree listing
alias l='eza -a | grep -e "^\."'

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias g="grep --color=auto -i"

# adding flags
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias mocp='mocp -M "$XDG_CONFIG_HOME"/moc -O MOCDir="$XDG_CONFIG_HOME"/moc'

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# gpg encryption
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# switch between shells
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"

#yta-best-mp3
function yta(){
    yt-dlp --extract-audio --audio-format "$2" --audio-quality 0 --output "%(title)s.%(ext)s" "$1"
}

function ytpa(){
    yt-dlp --extract-audio --audio-format "$2" --audio-quality 0 --output "%(title)s.%(ext)s" --yes-playlist "$1"
}


# Improved function to replace yta-best alias
yta-best() {
    eval yt-dlp --extract-audio --audio-format "wav" --output '"%(title)s.%(ext)s"' -- '"$1"'
}

alias ytp-abest='yt-dlp --extract-audio --audio-format "wav" --audio-quality 160K --output "%(title)s.%(ext)s" --yes-playlist '
alias ytv-best="yt-dlp -f bestvideo+bestaudio "
alias spotdl='spotdl --cookie-file /home/alex/Music/music.youtube.com_cookies.txt'

alias disks='gdu'

alias duf='echo "╓───── m o u n t . p o i n t s"; \
			 echo "╙────────────────────────────────────── ─ ─ "; \
			 lsblk -a; echo ""; \
			 echo "╓───── d i s k . u s a g e";\
			 echo "╙────────────────────────────────────── ─ ─ "; \
			 df -h;'

function docstop(){
      docker stop $(docker ps -aq)
}

function docstart(){
      docker start $(docker ps -aq)
}

function dockerservice() {
  if ! systemctl is-active --quiet docker; then
    echo "Starting docker service"
    sudo systemctl start docker.service
  else
    echo "Stopping docker service"
    sudo systemctl stop docker.service
  fi
}

function docker-clean() {
  docker stop $(sudo docker ps -aq)
  docker rm $(sudo docker ps -a -q)
  docker rmi $(sudo docker images -q)
}

function docker-clean-images() {
  docker rmi $(sudo docker images -q)
}

alias docstats="docker ps -q | xargs  docker stats --no-stream"

function t() {
	X=$#
	[[ $X -eq 0 ]] || X=X
	tmux new-session -A -s $X
}

#function that receives dir and zips it
function compress() {
    if [[ $# -eq 0 ]]; then
        echo "Error: Please provide a directory path"
        return 1
    fi

    # Get the directory path
    local dir_path="$1"

    # Check if the provided path is a directory
    if [[ ! -d "$dir_path" ]]; then
        echo "Error: '$dir_path' is not a directory"
        return 1
    fi

    # Get the base name of the directory
    local dir_name=$(basename "$dir_path")

    # Create the zip file name
    local zip_file="${dir_name}.zip"

    # Compress the directory
    if zip -r "$zip_file" "$dir_path"; then
        echo "Successfully compressed '$dir_path' into '$zip_file'"
    else
        echo "Error: Failed to compress '$dir_path'"
        return 1
    fi
}

function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1    ;;
      *.tar.gz)    tar xvzf $1    ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xvf $1     ;;
      *.tbz2)      tar xvjf $1    ;;
      *.tgz)       tar xvzf $1    ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


extractf() {
  if [ -f "$1" ] ; then
    # Create a directory based on the file name without its extension
    local dirname="${1%.*}"
    mkdir -p "$dirname"
    cd "$dirname"

    # Extract the file based on its extension
    case "$1" in
      *.tar.bz2) tar xvjf "../$1" ;;
      *.tar.gz)  tar xvzf "../$1" ;;
      *.bz2)     bunzip2 "../$1" ;;
      *.rar)     unrar x "../$1" ;;
      *.gz)      gunzip "../$1" ;;
      *.tar)     tar xvf "../$1" ;;
      *.tbz2)    tar xvjf "../$1" ;;
      *.tgz)     tar xvzf "../$1" ;;
      *.zip)     unzip "../$1" ;;
      *.Z)       uncompress "../$1" ;;
      *.7z)      7z x "../$1" ;;
      *)         echo "'$1' cannot be extracted via extractf()" ;;
    esac
  else
    echo "File '$1' not found"
  fi
}
