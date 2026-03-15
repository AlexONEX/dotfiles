#!/bin/bash

# Quick test script to verify ADB connection and device status

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}   Android Device Connection Test${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Check if adb is installed
if ! command -v adb &> /dev/null; then
    echo -e "${RED}✗ ADB not found${NC}"
    echo "Install Android Platform Tools first"
    exit 1
fi
echo -e "${GREEN}✓ ADB installed${NC}"

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}✗ No device connected or device unauthorized${NC}"
    echo ""
    echo "Available devices:"
    adb devices
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "1. Connect your device via USB"
    echo "2. Enable Developer Options (tap Build Number 7 times)"
    echo "3. Enable USB Debugging in Developer Options"
    echo "4. Accept the authorization popup on your device"
    echo ""
    echo "Then run: adb devices"
    exit 1
fi
echo -e "${GREEN}✓ Device connected and authorized${NC}"

# Get device info
DEVICE_MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
DEVICE_SERIAL=$(adb shell getprop ro.serialno | tr -d '\r')
ANDROID_VERSION=$(adb shell getprop ro.build.version.release | tr -d '\r')
MANUFACTURER=$(adb shell getprop ro.product.manufacturer | tr -d '\r')

echo ""
echo -e "${BLUE}Device Information:${NC}"
echo -e "  Manufacturer: ${YELLOW}$MANUFACTURER${NC}"
echo -e "  Model: ${YELLOW}$DEVICE_MODEL${NC}"
echo -e "  Serial: ${YELLOW}$DEVICE_SERIAL${NC}"
echo -e "  Android: ${YELLOW}$ANDROID_VERSION${NC}"

# Check storage
STORAGE=$(adb shell df /sdcard | tail -1 | awk '{print $4}')
echo -e "  Storage available: ${YELLOW}$STORAGE${NC}"

# Check battery
BATTERY=$(adb shell dumpsys battery | grep level | awk '{print $2}')
echo -e "  Battery: ${YELLOW}$BATTERY%${NC}"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}   All checks passed!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}You're ready to:${NC}"
echo "  • Run backup: ./backup.sh"
echo "  • Run debloat: ./debloat.sh"
echo "  • Run restore: ./restore.sh <backup_path>"
echo ""
