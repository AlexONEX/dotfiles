#!/bin/bash

# Install missing apps from backup

set -e

BACKUP_DIR="/Users/alex/Github/me/dotfiles/.local/bin/android-backup/backups/backup_20260315_112707"
APK_DIR="$BACKUP_DIR/apks"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Installing Missing Apps${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}Error: No device connected${NC}"
    exit 1
fi

# Missing apps list
MISSING_APPS=(
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
"com.google.android.apps.work.clouddpc"
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
"com.samsung.android.app.clockface"
"com.samsung.android.app.networkstoragemanager"
"com.sec.android.app.shealth"
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

TOTAL=${#MISSING_APPS[@]}
INSTALLED=0
FAILED=0
SKIPPED=0

echo -e "${YELLOW}Total apps to install: $TOTAL${NC}"
echo ""

for package in "${MISSING_APPS[@]}"; do
    APK_FILE="$APK_DIR/${package}.apk"

    if [ -f "$APK_FILE" ]; then
        echo -ne "${BLUE}Installing: $package ($((INSTALLED + FAILED + SKIPPED + 1))/$TOTAL)${NC}"

        if adb install -r "$APK_FILE" >/dev/null 2>&1; then
            echo -e "\r${GREEN}✓${NC} Installed: $package                                    "
            ((INSTALLED++))
        else
            echo -e "\r${RED}✗${NC} Failed: $package                                    "
            ((FAILED++))
        fi
    else
        echo -e "${YELLOW}○${NC} Skipped: $package (APK not found)"
        ((SKIPPED++))
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Successfully installed: ${GREEN}$INSTALLED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo -e "Skipped (APK not found): ${YELLOW}$SKIPPED${NC}"
echo ""
