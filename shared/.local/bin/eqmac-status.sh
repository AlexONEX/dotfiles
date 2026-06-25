#!/bin/bash
# eqmac-status.sh
# Quick diagnostic tool for eqMac + ATH-M40x AutoEq setup.

echo ""
echo "═══════════════════════════════════════"
echo "  eqMac + ATH-M40x AutoEq — Status"
echo "═══════════════════════════════════════"
echo ""

# 1. Is eqMac running?
echo "📱 eqMac process:"
if pgrep -x eqMac > /dev/null 2>&1; then
    echo "   ✅ Running (PID $(pgrep -x eqMac))"
else
    echo "   ❌ NOT running"
fi
echo ""

# 2. Check Login Item
echo "🔑 Login Item:"
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | \
    grep -q "eqMac" && echo "   ✅ eqMac auto-starts at login" || echo "   ❌ Not in Login Items"
echo ""

# 3. Check launchd agent
echo "⚙️ LaunchAgent:"
if launchctl list 2>/dev/null | grep -q "com.bitgapp.eqmac.ensure-output"; then
    echo "   ✅ Output monitor active"
else
    echo "   ❌ Output monitor NOT active"
fi
echo ""

# 4. List audio outputs
echo "🔊 Audio Outputs:"
SwitchAudioSource -a -t output 2>/dev/null | while IFS= read -r line; do
    if echo "$line" | grep -qi eqmac; then
        echo "   🎧 $line  ← eqMac virtual device"
    elif echo "$line" | grep -qi "external headphones"; then
        echo "   🎧 $line  ← tu AT40x"
    elif echo "$line" | grep -qi "speakers"; then
        echo "   🔊 $line"
    elif echo "$line" | grep -qi "blackhole"; then
        echo "   🔁 $line"
    else
        echo "   • $line"
    fi
done
echo ""

# 5. Current default output
echo "🎯 Default Output:"
CURRENT=$(SwitchAudioSource -c -t output 2>/dev/null)
if echo "$CURRENT" | grep -qi eqmac; then
    echo "   ✅ $CURRENT"
    echo "   (audio va con EQ aplicado)"
else
    echo "   ⚠️ $CURRENT (NO pasa por eqMac!)"
    echo "   Solución: SwitchAudioSource -s 'External Headphones (eqMac)' -t output"
fi
echo ""

# 6. Check eqMac preset from plist
echo "🎚️ EQ Preset:"
python3 << 'PYEOF' 2>/dev/null
import plistlib, json, os

plist_path = os.path.expanduser("~/Library/Preferences/com.bitgapp.eqMac.plist")
if not os.path.exists(plist_path):
    print("   ❌ eqMac plist not found")
else:
    try:
        with open(plist_path, 'rb') as f:
            plist = plistlib.load(f)
        state_raw = plist.get('state', b'{}')
        state = json.loads(state_raw) if isinstance(state_raw, bytes) else {}

        eq = state.get('effects', {}).get('equalizers', {})
        preset_id = eq.get('advanced', {}).get('selectedPresetId', 'flat')
        eq_type = eq.get('type', 'unknown')
        eq_enabled = eq.get('enabled', False)

        if preset_id != 'flat':
            print(f"   ✅ Activo: {eq_type} EQ (ID: {preset_id[:8]}...)")
            print(f"   Enabled: {eq_enabled}")
        else:
            print(f"   ⚠️ Flat EQ — sin preset custom")
    except Exception as e:
        print(f"   ❌ Error: {e}")
PYEOF
echo ""

# 7. Show available commands
echo "💡 Comandos útiles:"
echo "   Ver estado:    eqmac-status"
echo "   Forzar output: SwitchAudioSource -s 'External Headphones (eqMac)' -t output"
echo "   Reset EQ:      python3 ~/.local/bin/setup-eqmac-at40x.py --reset"
echo "   Re-aplicar:    python3 ~/.local/bin/setup-eqmac-at40x.py"
echo ""

echo "═══════════════════════════════════════"
