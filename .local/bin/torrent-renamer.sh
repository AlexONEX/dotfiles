#!/bin/bash
# torrent-renamer.sh - Rename torrent files according to their internal name
# Bash version of Jimmy-Z's JavaScript script
# Usage: ./torrent-renamer.sh [directory]

set -e

# Default to current directory if none specified
TARGET_DIR="${1:-.}"
EXT_TORRENT=".torrent"

# Function to extract the 'name' field from a .torrent file
# This uses python as a helper since bash isn't great for binary parsing
extract_torrent_name() {
    local torrent_file="$1"
    python3 -c '
import sys
import bencodepy
import os

torrent_file = sys.argv[1]
try:
    with open(torrent_file, "rb") as f:
        torrent_data = bencodepy.decode(f.read())

    if b"info" in torrent_data and b"name" in torrent_data[b"info"]:
        name = torrent_data[b"info"][b"name"].decode("utf-8", errors="replace")
        print(name)
    else:
        print("")
except Exception as e:
    print("", file=sys.stderr)
    sys.exit(1)
' "$torrent_file"
}

# Function to sanitize filename (remove characters not allowed in Windows)
sanitize_filename() {
    local filename="$1"
    # Replace Windows-forbidden characters with underscores
    echo "$filename" | sed 's/[<>:"\/\\|?*]/_/g'
}

# Function to rename a torrent file
rename_torrent_file() {
    local torrent_file="$1"
    local dir_path=$(dirname "$torrent_file")
    local base_name=$(basename "$torrent_file")

    # Skip if not a .torrent file
    if [[ ! "$base_name" == *$EXT_TORRENT ]]; then
        return
    fi

    # Extract torrent name from the file
    local torrent_name=$(extract_torrent_name "$torrent_file")

    # If extraction failed, skip this file
    if [[ -z "$torrent_name" ]]; then
        echo "Failed to extract name from $torrent_file, skipping"
        return
    fi

    # Sanitize the filename
    torrent_name=$(sanitize_filename "$torrent_name")
    local new_name="${torrent_name}${EXT_TORRENT}"
    local new_path="${dir_path}/${new_name}"

    # Skip if the name is already correct
    if [[ "$base_name" == "$new_name" ]]; then
        echo "$torrent_file already has the correct name."
        return
    fi

    echo "Renaming: $torrent_file -> $new_path"

    # Check if target file already exists
    if [[ -f "$new_path" ]]; then
        echo "  Target file already exists, checking if identical..."

        if cmp -s "$torrent_file" "$new_path"; then
            echo "  Files are identical, removing duplicate"
            rm "$torrent_file"
        else
            echo "  Files are different, keeping both"
            # Create a unique name by adding a number
            local counter=1
            local unique_name

            while true; do
                unique_name="${torrent_name}_${counter}${EXT_TORRENT}"
                local unique_path="${dir_path}/${unique_name}"

                if [[ ! -f "$unique_path" ]]; then
                    echo "  Renaming to $unique_path instead"
                    mv "$torrent_file" "$unique_path"
                    break
                fi

                ((counter++))
            done
        fi
    else
        # Just rename the file
        mv "$torrent_file" "$new_path"
    fi
}

# Main script

# Check if the bencodepy package is installed
if ! python3 -c "import bencodepy" &>/dev/null; then
    echo "Error: Python 'bencodepy' package is required but not installed."
    echo "Please install it with: pip3 install bencodepy"
    exit 1
fi

# Process all torrent files in the target directory
find "$TARGET_DIR" -type f -name "*$EXT_TORRENT" -print0 | while IFS= read -r -d $'\0' file; do
    rename_torrent_file "$file"
done

echo "Finished processing torrent files in $TARGET_DIR"
