#!/usr/bin/env python3
"""
Setup script for eqMac with Audio-Technica ATH-M40x AutoEq profile.
- Injects the ATH-M40x fixed-band EQ preset into eqMac preferences
- Enables the preset
- Configures eqMac for auto-start at login

Usage:
  python3 setup-eqmac-at40x.py          # Apply preset
  python3 setup-eqmac-at40x.py --reset  # Reset to flat EQ
"""

import json
import os
import plistlib
import subprocess
import sys
import uuid

PLIST_PATH = os.path.expanduser(
    "~/Library/Preferences/com.bitgapp.eqMac.plist"
)

EQMAC_APP = "/Applications/eqMac.app"

# ATH-M40x Fixed Band EQ settings from AutoEq (oratory1990, Harman over-ear 2018)
# Frequencies (ISO 10-band): 31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000 Hz
ATH_M40X_PRESET = {
    "gains": {
        "global": -3.2,
        "bands": [3.7, -1.6, -4.3, -0.3, 2.8, -0.5, -0.1, 3.3, -0.6, -12.0],
    },
    "id": str(uuid.uuid4()),
    "isDefault": False,
    "name": "Audio-Technica ATH-M40x",
}


def read_plist():
    """Read the eqMac plist file."""
    if not os.path.exists(PLIST_PATH):
        print(f"❌ eqMac plist not found at {PLIST_PATH}")
        print("   Make sure eqMac has been launched at least once.")
        sys.exit(1)

    with open(PLIST_PATH, "rb") as f:
        return plistlib.load(f)


def write_plist(plist):
    """Write the eqMac plist file."""
    # Create backup
    backup_path = PLIST_PATH + ".backup"
    if not os.path.exists(backup_path):
        with open(PLIST_PATH, "rb") as src, open(backup_path, "wb") as dst:
            dst.write(src.read())
        print(f"📦 Backup saved to {backup_path}")

    with open(PLIST_PATH, "wb") as f:
        plistlib.dump(plist, f)
    print(f"✅ eqMac plist updated")


def is_eqmac_running():
    """Check if eqMac process is running."""
    result = subprocess.run(
        ["pgrep", "-x", "eqMac"], capture_output=True, text=True
    )
    return result.returncode == 0


def kill_eqmac():
    """Kill eqMac if running."""
    if is_eqmac_running():
        print("🛑 Stopping eqMac...")
        subprocess.run(["killall", "eqMac"], capture_output=True)


def launch_eqmac():
    """Launch eqMac."""
    print("🚀 Starting eqMac...")
    subprocess.Popen(["open", EQMAC_APP])
    print("   eqMac launched (it runs in menu bar)")


def install_preset():
    """Inject the ATH-M40x preset into eqMac preferences."""
    print("🔧 Setting up Audio-Technica ATH-M40x AutoEq preset...")
    print(f"   Preset ID: {ATH_M40X_PRESET['id']}")

    plist = read_plist()

    # Read existing presets
    existing_presets_raw = plist.get("presets", b"[]")
    existing_presets = json.loads(existing_presets_raw) if isinstance(existing_presets_raw, bytes) else []

    # Read existing state
    state_raw = plist.get("state", b"{}")
    state = json.loads(state_raw) if isinstance(state_raw, bytes) else {}

    # Check if AT40x preset already exists and remove it
    existing_presets = [
        p for p in existing_presets if p.get("name") != ATH_M40X_PRESET["name"]
    ]

    # Add the new preset
    existing_presets.append(ATH_M40X_PRESET)
    plist["presets"] = json.dumps(existing_presets).encode("utf-8")

    # Update state to select this preset
    if "effects" not in state:
        state["effects"] = {}
    if "equalizers" not in state["effects"]:
        state["effects"]["equalizers"] = {}
    if "advanced" not in state["effects"]["equalizers"]:
        state["effects"]["equalizers"]["advanced"] = {}

    # Set equalizer type to Advanced and select our preset
    state["effects"]["equalizers"]["type"] = "Advanced"
    state["effects"]["equalizers"]["advanced"]["selectedPresetId"] = ATH_M40X_PRESET["id"]
    state["effects"]["equalizers"]["advanced"]["showDefaultPresets"] = True

    # Enable presets in state
    if "presets" not in state:
        state["presets"] = {}
    state["presets"]["enabled"] = True

    # Ensure equalizer is enabled
    state["effects"]["equalizers"]["enabled"] = True

    # Write state back
    plist["state"] = json.dumps(state).encode("utf-8")

    write_plist(plist)

    print(f"\n📋 Preset details:")
    print(f"   Name: {ATH_M40X_PRESET['name']}")
    print(f"   Preamp: {ATH_M40X_PRESET['gains']['global']} dB")
    bands = ATH_M40X_PRESET['gains']['bands']
    freqs = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    for f, g in zip(freqs, bands):
        print(f"   {f:5d} Hz: {g:+.1f} dB")
    print()


