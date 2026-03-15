#!/bin/bash

# Android Full Backup Script
# Creates a complete backup of your Android device for easy restoration after factory reset

set -e

BACKUP_DIR="/Users/alex/Github/me/dotfiles/.local/bin/android-backup/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/backup_${TIMESTAMP}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Android Complete Backup Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}Error: No device found or device unauthorized${NC}"
    echo "Please connect your device and authorize USB debugging"
    exit 1
fi

DEVICE_MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
DEVICE_SERIAL=$(adb shell getprop ro.serialno | tr -d '\r')
ANDROID_VERSION=$(adb shell getprop ro.build.version.release | tr -d '\r')

echo -e "${GREEN}Device detected:${NC}"
echo "  Model: $DEVICE_MODEL"
echo "  Serial: $DEVICE_SERIAL"
echo "  Android: $ANDROID_VERSION"
echo ""

# Create backup directory
mkdir -p "$BACKUP_PATH"
echo -e "${YELLOW}Backup location: $BACKUP_PATH${NC}"
echo ""

# Save device info
cat > "$BACKUP_PATH/device_info.txt" <<EOF
Device Model: $DEVICE_MODEL
Serial Number: $DEVICE_SERIAL
Android Version: $ANDROID_VERSION
Backup Date: $(date)
EOF

echo -e "${BLUE}[1/8] Backing up installed apps list...${NC}"
adb shell pm list packages -3 | sed 's/package://' > "$BACKUP_PATH/installed_apps.txt"
adb shell pm list packages | sed 's/package://' > "$BACKUP_PATH/all_packages.txt"
echo -e "${GREEN}✓ Saved $(wc -l < "$BACKUP_PATH/installed_apps.txt") user apps${NC}"
echo ""

echo -e "${BLUE}[2/8] Backing up APKs of installed apps...${NC}"
mkdir -p "$BACKUP_PATH/apks"
APK_COUNT=0
while IFS= read -r package; do
    APK_PATH=$(adb shell pm path "$package" | sed 's/package://' | tr -d '\r')
    if [ -n "$APK_PATH" ]; then
        adb pull "$APK_PATH" "$BACKUP_PATH/apks/${package}.apk" 2>/dev/null && {
            ((APK_COUNT++))
            echo -ne "\r${GREEN}  Backed up $APK_COUNT APKs...${NC}"
        }
    fi
done < "$BACKUP_PATH/installed_apps.txt"
echo -e "\n${GREEN}✓ Backed up $APK_COUNT APK files${NC}"
echo ""

echo -e "${BLUE}[3/8] Backing up app data (this may take a while)...${NC}"
echo -e "${YELLOW}Note: You may need to unlock your device and approve the backup${NC}"
adb backup -apk -shared -all -f "$BACKUP_PATH/app_data.ab"
if [ -f "$BACKUP_PATH/app_data.ab" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_PATH/app_data.ab" | cut -f1)
    echo -e "${GREEN}✓ App data backup created: $BACKUP_SIZE${NC}"
else
    echo -e "${YELLOW}⚠ App data backup may have failed or was cancelled${NC}"
fi
echo ""

echo -e "${BLUE}[4/8] Backing up internal storage (photos, documents, etc.)...${NC}"
mkdir -p "$BACKUP_PATH/storage"
echo -e "${YELLOW}  Backing up DCIM (Camera photos)...${NC}"
adb pull /sdcard/DCIM "$BACKUP_PATH/storage/" 2>/dev/null || echo "  (No DCIM folder)"
echo -e "${YELLOW}  Backing up Pictures...${NC}"
adb pull /sdcard/Pictures "$BACKUP_PATH/storage/" 2>/dev/null || echo "  (No Pictures folder)"
echo -e "${YELLOW}  Backing up Documents...${NC}"
adb pull /sdcard/Documents "$BACKUP_PATH/storage/" 2>/dev/null || echo "  (No Documents folder)"
echo -e "${YELLOW}  Backing up Download...${NC}"
adb pull /sdcard/Download "$BACKUP_PATH/storage/" 2>/dev/null || echo "  (No Download folder)"
echo -e "${YELLOW}  Backing up Music...${NC}"
adb pull /sdcard/Music "$BACKUP_PATH/storage/" 2>/dev/null || echo "  (No Music folder)"
echo -e "${GREEN}✓ Internal storage backed up${NC}"
echo ""

echo -e "${BLUE}[5/8] Backing up SMS and call logs...${NC}"
adb shell content query --uri content://sms/ > "$BACKUP_PATH/sms_backup.txt" 2>/dev/null || echo -e "${YELLOW}⚠ SMS backup requires root or special permissions${NC}"
adb shell content query --uri content://call_log/calls > "$BACKUP_PATH/call_log.txt" 2>/dev/null || echo -e "${YELLOW}⚠ Call log backup requires root or special permissions${NC}"
echo ""

echo -e "${BLUE}[6/8] Backing up system settings...${NC}"
adb shell settings list system > "$BACKUP_PATH/settings_system.txt"
adb shell settings list secure > "$BACKUP_PATH/settings_secure.txt"
adb shell settings list global > "$BACKUP_PATH/settings_global.txt"
echo -e "${GREEN}✓ System settings backed up${NC}"
echo ""

echo -e "${BLUE}[7/8] Backing up WiFi configurations...${NC}"
adb shell "su -c 'cat /data/misc/wifi/WifiConfigStore.xml'" > "$BACKUP_PATH/wifi_config.xml" 2>/dev/null || \
    echo -e "${YELLOW}⚠ WiFi config backup requires root access${NC}"
echo ""

echo -e "${BLUE}[8/8] Creating backup summary...${NC}"
cat > "$BACKUP_PATH/README.txt" <<EOF
Android Backup Summary
======================
Created: $(date)
Device: $DEVICE_MODEL ($DEVICE_SERIAL)
Android: $ANDROID_VERSION

Contents:
- installed_apps.txt: List of user-installed apps
- all_packages.txt: Complete list of all packages
- apks/: APK files for user apps
- app_data.ab: Android backup file with app data
- storage/: Internal storage (photos, documents, etc.)
- sms_backup.txt: SMS messages
- call_log.txt: Call history
- settings_*.txt: System settings
- wifi_config.xml: WiFi configurations (if rooted)

To restore:
1. Factory reset your device
2. Run: ../scripts/restore.sh "$BACKUP_PATH"
EOF

TOTAL_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
echo -e "${GREEN}✓ Backup summary created${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Backup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Total backup size: ${YELLOW}$TOTAL_SIZE${NC}"
echo -e "Backup location: ${YELLOW}$BACKUP_PATH${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Verify backup contents in: $BACKUP_PATH"
echo -e "  2. Perform factory reset on your device"
echo -e "  3. Run restore script: ${YELLOW}./restore.sh $BACKUP_PATH${NC}"
echo ""
