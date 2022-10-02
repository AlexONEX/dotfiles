#!/bin/bash
local input=""

  if [[ -p /dev/stdin ]]; then
    input="$(cat -)"
  else
    input="${@}"
  fi

  if [[ -z "${input}" ]]; then
    return 1
  fi
yt-dlp --extract-audio --audio-format "wav" "{input}"
