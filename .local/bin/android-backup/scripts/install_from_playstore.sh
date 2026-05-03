#!/bin/bash

# Install apps from Play Store using package names

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Installing Apps from Play Store${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}Error: No device connected${NC}"
    exit 1
fi

echo -e "${YELLOW}This will open Play Store for each app.${NC}"
echo -e "${YELLOW}You need to manually tap 'Install' for each one.${NC}"
echo ""
echo -e "Press Enter to continue, or Ctrl+C to cancel."
read

# Missing apps list (excluding system apps)
APPS=(
"ar.com.osde.ads"
"ar.gob.smn"
"atws.app"
"ch.protonmail.android"
"com.barebonesdev.powerplanner"
"com.beemdevelopment.aegis"
"com.best.deskclock"
"com.cxinventor.file.explorer"
"com.deniscerri.ytdl"
"com.discord"
"com.faultexception.reader"
"com.github.android"
"com.google.android.calendar"
"com.hoyts"
"com.instagram.android"
"com.letterboxd.letterboxd"
"com.mercadolibre"
"com.mercadopago.wallet"
"com.microsoft.launcher"
"com.mosync.app_Banco_Galicia"
"com.NotYetMedia.RoyalRoad"
"com.pedidosya"
"com.playdigital.modo"
"com.qidian.Int.reader"
"com.stooq.mobile"
"com.sube.app"
"com.theathletic"
"com.thestorygraph.thestorygraph"
"com.touchtype.swiftkey"
"com.tuentiargentina"
"com.twitter.android"
"com.ubercab"
"com.urbandroid.sleep"
"com.valvesoftware.android.steam.community"
"com.whatsapp"
"com.x8bit.bitwarden"
"com.yahoo.mobile.client.android.finance"
"dev.netlob.spotistats"
"io.strongapp.strong"
"me.proton.android.calendar"
"org.fossify.messages"
"org.localsend.localsend_app"
"org.mozilla.firefox"
"org.telegram.messenger"
"s1m.savertuner"
)

# Special apps (not in Play Store or need special handling)
echo -e "${BLUE}Apps that need special handling:${NC}"
echo -e "  ${YELLOW}•${NC} Aegis (com.beemdevelopment.aegis) - Install from GitHub or F-Droid"
echo -e "  ${YELLOW}•${NC} F-Droid (org.fdroid.fdroid) - Download from fdroid.org"
echo -e "  ${YELLOW}•${NC} YT-DLP (com.deniscerri.ytdl) - May need F-Droid"
echo -e "  ${YELLOW}•${NC} Fossify Messages - May need F-Droid"
echo ""

TOTAL=${#APPS[@]}
OPENED=0

echo -e "${YELLOW}Opening Play Store for $TOTAL apps...${NC}"
echo -e "${YELLOW}Wait 3-5 seconds between each one to let Play Store load.${NC}"
echo ""

for package in "${APPS[@]}"; do
    ((OPENED++))
    echo -e "${BLUE}[$OPENED/$TOTAL]${NC} Opening Play Store for: $package"

    # Open Play Store page for this app
    adb shell am start -a android.intent.action.VIEW -d "market://details?id=$package" >/dev/null 2>&1

    # Wait 4 seconds before opening next one
    if [ $OPENED -lt $TOTAL ]; then
        sleep 4
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Finished opening Play Store pages${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Go through your Play Store and install the apps"
echo -e "  2. Some apps may not be found (region/device restrictions)"
echo -e "  3. Install Aegis and F-Droid manually:"
echo ""
echo -e "${BLUE}Manual installations:${NC}"
echo -e "  • F-Droid: https://f-droid.org/F-Droid.apk"
echo -e "  • Aegis: https://github.com/beemdevelopment/Aegis/releases"
echo ""
