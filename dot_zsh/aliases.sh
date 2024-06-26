alias hacker-news='hackernews_tui'

paru() {
    command nice -n 10 ionice -c 3 /usr/bin/paru "$@"
}

man() {
  if [ $# -eq 0 ]; then
    echo "Usage: man <command>"
    return 1
  fi
  command man "$1" | col -bx | bat -l man -p
}


alias r='exec zsh'
alias rf='rm -rf'
alias a='nvim ~/.zsh/aliases.sh'
alias t='$EDITOR $HOME/.config/tmux/tmux.conf'
alias j='goto'
alias nvimdiff='nvim -d'
alias zplugins='ls $ZPLUGINDIR'

alias dotsadd='cd $HOME && chezmoi add .zshrc .zsh/aliases.sh && chezmoi add .docker && chezmoi add .gitconfig && cd ~/.config && chezmoi add alacritty easyeffects i3 flameshot polybar tmux/tmux.conf zathura && cd nvim/lua/custom && cd /home/alex/.local/share/chezmoi && cd ~/.local/bin/'
alias frmcp='xclip -c'
alias tocp='xclip -sel c'
alias calibre='fzf-calibre'
alias k='pkill -9'


alias dsize='du -hsx * | sort -rh'
alias neofetch='fastfetch'
alias open='handlr open'
alias c='clear'
alias vim='nvim'
alias cat='bat'

alias purge='paru -Rsn'

#Alias cd
alias cd..='cd ..'
alias ..='cd..'

# Compress
alias zip='zip -r'
alias xz='xz -z -v -k -T 0'

# Docker 
# support Compose v2 as docker CLI plugin

# Detectar si docker-compose está disponible o si se debe usar docker compose
if type docker-compose > /dev/null 2>&1; then
    dccmd='docker-compose'
elif type docker > /dev/null 2>&1 && docker compose version > /dev/null 2>&1; then
    dccmd='docker compose'
else
    echo "Neither docker-compose nor docker compose command is available."
    return 1
fi

# Definir funciones en lugar de alias para evitar problemas de expansión
dcrm() { $dccmd rm "$@"; }
dcr() { $dccmd run "$@"; }
dcstop() { $dccmd stop "$@"; }
dcup() { $dccmd up "$@"; }
dcupb() { $dccmd up --build "$@"; }
dcupd() { $dccmd up -d "$@"; }
dcupdb() { $dccmd up -d --build "$@"; }
dcdn() { $dccmd down "$@"; }
dcl() { $dccmd logs "$@"; }
dclf() { $dccmd logs -f "$@"; }
dclF() { $dccmd logs -f --tail 0 "$@"; }
dcpull() { $dccmd pull "$@"; }
dcstart() { $dccmd start "$@"; }
dck() { $dccmd kill "$@"; }

# Eliminar dccmd para evitar su uso directo
#unset dccmd

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
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l='exa -a | grep -e "^\."'

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
alias tobash='sudo chsh $USER -s /bin/bash && echo "Now log out."'
alias tozsh='sudo chsh $USER -s /bin/zsh && echo "Now log out."'

#yta-best-mp3
function yta(){
    yt-dlp --extract-audio --audio-format "$2" --audio-quality 0 --output "%(title)s.%(ext)s" "$1"
}

function ytpa(){
    yt-dlp --extract-audio --audio-format "$2" --audio-quality 0 --output "%(title)s.%(ext)s" --yes-playlist "$1"
}

alias yta-best='yt-dlp --extract-audio --audio-format "wav"'
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

function dockrestart(){
      docker restart $(docker ps -aq)
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

alias docker-clean='docker system prune -a --volumes'
alias docstats="docker ps -q | xargs  docker stats --no-stream"

function t() {
	X=$#
	[[ $X -eq 0 ]] || X=X
	tmux new-session -A -s $X
}

extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar x $1       ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *.xz)        xz -d $1       ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi 
}
extractf() {
  if [ -f "$1" ]; then
    # Get the filename without extension
    folder_name="${1%.*}"
    case $1 in
      *.tar.bz2)   tar xjf "$1" -C "$folder_name" ;;
      *.tar.gz)    tar xzf "$1" -C "$folder_name" ;;
      *.bz2)       bunzip2 "$1" -C "$folder_name" ;;
      *.rar)       unrar x "$1" "$folder_name" ;;
      *.gz)        gunzip "$1" -C "$folder_name" ;;
      *.tar)       tar xf "$1" -C "$folder_name" ;;
      *.tbz2)      tar xjf "$1" -C "$folder_name" ;;
      *.tgz)       tar xzf "$1" -C "$folder_name" ;;
      *.zip)       unzip "$1" -d "$folder_name" ;;
      *.Z)         uncompress "$1" -C "$folder_name" ;;
      *.7z)        7z x "$1" -o"$folder_name" ;;
      *.xz)        xz -d "$1" -C "$folder_name" ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

webToPDF() {
    # Solicitar al usuario la fuente y el título del PDF
    echo "Introduce la URL de la fuente:"
    read source
    echo "Introduce el título del PDF:"
    read title

    # Usar curl para convertir la fuente en PDF
    curl \
        -u 'api:3e5153da1ecd4259af582ca739c2971a' \
        -H 'Content-Type: application/json' \
        -d "{\"source\":\"$source\",\"landscape\":false,\"use_print\":false}" \
        https://api.pdfshift.io/v3/convert/pdf/ \
        -o "${title}.pdf"

    echo "PDF guardado como ${title}.pdf"
}
