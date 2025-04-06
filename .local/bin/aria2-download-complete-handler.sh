#!/bin/sh

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${HOME}/.local/share/aria2/completion.log"
}

# Arguments passed by aria2:
# $1 - GID
# $2 - Number of files
# $3 - Path to the first file

# Remove .aria2 control file
rm -f "$3.aria2"

# Log the completed download
log "Download completed: $3"
log "GID: $1"
log "Number of files: $2"

# Optional: Send desktop notification
notify-send "Download Complete" "$(basename "$3")"

# Optional: Verify torrent integrity
if command -v ctorrent-checkfiles >/dev/null 2>&1; then
    ctorrent-checkfiles "$3"
fi

# Optional: Automatically seed with higher priority
if [ -f "$3" ]; then
    # If it's a torrent file, ensure continuous seeding
    if echo "$3" | grep -q "\.torrent$"; then
        aria2c --seed-time=525600 --seed-ratio=2.0 "$3"
    fi
fi
