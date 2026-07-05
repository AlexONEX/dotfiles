# SHORTCUTS
alias dotfiles='~/dotfiles/scripts/sync_dotfiles.sh'
alias ls='ls -alFG'
alias initpy='touch __init__.py'
alias btc='better-commits'
alias emacst='emacsclient -t -a'

bak() {
    cp -r "$1" "$1.bak"
}

brew() {
    nice -n 10 $(command -v brew) "$@"
}

brew-clean() {
  echo "Updating the system..."
  brew update && brew upgrade

  echo "Current cache size:"
  du -sh "$(brew --cache)"

  echo "Cleaning old packages and cache..."
  brew cleanup --prune=all

  echo "Emptying downloads cache..."
  rm -rf "$(brew --cache)/downloads" 2>/dev/null

  echo "Checking for large cache directories..."
  cache_dir=$(brew --cache)
  large_dirs=$(find "$cache_dir" -type d -exec du -sm {} \; | sort -nr | head -10)
  echo "Largest cache directories (MB):"
  echo "$large_dirs"

  echo "Removing orphaned packages..."
  brew autoremove

  echo "Manually installed packages (not dependencies):"
  brew leaves

  # Review optional packages
  unused_pkgs=$(brew leaves)
  if [ -n "$unused_pkgs" ]; then
    echo "The following manually installed packages were found:"
    echo "$unused_pkgs"
    echo "Do you want to review and remove any? (y/N) "
    read response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo "List of packages to review:"
      select pkg in $unused_pkgs "Exit"; do
        if [ "$pkg" = "Exit" ]; then
          break
        elif [ -n "$pkg" ]; then
          echo "Do you want to uninstall $pkg? (y/N) "
          read remove
          if [[ "$remove" =~ ^[Yy]$ ]]; then
            echo "Removing $pkg..."
            brew uninstall "$pkg"
          fi
        fi
      done
    else
      echo "No packages were removed."
    fi
  else
    echo "No manually installed packages found."
  fi

  # Check for and remove unneeded bottle files
  echo "Looking for large bottle files..."
  large_bottles=$(find "$(brew --cache)" -name "*.bottle.*" -size +100M | sort)
  if [ -n "$large_bottles" ]; then
    echo "Found large bottle files:"
    echo "$large_bottles"
    echo "Do you want to remove these large bottle files? (y/N) "
    read remove_bottles
    if [[ "$remove_bottles" =~ ^[Yy]$ ]]; then
      find "$(brew --cache)" -name "*.bottle.*" -size +100M -delete
      echo "Large bottle files removed."
    fi
  else
    echo "No large bottle files found."
  fi

  # Option to purge the complete cache in extreme cases
  echo "Current cache size after cleanup:"
  du -sh "$(brew --cache)"

  echo "Do you want to completely purge the Homebrew cache? (Only use in extreme cases) (y/N) "
  read purge_cache
  if [[ "$purge_cache" =~ ^[Yy]$ ]]; then
    echo "WARNING: This will delete ALL cached Homebrew files!"
    echo "Are you absolutely sure? (y/N) "
    read confirm_purge
    if [[ "$confirm_purge" =~ ^[Yy]$ ]]; then
      rm -rf "$(brew --cache)"/*
      echo "Homebrew cache completely purged!"
    else
      echo "Complete cache purge cancelled."
    fi
  fi

  echo "Checking for Homebrew issues..."
  brew doctor

  echo "Cleanup completed. Current cache size:"
  du -sh "$(brew --cache)"
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

alias j='goto'
alias zplugins='ls $ZPLUGINDIR'
alias dotsadd='cd $HOME && chezmoi add .zshrc .zsh/aliases.zsh && cd ~/.config && chezmoi add alacritty easyeffects i3 flameshot polybar tmux/tmux.conf zathura && cd nvim/lua/custom && cd /home/alex/.local/share/chezmoi'

alias z='$EDITOR ~/.zshrc'
alias ct='$EDITOR ~/.config/tmux/tmux.conf'

alias cf='cat $1 | xclip -sel c'
alias calibre='fzf-calibre'

if command -v xclip >/dev/null 2>&1; then
  alias tocp='xclip -selection clipboard'
  alias fromcp='xclip -selection clipboard -o'
elif command -v xsel >/dev/null 2>&1; then
  alias tocp='xsel --clipboard --input'
  alias fromcp='xsel --clipboard --output'
else
  echo "Neither xclip nor xsel found. Please install one of them."
  # Create dummy aliases that show error message
  alias tocp='echo "No clipboard provider installed (xclip/xsel required)"'
  alias fromcp='echo "No clipboard provider installed (xclip/xsel required)"'
fi

logcmd() {
    "$@" > log_output.txt 2>&1
}

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

alias k='pkill -9'
alias bl='xbacklight -get'

alias dsize='du -hsx * | sort -rh'
alias neofetch='fastfetch'
alias c='clear'
alias vim='nvim'
alias cat='bat'

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
alias purge='brew uninstall'
alias u='brew update && brew upgrade'
alias i='brew install'

alias uAndroid='adb shell pm uninstall -k --user 0'
alias pullAndroid='cd $HOME/Pictures/Android && adb pull /storage/emulated/0/Pictures && adb pull /storage/emulated/0/Dcim'
alias network='nmtui'
alias version='lsb_release -a'
alias kernel='uname -r'
alias localip='ip -brief -color address'
alias wttr='curl -4 wttr.in'
alias rpolybar='~/.config/polybar/launch.sh'


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
mkplaylist() {
   ls -1 *.mkv | sort > playlist.txt
   mpv --playlist="playlist.txt"
}

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
alias spotdl='spotdl --cookie-file /home/alex/Music/music.youtube.com_cookies.txt'

# YouTube download max quality (video + audio)
ytd() {
    yt-dlp -f "bestvideo+bestaudio" --merge-output-format mp4 -o "%(title)s.%(ext)s" "$1"
}

alias disks='ncdu'

function docker-clean() {
  docker ps -aq | xargs -r docker stop
  docker ps -a -q | xargs -r docker rm
  #docker volume ls -q | xargs -r docker volume rm
  docker builder prune
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
    cd ..
  else
    echo "File '$1' not found"
  fi
}

extractfall() {
  # Desactivar 'nomatch' temporalmente
  setopt +o nomatch

  # Encontrar todos los archivos comprimidos en el directorio actual
  local files=(*.tar.bz2 *.tar.gz *.bz2 *.rar *.gz *.tar *.tbz2 *.tgz *.zip *.Z *.7z)

  # Restaurar 'nomatch'
  setopt nomatch

  # Verificar si hay archivos que procesar
  if [ ${#files[@]} -eq 0 ]; then
    echo "No se encontraron archivos comprimidos en el directorio actual"
    return
  fi

  # Procesar cada archivo encontrado
  for file in "${files[@]}"; do
    if [ -f "$file" ]; then
      extractf "$file"
    fi
  done
}


tomp4() {
  ffmpeg -i "$1" -c:v libx264 -preset fast -crf 22 -c:a aac -b:a 192k "${1%.*}.mp4"
}

compile-slides() {
  npx @marp-team/marp-cli@latest "$1" --pdf
}

# ===== GEMINI MCP ALIASES =====
alias gmcp='gemini mcp list'
alias gmcp-status='gemini mcp list && echo "\nMCP Config:" && cat ~/.gemini/settings.json | grep -A 20 mcpServers'

alias bcra-vars='curl https://api.bcra.gob.ar/estadisticas/v4.0/Monetarias > output.json'

# ===== BYMA TOKEN =====
# Obtiene un access token de BYMA con todos los scopes (snapshot.read + marketDataInstruments.read)
# leyendo credenciales del secret application/market-data en AWS (profile development)
byma-token() {
  local profile="${1:-development}"
  local byma_url="${BYMA_URL:-https://apigw.byma.com.ar}"

  echo "Reading credentials from AWS Secrets Manager (profile: $profile)..." >&2
   local secret
   secret=$(aws secretsmanager get-secret-value \
     --secret-id application/market-data \
     --profile "$profile" \
     --query 'SecretString' \
     --output text 2>/dev/null) || {
     echo "Error: Could not read secret application/market-data with profile '$profile'" >&2
     return 1
   }

  local client_id
  local client_secret
  client_id=$(echo "$secret" | jq -r '.byma_client_id')
  client_secret=$(echo "$secret" | jq -r '.byma_client_secret')

  if [[ -z "$client_id" || "$client_id" == "null" ]]; then
     echo "Error: byma_client_id not found in secret" >&2
     return 1
   fi

   echo "Requesting token with scopes: snapshot.read marketDataInstruments.read ..." >&2
   local response
   response=$(curl -s -X POST "$byma_url/oauth/token/" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "client_id=$client_id" \
     -d "client_secret=$client_secret" \
     -d "grant_type=client_credentials" \
     -d "scope=snapshot.read marketDataInstruments.read") || {
     echo "Error getting token from BYMA" >&2
     return 1
   }

   local error
   error=$(echo "$response" | jq -r '.error // empty')
   if [[ -n "$error" ]]; then
     echo "BYMA error: $error — $(echo "$response" | jq -r '.error_description // ""')" >&2
     return 1
   fi

   local access_token
   access_token=$(echo "$response" | jq -r '.access_token')

   echo "Token obtained (expires in $(echo "$response" | jq -r '.expires_in') seconds)" >&2
   echo "$access_token"
}

# Alias con shorthand — usa profile development por defecto
alias byma-token-dev='byma-token development'
alias byma-token-prod='byma-token production'

# Helper: copy token to clipboard
byma-token-copy() {
   local token
   token=$(byma-token "$@") && echo "$token" | pbcopy && echo "Token copied to clipboard"
}

# Helper: export token as BYMA_TOKEN env var
byma-token-export() {
   export BYMA_TOKEN=$(byma-token "$@")
   echo "BYMA_TOKEN set in environment"
}

# ===== BYMA MARKET DATA INSTRUMENTS =====
# GET /market-data-instruments/v1/{type}?group={group}&market={market}
# USO: byma-market-data-instruments <type> <group> [market] [profile]
#   type: equities.json, fixed-income.json, options.json
#   group: ACCIONES, CEDEARS, TITULOSPUBLICOS, LETRAS, OPCIONES, etc.
#   market: PPT (default para fixed-income), opcional para equities
#   profile: development (default), production
byma-market-data-instruments() {
  local type="${1:?Uso: byma-market-data-instruments <type> <group> [market] [profile]}"
  local group="${2:?Falta group: ACCIONES, CEDEARS, etc}"
  local market="${3:-}"
  local profile="${4:-development}"
  local byma_url="${BYMA_URL:-https://apigw.byma.com.ar}"

   local token="${BYMA_TOKEN}"
   if [[ -z "$token" ]]; then
     echo "BYMA_TOKEN not in environment, fetching..." >&2
     token=$(byma-token "$profile") || return 1
   fi

   local url="$byma_url/market-data-instruments/v1/$type?group=$group"
   [[ -n "$market" ]] && url="$url&market=$market"

   echo "GET $url" >&2
  curl -s --request GET "$url" \
    --header "Authorization: Bearer $token" | jq .
}

# Shorthands para equities
alias byma-mdi-equities-acciones='byma-market-data-instruments equities.json ACCIONES'
alias byma-mdi-equities-cedears='byma-market-data-instruments equities.json CEDEARS'
alias byma-mdi-options='byma-market-data-instruments options.json OPCIONES'

# ===== BYMA FIXED INCOME ISSUANCE CONDITIONS =====
# GET /market-data-instruments/v1/fixed-income-issuance-conditions.json?symbol={symbol}
# USO: byma-mdi-issuance-conditions <symbol> [profile]
byma-mdi-issuance-conditions() {
  local symbol="${1:?Uso: byma-mdi-issuance-conditions <symbol> [profile]}"
  local profile="${2:-development}"
  local byma_url="${BYMA_URL:-https://apigw.byma.com.ar}"

  local token="${BYMA_TOKEN}"
  if [[ -z "$token" ]]; then
    echo "BYMA_TOKEN not in environment, fetching..." >&2
    token=$(byma-token "$profile") || return 1
  fi

  local url="$byma_url/market-data-instruments/v1/fixed-income-issuance-conditions.json/?symbol=$symbol"
  echo "GET $url" >&2
  curl -s --request GET "$url" \
    --header "Authorization: Bearer $token" | jq .
}
alias byma-mdi-condiciones='byma-mdi-issuance-conditions'

# ===== BYMA SNAPSHOT EQUITY =====
# Obtiene equity snapshot de BYMA
# USO: byma-snapshot-equity [group] [subgroup] [operativeForm] [profile]
#   group: ACCIONES (default), CEDEARS, OPCIONES
#   subgroup: GENERAL, LIDER (default: usa .raw/ endpoint = raw json)
#   operativeForm: CONTADO (default)
#   profile: development (default), production
#
# Si BYMA_TOKEN está exportado lo usa; si no, obtiene token automáticamente.
byma-snapshot-equity() {
  local group="${1:-ACCIONES}"
  local subgroup="${2:-}"
  local operative_form="${3:-CONTADO}"
  local profile="${4:-development}"
  local byma_url="${BYMA_URL:-https://apigw.byma.com.ar}"

   local token="${BYMA_TOKEN}"
   if [[ -z "$token" ]]; then
     echo "BYMA_TOKEN not in environment, fetching..." >&2
     token=$(byma-token "$profile") || return 1
   fi

   local url
   if [[ -z "$subgroup" ]]; then
     # Raw endpoint (flat response, no subgroup)
     url="$byma_url/snapshot/v1/equity.raw/?group=$group&operativeForm=$operative_form"
   else
     # Endpoint with subgroup (wrapped response)
     url="$byma_url/snapshot/v1/equity?group=$group&subgroup=$subgroup&operativeForm=$operative_form"
   fi
   echo "GET $url" >&2
  curl -s --request GET "$url" \
    --header "Authorization: Bearer $token" | jq .
}

# Shorthands (raw = sin subgroup)
alias byma-snapshot-equity-all='byma-snapshot-equity ACCIONES "" CONTADO'
alias byma-snapshot-equity-general='byma-snapshot-equity ACCIONES GENERAL CONTADO'
alias byma-snapshot-equity-leaders='byma-snapshot-equity ACCIONES LIDER CONTADO'
alias byma-snapshot-cedears='byma-snapshot-equity CEDEARS GENERAL CONTADO'

# ===== BYMA SNAPSHOT FIXED INCOME =====
# USO: byma-snapshot-fixed-income <group> [market] [operativeForm] [profile]
#   group*: TITULOSPUBLICOS, BONOSCONSOLIDACION, LETRAS, LETRASTESORO,
#           TITULOSDEUDA, CERTPARTICIPACION, OBLIGACIONESNEGOC, ONPYMES
#   market: PPT (default)
#   operativeForm: CONTADO (default)
#   profile: development (default), production
#
# Si BYMA_TOKEN está exportado lo usa; si no, obtiene token automáticamente.
byma-snapshot-fixed-income() {
  local group="${1:?Uso: byma-snapshot-fixed-income <group> [market] [operativeForm] [profile]\nGroups: TITULOSPUBLICOS, BONOSCONSOLIDACION, LETRAS, LETRASTESORO, TITULOSDEUDA, CERTPARTICIPACION, OBLIGACIONESNEGOC, ONPYMES}"
  local market="${2:-PPT}"
  local operative_form="${3:-CONTADO}"
  local profile="${4:-development}"
  local byma_url="${BYMA_URL:-https://apigw.byma.com.ar}"

  local token="${BYMA_TOKEN}"
  if [[ -z "$token" ]]; then
    echo "BYMA_TOKEN not in environment, fetching..." >&2
    token=$(byma-token "$profile") || return 1
  fi

  local url="$byma_url/snapshot/v1/fixed_income.raw/?group=$group&market=$market&operativeForm=$operative_form"
  echo "GET $url" >&2
  curl -s --request GET "$url" \
    --header "Authorization: Bearer $token" | jq .
}

# Shorthands
alias byma-snapshot-titulospublicos='byma-snapshot-fixed-income TITULOSPUBLICOS'
alias byma-snapshot-letras='byma-snapshot-fixed-income LETRAS'
alias byma-snapshot-titulosdeuda='byma-snapshot-fixed-income TITULOSDEUDA'
alias byma-snapshot-obligacionesnegoc='byma-snapshot-fixed-income OBLIGACIONESNEGOC'
alias byma-snapshot-onpymes='byma-snapshot-fixed-income ONPYMES'
alias byma-snapshot-bonosconsolidacion='byma-snapshot-fixed-income BONOSCONSOLIDACION'
alias byma-snapshot-letrastesoro='byma-snapshot-fixed-income LETRASTESORO'
alias byma-snapshot-certparticipacion='byma-snapshot-fixed-income CERTPARTICIPACION'

# ===== CLAUDE CODE MULTI-PROFILE MANAGEMENT =====
# Profiles: personal (teal), w = work (orange), ww = alt (lavender)
# Shared scripts in ~/.config/claude-profiles/

_claude_run() {
    local profile=$1
    shift
    local config_dir=$(jq -r --arg p "$profile" '.[$p].config_dir' "$HOME/.config/claude-profiles/profiles.json")
    if [[ "$config_dir" == "null" ]] || [[ -z "$config_dir" ]]; then
        echo "Unknown profile: $profile" >&2
        return 1
    fi
    # Write profile marker so context-bar picks it up
    echo "$profile" > "$HOME/.claude-profile"
    CLAUDE_CONFIG_DIR="$config_dir" claude "$@"
}

# Claude Code profile aliases
alias c-self='echo "personal" > "$HOME/.claude-profile" && CLAUDE_CONFIG_DIR=~/.claude claude'
alias c-alma='echo "alma" > "$HOME/.claude-profile" && CLAUDE_CONFIG_DIR=~/.claude-alma claude'
# Legacy aliases
alias claude-personal='c-self'
alias claude-alma='c-alma'

alias claude-profiles='bash ~/.config/claude-profiles/status.sh'

claude-use() {
    bash ~/.config/claude-profiles/switch-profile.sh "$@"
}

claude-whoami() {
     local cfg="${CLAUDE_CONFIG_DIR:-$HOME}"
     local user_id="?"
     if [[ -f "$cfg/.claude.json" ]]; then
         user_id=$(jq -r '.userID // "?"' "$cfg/.claude.json" | head -c 16)
     fi
     local profile="default"
     if [[ -f "$HOME/.claude-profile" ]]; then
         profile=$(cat "$HOME/.claude-profile")
     fi
     echo "Claude Profile: $profile"
     echo "   Config dir:     ${CLAUDE_CONFIG_DIR:-~/.claude.json}"
     echo "   User ID:        ${user_id}..."
}
# Load claude profile completion
if [[ -f "$HOME/.config/claude-profiles/completion.zsh" ]]; then
    source "$HOME/.config/claude-profiles/completion.zsh"
fi

# ===== MERIDIAN PROFILE SWITCHING FOR OPENCODE =====
# Switch profiles at runtime — OpenCode picks it up automatically

_oc_switch() {
    local profile=$1
    echo "$profile" > "$HOME/.claude-profile"
    meridian profile switch "$profile" 2>/dev/null && echo "Switched to: $profile" || echo "Meridian not running? Try: meridian-restart"
}

alias oc-self='_oc_switch personal'
alias oc-alma='_oc_switch alma'

oc-status() {
    local active
    active=$(jq -r '.activeProfile // "none"' "$HOME/.config/meridian/settings.json" 2>/dev/null || echo "none")
    echo "Currently active: $active"
    echo ""
    meridian profile list 2>/dev/null || echo "Meridian not running on :3456"
}

meridian-restart() {
    if launchctl list com.rynfar.meridian &>/dev/null; then
        echo "Restarting Meridian via launchd..."
        launchctl kickstart -kp com.rynfar.meridian 2>/dev/null
        sleep 3
    else
        echo "Launchd service not found, starting manually..."
        NODE_NO_WARNINGS=1 meridian &>/dev/null &
        sleep 3
    fi
    echo ""
    oc-status
}
