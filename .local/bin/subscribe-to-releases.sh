#!/bin/bash

PLUGINS_FILE="plugins.txt"
SUCCESS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Subscribing to release...${NC}"
echo -e "${BLUE}========================================${NC}\n"

if [ ! -f "$PLUGINS_FILE" ]; then
    echo -e "${RED}Error: File not found $PLUGINS_FILE${NC}"
    exit 1
fi

while IFS= read -r repo || [ -n "$repo" ]; do
    if [ -z "$repo" ]; then
        continue
    fi

    echo -e "Processing: ${YELLOW}$repo${NC}"

    if gh api --method PUT \
        -H "Accept: application/vnd.github+json" \
        "/repos/$repo/subscription" \
        -F subscribed=true \
        -F ignored=false \
        --silent 2>/dev/null; then
        echo -e "${GREEN}✓ Subscrito exitosamente${NC}\n"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}✗ Error al subscribirse${NC}\n"
        ((FAIL_COUNT++))
    fi

    sleep 0.5

done < "$PLUGINS_FILE"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Overview:${NC}"
echo -e "${GREEN}Success: $SUCCESS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo -e "${BLUE}========================================${NC}"
