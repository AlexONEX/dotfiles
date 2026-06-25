#!/bin/bash
# ensure-eqmac-output.sh
# Ensures the eqMac virtual device is the default audio output.
# Runs at login to guarantee seamless audio processing.
# Can also be run manually if audio stops routing through eqMac.
#
# Retries with backoff because at login, CoreAudio might not be fully ready yet.

EQMAC_DEVICE_PATTERN="eqMac"
MAX_RETRIES=12  # ~60s total wait with backoff

log() {
    echo "[eqmac] $(date '+%H:%M:%S') $1"
}

# Find the eqMac virtual output device
find_eqmac_device() {
    SwitchAudioSource -a -t output 2>/dev/null | grep -i "$EQMAC_DEVICE_PATTERN" | head -1
}

# Set a device as the default output
set_default_output() {
    local device_name="$1"
    if SwitchAudioSource -s "$device_name" -t output 2>/dev/null; then
        log "✅ Default output set to: $device_name"
        return 0
    else
        log "⚠️ Could not set default to: $device_name"
        return 1
    fi
}

main() {
    log "🔊 Ensuring eqMac is the default audio output..."

    local attempt=1
    while [ $attempt -le $MAX_RETRIES ]; do
        local eqmac_device
        eqmac_device=$(find_eqmac_device)

        if [ -n "$eqmac_device" ]; then
            local current_default
            current_default=$(SwitchAudioSource -c -t output 2>/dev/null)

            if [ "$current_default" = "$eqmac_device" ]; then
                log "✅ eqMac already default: $eqmac_device"
                return 0
            else
                log "🔄 Attempt $attempt: Switching to '$eqmac_device'..."
                if set_default_output "$eqmac_device"; then
                    return 0
                fi
            fi
        else
            log "⏳ Attempt $attempt: eqMac device not found yet"
            SwitchAudioSource -a -t output 2>/dev/null | while read -r line; do
                log "   available: $line"
            done
        fi

        sleep $((attempt * 2))  # backoff: 2, 4, 6, 8... seconds
        attempt=$((attempt + 1))
    done

    log "❌ Failed to set eqMac as default after $MAX_RETRIES attempts"
    return 1
}

main
