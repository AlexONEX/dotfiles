#!/bin/bash
playlistDownloader(){
    local input=""
    if [[ -p /dev/stdin ]]; then
        input="$(cat -)"
    else
        input="${@}"
    fi

    if [[ -z "${input}" ]]; then
        return 1
    fi

    yt-dlp -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "{$input}"
}
