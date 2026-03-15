#!/bin/bash

# Samsung S23 Debloat Script (Customized Version)
# Removes Samsung bloatware while keeping useful apps

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../backups/debloat_$(date +%Y%m%d_%H%M%S).log"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Samsung S23 Debloat Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "This script will remove bloatware from your Samsung device."
echo ""
echo -e "${GREEN}KEPT (useful apps):${NC}"
echo "  • My Files (file manager)"
echo "  • Samsung Calculator"
echo "  • Samsung Calendar"
echo "  • Always On Display"
echo "  • Digital Wellbeing (screen time)"
echo ""
echo "All operations logged to: $LOG_FILE"
echo ""

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}Error: No device found or device unauthorized${NC}"
    echo "Please:"
    echo "  1. Connect your device via USB"
    echo "  2. Enable USB debugging"
    echo "  3. Authorize this computer"
    exit 1
fi

DEVICE_MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
echo -e "${GREEN}Device detected: $DEVICE_MODEL${NC}"
echo ""
echo -e "${YELLOW}⚠️  WARNING: This will remove many system apps!${NC}"
echo "Press Enter to begin, or Ctrl+C to cancel."
read

# Initialize log
mkdir -p "$(dirname "$LOG_FILE")"
{
    echo "Debloat Log"
    echo "==========="
    echo "Date: $(date)"
    echo "Device: $DEVICE_MODEL"
    echo ""
    echo "Apps KEPT (not removed):"
    echo "  - My Files"
    echo "  - Samsung Calculator"
    echo "  - Samsung Calendar"
    echo "  - Always On Display"
    echo "  - Digital Wellbeing"
    echo ""
} > "$LOG_FILE"

# Function to uninstall package
uninstall_package() {
    local package=$1
    local description=$2

    # Check if package exists
    if adb shell pm list packages | grep -q "^package:${package}$"; then
        if adb shell pm uninstall -k --user 0 "$package" 2>&1 | grep -q "Success"; then
            echo -e "${GREEN}✓${NC} Removed: $description"
            echo "SUCCESS: $package - $description" >> "$LOG_FILE"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} Failed: $description"
            echo "FAILED: $package - $description" >> "$LOG_FILE"
            return 1
        fi
    else
        echo -e "${BLUE}○${NC} Not installed: $description"
        echo "SKIP: $package - $description (not installed)" >> "$LOG_FILE"
        return 2
    fi
}

TOTAL=0
SUCCESS=0
FAILED=0
SKIPPED=0

echo -e "${BLUE}Starting debloat process...${NC}"
echo ""

# Samsung Bixby-Related Bloatware
echo -e "${BLUE}[1/15] Removing Bixby components...${NC}"
uninstall_package "com.samsung.android.app.settings.bixby" "Settings Bixby" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.bixby.wakeup" "Bixby Voice Wake-up" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.bixby.agent" "Bixby Voice" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.bixbyvision.framework" "Bixby Vision" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.bixby.service" "Bixby Service" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.routines" "Bixby Routines" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.visionintelligence" "Bixby Vision Intelligence" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Samsung System Apps
echo -e "${BLUE}[2/15] Removing Samsung system bloatware...${NC}"
uninstall_package "com.samsung.android.smartswitchassistant" "Smart Switch Assistant" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
# KEPT: My Files - useful file manager
echo -e "${BLUE}○${NC} Kept: My Files (file manager)"
echo "KEPT: com.sec.android.app.myfiles - My Files" >> "$LOG_FILE"
uninstall_package "com.sec.android.app.shealth" "Samsung Health" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.arzone" "AR Zone" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.video" "Samsung Video Player" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.sec.android.app.samsungapps" "Galaxy Store" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.tvplus" "Samsung TV+" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.voc" "Samsung Members" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
# KEPT: Samsung Calendar - useful calendar app
echo -e "${BLUE}○${NC} Kept: Samsung Calendar"
echo "KEPT: com.samsung.android.calendar - Samsung Calendar" >> "$LOG_FILE"
uninstall_package "com.samsung.android.messaging" "Samsung Messages" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
# KEPT: Samsung Calculator - useful calculator
echo -e "${BLUE}○${NC} Kept: Samsung Calculator"
echo "KEPT: com.sec.android.app.popupcalculator - Samsung Calculator" >> "$LOG_FILE"
# KEPT: Always On Display - user requested
echo -e "${BLUE}○${NC} Kept: Always On Display"
echo "KEPT: com.samsung.android.app.aodservice - Always On Display" >> "$LOG_FILE"
echo ""

