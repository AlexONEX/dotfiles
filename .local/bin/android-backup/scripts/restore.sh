#!/bin/bash

# Android Full Restore Script
# Restores your Android device from a backup created with backup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Android Complete Restore Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if backup path provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No backup path provided${NC}"
    echo ""
    echo "Usage: $0 <backup_path>"
    echo ""
    echo "Available backups:"
    ls -dt /Users/alex/Github/me/dotfiles/.local/bin/android-backup/backups/backup_* 2>/dev/null | head -5 || echo "  (none found)"
    exit 1
fi

BACKUP_PATH="$1"

if [ ! -d "$BACKUP_PATH" ]; then
    echo -e "${RED}Error: Backup path not found: $BACKUP_PATH${NC}"
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}Error: No device found or device unauthorized${NC}"
    echo "Please connect your device and authorize USB debugging"
    exit 1
fi

DEVICE_MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
echo -e "${GREEN}Device detected: $DEVICE_MODEL${NC}"
echo -e "${YELLOW}Restoring from: $BACKUP_PATH${NC}"
echo ""

# Show backup info
if [ -f "$BACKUP_PATH/device_info.txt" ]; then
    echo -e "${BLUE}Backup Information:${NC}"
    cat "$BACKUP_PATH/device_info.txt"
    echo ""
fi

echo -e "${YELLOW}⚠️  WARNING: This will:${NC}"
echo -e "  1. Remove Samsung bloatware (debloat)"
echo -e "  2. Install all backed up apps"
echo -e "  3. Restore app data"
echo -e "  4. Restore files to internal storage"
echo ""
echo -e "${RED}Make sure your device is freshly factory reset!${NC}"
echo ""
read -p "Continue? (yes/no): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Restore cancelled"
    exit 0
fi

# Step 1: Debloat
echo -e "${BLUE}[1/6] Running debloat script...${NC}"
DEBLOAT_SCRIPT="/Users/alex/Github/me/dotfiles/.local/bin/android_debloat.sh"
if [ -f "$DEBLOAT_SCRIPT" ]; then
    echo -e "${YELLOW}Starting automated debloat (this will take a few minutes)...${NC}"
    # Run debloat script non-interactively
    yes "" 2>/dev/null | bash "$DEBLOAT_SCRIPT" | grep -E "(Uninstalling|Success|Failure|Error)" || true
    echo -e "${GREEN}✓ Debloat complete${NC}"
else
    echo -e "${YELLOW}⚠ Debloat script not found, skipping${NC}"
fi
echo ""

