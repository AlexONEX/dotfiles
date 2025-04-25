#!/bin/bash
    # aria2-download-complete-handler.sh
# This script is called by aria2 when a download completes

# Log file for debugging
LOG_FILE="${HOME}/.config/aria2/event-handler.log"

# Function to log messages
log_message() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG_FILE"
}

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Log start of handler
log_message "Download complete handler started with args: $*"

# Get parameters from aria2
GID="$1"
FILE_NUM="$2"
FILE_PATH="$3"

# Log the download details
log_message "GID: $GID, File Number: $FILE_NUM, File Path: $FILE_PATH"

# Check if we're dealing with a magnet link that saved metadata
if [[ "$GID" == *".torrent"* ]]; then
  log_message "This appears to be a torrent metadata file: $GID"

  # Path to your torrent directory (where .torrent files are saved)
  TORRENT_DIR="${HOME}/Downloads/Torrents"

  # Run the torrent renamer script
  log_message "Running torrent renamer on ${TORRENT_DIR}"
  "${HOME}/.local/bin/torrent-renamer.sh" "${TORRENT_DIR}"

  log_message "Torrent renamer completed"
fi

log_message "Download complete handler finished"
exit 0