# Google Bloatware
echo -e "${BLUE}[3/15] Removing Google bloatware...${NC}"
uninstall_package "com.google.android.apps.messaging" "Google Messages" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.apps.bard" "Google Bard" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.android.chrome" "Chrome Browser" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.gm" "Gmail" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.youtube" "YouTube" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.videos" "Google TV (Play Movies & TV)" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.apps.maps" "Google Maps" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.apps.tachyon" "Google Duo" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.googlequicksearchbox" "Google Search" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Facebook Bloatware
echo -e "${BLUE}[4/15] Removing Facebook bloatware...${NC}"
uninstall_package "com.facebook.system" "Facebook System" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.facebook.appmanager" "Facebook App Manager" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.facebook.services" "Facebook Services" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.facebook.katana" "Facebook App" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Samsung Sharing & Connectivity
echo -e "${BLUE}[5/15] Removing Samsung sharing features...${NC}"
uninstall_package "com.samsung.android.app.simplesharing" "Link Sharing" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.aware.service" "Quick Share" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.sharelive" "Quick Share Live" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.mdx" "Link to Windows" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.smartmirroring" "Smart View" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Samsung Pay & Pass
echo -e "${BLUE}[6/15] Removing Samsung Pay & Pass...${NC}"
uninstall_package "com.samsung.android.samsungpass" "Samsung Pass" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.samsungpassautofill" "Samsung Pass Autofill" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.spay" "Samsung Wallet" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.spayfw" "Samsung Pay Framework" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# AR Emoji & Stickers
echo -e "${BLUE}[7/15] Removing AR Emoji features...${NC}"
uninstall_package "com.samsung.android.aremoji" "AR Emoji" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.sec.android.mimage.avatarstickers" "AR Emoji Stickers" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.aremojieditor" "AR Emoji Editor" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.stickercenter" "Sticker Center" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.livestickers" "Live Stickers" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Game Launcher
echo -e "${BLUE}[8/15] Removing Game Launcher...${NC}"
uninstall_package "com.samsung.android.game.gametools" "Game Booster" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.game.gos" "Game Optimizing Service" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.game.gamehome" "Game Launcher" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Samsung Dex
echo -e "${BLUE}[9/15] Removing Samsung DeX...${NC}"
uninstall_package "com.sec.android.dexsystemui" "DeX System UI" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.sec.android.desktopmode.uiservice" "DeX UI Service" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.sec.android.app.desktoplauncher" "DeX Launcher" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Edge Panels
echo -e "${BLUE}[10/15] Removing Edge Panels...${NC}"
uninstall_package "com.samsung.android.service.peoplestripe" "People Edge Panel" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.appsedge" "Apps Edge Panel" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.taskedge" "Tasks Edge Panel" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.clipboardedge" "Clipboard Edge" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Microsoft Services
echo -e "${BLUE}[11/15] Removing Microsoft services...${NC}"
uninstall_package "com.microsoft.appmanager" "Your Phone Companion" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.microsoft.skydrive" "OneDrive" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Printing Services
echo -e "${BLUE}[12/15] Removing printing services...${NC}"
uninstall_package "com.android.bips" "Default Print Service" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.google.android.printservice.recommendation" "Print Recommendations" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.android.printspooler" "Print Spooler" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Netflix & Streaming
echo -e "${BLUE}[13/15] Removing Netflix...${NC}"
uninstall_package "com.netflix.partner.activation" "Netflix Activation" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.netflix.mediaclient" "Netflix" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Samsung Free & Recommendations
echo -e "${BLUE}[14/15] Removing Samsung Free & recommendations...${NC}"
uninstall_package "com.samsung.android.app.spage" "Samsung Free" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.omcagent" "Recommended Apps" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.tips" "Samsung Tips" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
echo ""

# Additional Bloatware
echo -e "${BLUE}[15/15] Removing miscellaneous bloatware...${NC}"
uninstall_package "com.samsung.android.scloud" "Samsung Cloud" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.fmm" "Find My Mobile" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.privateshare" "Private Share" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.storyservice" "Gallery Stories" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.samsung.android.app.reminder" "Samsung Reminder" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
uninstall_package "com.sec.android.app.sbrowser" "Samsung Internet" && ((SUCCESS++)) || [ $? -eq 2 ] && ((SKIPPED++)) || ((FAILED++)); ((TOTAL++))
# KEPT: Digital Wellbeing - screen time tracking
echo -e "${BLUE}○${NC} Kept: Digital Wellbeing (screen time)"
echo "KEPT: com.samsung.android.forest - Digital Wellbeing" >> "$LOG_FILE"
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Debloat Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Total packages processed: ${BLUE}$TOTAL${NC}"
echo -e "Successfully removed: ${GREEN}$SUCCESS${NC}"
echo -e "Failed to remove: ${YELLOW}$FAILED${NC}"
echo -e "Not installed (skipped): ${BLUE}$SKIPPED${NC}"
echo -e "Kept (useful apps): ${BLUE}5${NC} (My Files, Calculator, Calendar, AOD, Digital Wellbeing)"
echo ""
echo -e "Log saved to: ${YELLOW}$LOG_FILE${NC}"
echo ""
echo -e "${YELLOW}Reboot recommended to complete debloat process${NC}"
echo ""