# Step 2: Install APKs
echo -e "${BLUE}[2/6] Installing user apps...${NC}"
if [ -d "$BACKUP_PATH/apks" ]; then
    INSTALLED=0
    FAILED=0
    TOTAL=$(ls -1 "$BACKUP_PATH/apks"/*.apk 2>/dev/null | wc -l)

    for apk in "$BACKUP_PATH/apks"/*.apk; do
        if [ -f "$apk" ]; then
            PACKAGE=$(basename "$apk" .apk)
            echo -ne "\r${YELLOW}  Installing: $PACKAGE ($((INSTALLED + FAILED + 1))/$TOTAL)${NC}"
            if adb install -r "$apk" >/dev/null 2>&1; then
                ((INSTALLED++))
            else
                ((FAILED++))
            fi
        fi
    done

    echo -e "\n${GREEN}✓ Installed $INSTALLED apps${NC}"
    [ $FAILED -gt 0 ] && echo -e "${YELLOW}⚠ Failed to install $FAILED apps${NC}"
else
    echo -e "${YELLOW}⚠ No APKs found in backup${NC}"
fi
echo ""

# Step 3: Restore app data
echo -e "${BLUE}[3/6] Restoring app data...${NC}"
if [ -f "$BACKUP_PATH/app_data.ab" ]; then
    echo -e "${YELLOW}You may need to unlock your device and approve the restore${NC}"
    adb restore "$BACKUP_PATH/app_data.ab"
    echo -e "${GREEN}✓ App data restore initiated${NC}"
else
    echo -e "${YELLOW}⚠ No app data backup found${NC}"
fi
echo ""

# Step 4: Restore internal storage
echo -e "${BLUE}[4/6] Restoring internal storage...${NC}"
if [ -d "$BACKUP_PATH/storage" ]; then
    echo -e "${YELLOW}  Restoring DCIM (photos)...${NC}"
    [ -d "$BACKUP_PATH/storage/DCIM" ] && adb push "$BACKUP_PATH/storage/DCIM" /sdcard/ 2>/dev/null || echo "  (skipped)"

    echo -e "${YELLOW}  Restoring Pictures...${NC}"
    [ -d "$BACKUP_PATH/storage/Pictures" ] && adb push "$BACKUP_PATH/storage/Pictures" /sdcard/ 2>/dev/null || echo "  (skipped)"

    echo -e "${YELLOW}  Restoring Documents...${NC}"
    [ -d "$BACKUP_PATH/storage/Documents" ] && adb push "$BACKUP_PATH/storage/Documents" /sdcard/ 2>/dev/null || echo "  (skipped)"

    echo -e "${YELLOW}  Restoring Downloads...${NC}"
    [ -d "$BACKUP_PATH/storage/Download" ] && adb push "$BACKUP_PATH/storage/Download" /sdcard/ 2>/dev/null || echo "  (skipped)"

    echo -e "${YELLOW}  Restoring Music...${NC}"
    [ -d "$BACKUP_PATH/storage/Music" ] && adb push "$BACKUP_PATH/storage/Music" /sdcard/ 2>/dev/null || echo "  (skipped)"

    echo -e "${GREEN}✓ Internal storage restored${NC}"
else
    echo -e "${YELLOW}⚠ No storage backup found${NC}"
fi
echo ""

# Step 5: Restore system settings (manual review recommended)
echo -e "${BLUE}[5/6] Restoring system settings...${NC}"
echo -e "${YELLOW}⚠ Settings restore requires manual review for safety${NC}"
echo -e "Settings backed up in:"
echo -e "  - $BACKUP_PATH/settings_system.txt"
echo -e "  - $BACKUP_PATH/settings_secure.txt"
echo -e "  - $BACKUP_PATH/settings_global.txt"
echo ""
echo -e "${BLUE}Would you like to auto-restore safe settings? (recommended: no)${NC}"
read -p "Auto-restore settings? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}Restoring selected safe settings...${NC}"
    # Only restore safe, non-critical settings
    # You can customize this list based on your needs
    grep -E "^(font_scale|screen_brightness|volume_)" "$BACKUP_PATH/settings_system.txt" 2>/dev/null | while IFS= read -r line; do
        KEY=$(echo "$line" | cut -d= -f1)
        VALUE=$(echo "$line" | cut -d= -f2-)
        adb shell settings put system "$KEY" "$VALUE" 2>/dev/null || true
    done
    echo -e "${GREEN}✓ Safe settings restored${NC}"
else
    echo -e "${YELLOW}⚠ Settings restore skipped${NC}"
fi
echo ""

# Step 6: Reboot
echo -e "${BLUE}[6/6] Finalizing...${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Restore Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Review restored apps and data"
echo -e "  2. Check $BACKUP_PATH/installed_apps.txt for any missing apps"
echo -e "  3. Manually restore WiFi settings if needed"
echo -e "  4. Review and manually restore settings from settings_*.txt files"
echo ""
echo -e "${YELLOW}Reboot device now? (recommended)${NC}"
read -p "Reboot? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${BLUE}Rebooting device...${NC}"
    adb reboot
else
    echo -e "${YELLOW}Remember to reboot your device manually${NC}"
fi
echo ""
echo -e "${GREEN}Done!${NC}"