def reset_to_flat():
    """Reset eqMac to flat EQ."""
    print("🔄 Resetting to flat EQ...")

    plist = read_plist()

    # Remove AT40x presets
    existing_presets_raw = plist.get("presets", b"[]")
    existing_presets = json.loads(existing_presets_raw) if isinstance(existing_presets_raw, bytes) else []
    existing_presets = [
        p for p in existing_presets if p.get("name") != ATH_M40X_PRESET["name"]
    ]
    plist["presets"] = json.dumps(existing_presets).encode("utf-8")

    # Reset state
    state_raw = plist.get("state", b"{}")
    state = json.loads(state_raw) if isinstance(state_raw, bytes) else {}

    if "effects" in state and "equalizers" in state["effects"]:
        if "advanced" in state["effects"]["equalizers"]:
            state["effects"]["equalizers"]["advanced"]["selectedPresetId"] = "flat"
        state["effects"]["equalizers"]["type"] = "Basic"

    if "presets" in state:
        state["presets"]["enabled"] = False

    plist["state"] = json.dumps(state).encode("utf-8")
    write_plist(plist)
    print("✅ Reset complete")


def setup_login_item():
    """Add eqMac to macOS Login Items."""
    print("🔑 Setting up eqMac as Login Item...")

    # Check if already a login item
    result = subprocess.run(
        ["osascript", "-e",
         'tell application "System Events" to get the name of every login item'],
        capture_output=True, text=True
    )
    login_items = result.stdout.strip().split(", ") if result.stdout.strip() else []

    if "eqMac" in login_items:
        print("   ✅ eqMac is already a Login Item")
        return

    # Add eqMac to login items
    script = f"""
    tell application "System Events"
        make login item at end with properties {{name: "eqMac", path: "/Applications/eqMac.app", hidden: false}}
    end tell
    """
    result = subprocess.run(["osascript", "-e", script], capture_output=True, text=True)
    if result.returncode == 0:
        print("   ✅ eqMac added to Login Items")
    else:
        print(f"   ⚠️ Could not add to Login Items: {result.stderr.strip()}")
        print("   You can add it manually in System Settings → General → Login Items")


def main():
    if "--reset" in sys.argv:
        kill_eqmac()
        reset_to_flat()
        launch_eqmac()
        return

    if "--no-restart" not in sys.argv:
        kill_eqmac()

    install_preset()
    setup_login_item()

    if "--no-restart" not in sys.argv:
        launch_eqmac()
        print("""
🎉 ¡TODO LISTO!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ AutoEq para ATH-M40x inyectado
✓ Arranque automático configurado
✓ eqMac reiniciado

📌 PRÓXIMOS PASOS (opcional):
  1. Abrí eqMac desde la barra de menú (ícono de ecualizador ↑)
  2. Verificá que esté en "Advanced Equalizer" con el preset activo
  3. Si escuchás distorsión, ajustá el "Global Gain" manualmente

Para volver a flat:
  python3 setup-eqmac-at40x.py --reset
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""")


if __name__ == "__main__":
    main()
