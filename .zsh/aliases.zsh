#═══════════════════════════════════════════════════════════════════════════════
# DOTFILES MANAGEMENT
#═══════════════════════════════════════════════════════════════════════════════

dotfiles-add() {
  local input_path="$1"
  local home_path="$HOME"
  local dotfiles_path="$HOME/.dotfiles"
  local full_path=""

  # Handle "." as current directory
  if [ "$input_path" = "." ]; then
    full_path="$(pwd)"
  else
    # If path doesn't start with /, assume it's in .config
    if [[ "$input_path" != /* && "$input_path" != .* && "$input_path" != ~* ]]; then
      full_path="$home_path/.config/$input_path"
    # Convert to absolute path if needed
    elif [[ "$input_path" = /* ]]; then
      full_path="$input_path"
    else
      full_path="$(pwd)/$input_path"
    fi
  fi

  # Ensure path is under home directory
  if [[ "$full_path" != "$home_path"* ]]; then
    echo "Error: Path must be under home directory"
    return 1
  fi

  # Check if path exists
  if [ ! -e "$full_path" ]; then
    echo "Error: $full_path does not exist"
    return 1
  fi

  # Get relative path from home
  local rel_path="${full_path#$home_path/}"
  local package_name=$(echo "$rel_path" | cut -d/ -f1)

  # Get directory structure
  local target_dir="$(dirname "$dotfiles_path/$rel_path")"

  # Create necessary directories
  mkdir -p "$target_dir"

  # Copy the file/directory
  if [ -d "$full_path" ]; then
    cp -r "$full_path" "$target_dir/"
  else
    cp "$full_path" "$target_dir/"
  fi

  # Only stow the specific package
  cd "$dotfiles_path"
  stow --adopt --target="$HOME" "$package_name" 2>/dev/null || true

  echo "Added $rel_path to dotfiles repository"
}

alias dotsadd='cd $HOME && chezmoi add .zshrc .zsh/aliases.zsh && cd ~/.config && chezmoi add alacritty easyeffects i3 flameshot polybar tmux/tmux.conf zathura && cd nvim/lua/custom && cd /home/alex/.local/share/chezmoi'

#═══════════════════════════════════════════════════════════════════════════════
# BASIC SHELL OPERATIONS
#═══════════════════════════════════════════════════════════════════════════════

alias r='exec zsh'
alias c='clear'
alias rf='rm -rf'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'

# Directory navigation
alias cd..='cd ..'
alias ..='cd..'

# Backup function
bak() {
    cp "$1" "$1.bak"
}

# Mark and goto
mark() {
    if [ $# -eq 1 ]; then
        goto -r "$1" "$(pwd)"
    else
        echo "Usage: mark <alias>"
    fi
}

alias j='goto'

#═══════════════════════════════════════════════════════════════════════════════
# EDITORS AND CONFIG FILES
#═══════════════════════════════════════════════════════════════════════════════

alias a='$EDITOR ~/.zsh/aliases.zsh'
alias z='$EDITOR ~/.zshrc'
alias t='$EDITOR $HOME/.config/tmux/tmux.conf'
alias ct='$EDITOR ~/.config/tmux/tmux.conf'

#═══════════════════════════════════════════════════════════════════════════════
# FILE LISTING (EZA)
#═══════════════════════════════════════════════════════════════════════════════

alias ls='eza -al --color=always --group-directories-first'
alias la='eza -a --color=always --group-directories-first'
alias ll='eza -l --color=always --group-directories-first'
alias lt='eza -aT --color=always --group-directories-first'
alias l='eza -a | grep -e "^\."'

#═══════════════════════════════════════════════════════════════════════════════
# PACKAGE MANAGEMENT (PARU/PACMAN)
#═══════════════════════════════════════════════════════════════════════════════

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

alias u='paru -Syu'
alias i='paru'
alias purge='paru -Rns'
alias pkglist='paru -Qe > ~/pkglist.txt'

#═══════════════════════════════════════════════════════════════════════════════
# CLIPBOARD MANAGEMENT
#═══════════════════════════════════════════════════════════════════════════════

if command -v xclip >/dev/null 2>&1; then
  alias tocp='xclip -selection clipboard'
  alias fromcp='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
  alias tocp='xsel --clipboard --input'
  alias fromcp='xsel --clipboard --output'
else
  echo "Neither xclip nor xsel found. Please install one of them."
  alias tocp='echo "No clipboard provider installed (xclip/xsel required)"'
  alias fromcp='echo "No clipboard provider installed (xclip/xsel required)"'
fi

alias cf='cat $1 | xclip -sel c'

#═══════════════════════════════════════════════════════════════════════════════
# FZF INTEGRATION
#═══════════════════════════════════════════════════════════════════════════════

alias vif='vim $(fzf)'
alias rgf='vim $(rg . | fzf | cut -d ":" -f 1)'
alias rgfzf='rg . | fzf'
alias calibre='fzf-calibre'
alias b='fzf-calibre'

# Search and cd into directory
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# Search with ripgrep and fzf
fstring() {
  local file_and_line=$(
    rg --color=always --line-number --no-heading --smart-case "${1:-}" |
      fzf --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
          --preview-window 'right,60%,border-bottom,+{2}+3/3,~3'
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

# Case-sensitive search
FSTRING() {
  local file_and_line=$(
    rg --color=always \
       --line-number \
       --no-heading \
       --case-sensitive \
       --fixed-strings \
       --word-regexp \
       "${1:-}" |
      fzf --ansi \
          --exact \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
          --preview-window 'right,60%,border-bottom,+{2}+3/3,~3'
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

#═══════════════════════════════════════════════════════════════════════════════
# SYSTEM MONITORING AND UTILITIES
#═══════════════════════════════════════════════════════════════════════════════

alias k='pkill -9'
alias bl='xbacklight -get'
alias dsize='du -hsx * | sort -rh'
alias neofetch='fastfetch'
alias open='handlr open'
alias cat='bat'
alias disks='gdu'

# Disk usage overview
alias duf='echo "╓───── m o u n t . p o i n t s"; \
			 echo "╙────────────────────────────────────── ─ ─ "; \
			 lsblk -a; echo ""; \
			 echo "╓───── d i s k . u s a g e";\
			 echo "╙────────────────────────────────────── ─ ─ "; \
			 df -h;'

# Improved commands
alias df='df -h'
alias free='free -m'
alias mocp='mocp -M "$XDG_CONFIG_HOME"/moc -O MOCDir="$XDG_CONFIG_HOME"/moc'

#═══════════════════════════════════════════════════════════════════════════════
# PROCESS MANAGEMENT
#═══════════════════════════════════════════════════════════════════════════════

alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

#═══════════════════════════════════════════════════════════════════════════════
# COMPRESSION AND EXTRACTION
#═══════════════════════════════════════════════════════════════════════════════

alias zip='zip -r'
alias xz='xz -z -v -k -T 0'

# Compression function
compress() {
    if [[ $# -eq 0 ]]; then
        echo "Error: Please provide a directory path"
        return 1
    fi

    local dir_path="$1"

    if [[ ! -d "$dir_path" ]]; then
        echo "Error: '$dir_path' is not a directory"
        return 1
    fi

    local dir_name=$(basename "$dir_path")
    local zip_file="${dir_name}.zip"

    if zip -r "$zip_file" "$dir_path"; then
        echo "Successfully compressed '$dir_path' into '$zip_file'"
    else
        echo "Error: Failed to compress '$dir_path'"
        return 1
    fi
}

# Extract function
extract() {
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

# Extract to folder
extractf() {
  if [ -f "$1" ] ; then
    local dirname="${1%.*}"
    mkdir -p "$dirname"
    cd "$dirname"

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
    cd ..
  else
    echo "File '$1' not found"
  fi
}

# Extract all compressed files in current directory
extractfall() {
  setopt +o nomatch
  local files=(*.tar.bz2 *.tar.gz *.bz2 *.rar *.gz *.tar *.tbz2 *.tgz *.zip *.Z *.7z)
  setopt nomatch

  if [ ${#files[@]} -eq 0 ]; then
    echo "No se encontraron archivos comprimidos en el directorio actual"
    return
  fi

  for file in "${files[@]}"; do
    if [ -f "$file" ]; then
      extractf "$file"
    fi
  done
}

#═══════════════════════════════════════════════════════════════════════════════
# DOCKER
#═══════════════════════════════════════════════════════════════════════════════

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

# Docker functions
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

#═══════════════════════════════════════════════════════════════════════════════
# TMUX
#═══════════════════════════════════════════════════════════════════════════════

function t() {
	X=$#
	[[ $X -eq 0 ]] || X=X
	tmux new-session -A -s $X
}

#═══════════════════════════════════════════════════════════════════════════════
# NETWORK AND IP
#═══════════════════════════════════════════════════════════════════════════════

alias ip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"
alias ip_info="curl -qs https://ifconfig.co/json | jq -r '.ip,.city,.country,.hostname,.asn_org'"
alias localip='ip -brief -color address'
alias wttr='curl -4 wttr.in'
alias network='nmtui'

#═══════════════════════════════════════════════════════════════════════════════
# SYSTEM SERVICES
#═══════════════════════════════════════════════════════════════════════════════

alias stopB='sudo systemctl stop bluetooth.service'
alias startB='sudo systemctl start bluetooth.service && bluetoothctl'
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias restart='sudo systemctl restart'

#═══════════════════════════════════════════════════════════════════════════════
# MEDIA AND DOWNLOAD
#═══════════════════════════════════════════════════════════════════════════════

alias pdfconvert='gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf'
alias ytp='yt-dlp -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'

# YouTube download aliases
alias ytpa='noglob yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 --output "%(title)s.%(ext)s" --yes-playlist'
alias yta='noglob yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 --output "%(title)s.%(ext)s"'
alias yta-best='noglob yt-dlp --extract-audio --audio-format wav --audio-quality 0 --output "%(title)s.%(ext)s"'
alias ytp-abest='noglob yt-dlp --extract-audio --audio-format wav --audio-quality 160K --output "%(title)s.%(ext)s" --yes-playlist'
alias ytv-best='noglob yt-dlp -f bestvideo+bestaudio'

alias spotdl='spotdl --cookie-file /home/alex/Music/music.youtube.com_cookies.txt'

# Playlist function
mkplaylist() {
   ls -1 *.mkv | sort > playlist.txt
   mpv --playlist="playlist.txt"
}

#═══════════════════════════════════════════════════════════════════════════════
# ARIA2 INTEGRATION
#═══════════════════════════════════════════════════════════════════════════════

alias magnet2aria='function _magnet2aria() { curl --header "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.addUri\",\"id\":\"qwer\",\"params\":[[\"$1\"]]}" http://localhost:6800/jsonrpc; }; _magnet2aria'
alias link2aria='function _link2aria() { curl --header "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.addUri\",\"id\":\"qwer\",\"params\":[[\"$1\"]]}" http://localhost:6800/jsonrpc; }; _link2aria'

alias aria2list='
echo "=== ACTIVE DOWNLOADS ===";
curl -s --header "Content-Type: application/json" \
     --data "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.tellActive\",\"id\":\"qwer\"}" \
     http://localhost:6800/jsonrpc | \
jq -r ".result[] | \"[\(.status)] \(.bittorrent.info.name // .files[0].path): \
\((.completedLength|tonumber)/(.totalLength|tonumber) * 100 | floor)% - \
\((.completedLength|tonumber)/1048576)MB/\((.totalLength|tonumber)/1048576)MB - \
\((.downloadSpeed|tonumber)/1048576)MB/s - \
Up: \((.uploadLength|tonumber)/1048576)MB\"";

echo -e "\n=== WAITING DOWNLOADS ===";
curl -s --header "Content-Type: application/json" \
     --data "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.tellWaiting\",\"id\":\"qwer\",\"params\":[0,100]}" \
     http://localhost:6800/jsonrpc | \
jq -r ".result[] | \"[\(.status)] \(.bittorrent.info.name // .files[0].path): \
\((.completedLength|tonumber)/(.totalLength|tonumber) * 100 | floor)% - \
\((.completedLength|tonumber)/1048576)MB/\((.totalLength|tonumber)/1048576)MB - \
Up: \((.uploadLength|tonumber)/1048576)MB\"";

echo -e "\n=== COMPLETED DOWNLOADS ===";
curl -s --header "Content-Type: application/json" \
     --data "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.tellStopped\",\"id\":\"qwer\",\"params\":[0,100]}" \
     http://localhost:6800/jsonrpc | \
jq -r ".result[] | \"[\(.status)] \(.bittorrent.info.name // .files[0].path): \
\((.completedLength|tonumber)/(.totalLength|tonumber) * 100 | floor)% - \
\((.completedLength|tonumber)/1048576)MB/\((.totalLength|tonumber)/1048576)MB - \
Up: \((.uploadLength|tonumber)/1048576)MB\"";
'

#═══════════════════════════════════════════════════════════════════════════════
# ANDROID
#═══════════════════════════════════════════════════════════════════════════════

alias uAndroid='adb shell pm uninstall -k --user 0'
alias pullAndroid='cd $HOME/Pictures/Android && adb pull /storage/emulated/0/Pictures && adb pull /storage/emulated/0/Dcim'

#═══════════════════════════════════════════════════════════════════════════════
# SYSTEM INFO
#═══════════════════════════════════════════════════════════════════════════════

alias version='lsb_release -a'
alias kernel='uname -r'
alias zplugins='ls $ZPLUGINDIR'

#═══════════════════════════════════════════════════════════════════════════════
# MIRRORS AND REFLECTOR
#═══════════════════════════════════════════════════════════════════════════════

alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

#═══════════════════════════════════════════════════════════════════════════════
# GREP WITH COLORS
#═══════════════════════════════════════════════════════════════════════════════

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias g="grep --color=auto -i"

#═══════════════════════════════════════════════════════════════════════════════
# POLYBAR AND DESKTOP
#═══════════════════════════════════════════════════════════════════════════════

alias rpolybar='~/.config/polybar/launch.sh'

#═══════════════════════════════════════════════════════════════════════════════
# JOURNALCTL
#═══════════════════════════════════════════════════════════════════════════════

alias jctl="journalctl -p 3 -xb"

#═══════════════════════════════════════════════════════════════════════════════
# GPG
#═══════════════════════════════════════════════════════════════════════════════

alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

#═══════════════════════════════════════════════════════════════════════════════
# SHELL SWITCHING
#═══════════════════════════════════════════════════════════════════════════════

alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"

#═══════════════════════════════════════════════════════════════════════════════
# FILE OPERATIONS
#═══════════════════════════════════════════════════════════════════════════════

# File lookup function
lookup() {
  if [[ $# -eq 0 ]]; then
      echo "Error: Please provide a string to search for"
      return 1
  fi

  local search_string="$1"
  find . -type f -iname "*$search_string*" -print
}

#═══════════════════════════════════════════════════════════════════════════════
# NTFS MOUNTING
#═══════════════════════════════════════════════════════════════════════════════

mount_ntfs() {
    sudo mkdir -p /mnt/external

    local drives=($(lsblk -o NAME,FSTYPE -n -l | grep "ntfs" | awk '{print $1}'))

    if [ ${#drives[@]} -eq 0 ]; then
        echo "❌ No NTFS hard drive connected"
        return 1
    fi

    echo "💾 Discos NTFS encontrados:"
    local i=1
    for drive in "${drives[@]}"; do
        local label=$(lsblk -o NAME,LABEL -n -l | grep "$drive" | awk '{$1=""; print $0}' | xargs)
        local size=$(lsblk -o NAME,SIZE -n -l | grep "$drive" | awk '{print $2}')
        echo "[$i] /dev/$drive (${label:-Sin etiqueta}, $size)"
        ((i++))
    done

    local selected_drive
    if [ ${#drives[@]} -gt 1 ]; then
        echo "\nNumber of disk to mount (1-${#drives[@]}):"
        read -k 1 selection
        if [[ $selection -lt 1 ]] || [[ $selection -gt ${#drives[@]} ]]; then
            echo "\n❌ Invalid selection"
            return 1
        fi
        selected_drive="/dev/${drives[$selection-1]}"
    else
        selected_drive="/dev/${drives[0]}"
    fi

    sudo umount $selected_drive 2>/dev/null
    sudo fuser -k $selected_drive 2>/dev/null

    echo "\n🔧 Repairing disk..."
    sudo ntfsfix $selected_drive
    echo "🚀 Mounting..."
    if sudo mount -t ntfs-3g -o rw,uid=$(id -u),gid=$(id -g),windows_names $selected_drive /mnt/external; then
        echo "✅ Mounted in /mnt/external"
    else
        echo "❌ Error"
        return 1
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# MISC ALIASES
#═══════════════════════════════════════════════════════════════════════════════

alias btc='better-commits'
alias webToPdf='curl -u 'api:
