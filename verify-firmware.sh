#!/usr/bin/env bash
#
# Firmware Verification Script for ZyXEL VMG8825-T50
# Verifies integrity and provides information about firmware binaries
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRMWARE_DIR="${SCRIPT_DIR}/build/stock"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║      Firmware Verification Tool                               ║
║      ZyXEL VMG8825-T50 Binary Validator                       ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Change to firmware directory
cd "$FIRMWARE_DIR"

# Function to calculate checksum
calc_sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        echo "unavailable"
    fi
}

calc_md5() {
    if command -v md5sum >/dev/null 2>&1; then
        md5sum "$1" | awk '{print $1}'
    elif command -v md5 >/dev/null 2>&1; then
        md5 -q "$1"
    else
        echo "unavailable"
    fi
}

# Check firmware files
FIRMWARE_FILES=(V550ABOM3C0.bin V550ABOM6C0.bin V550ABOM7C0.bin)

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  FIRMWARE BINARY INFORMATION${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"

TOTAL_VERIFIED=0
TOTAL_FAILED=0

for fw in "${FIRMWARE_FILES[@]}"; do
    echo -e "${YELLOW}Checking: $fw${NC}"
    
    if [ ! -f "$fw" ]; then
        echo -e "  ${RED}✗ File not found${NC}\n"
        ((TOTAL_FAILED++))
        continue
    fi
    
    # File size
    SIZE=$(du -h "$fw" | cut -f1)
    SIZE_BYTES=$(stat -f%z "$fw" 2>/dev/null || stat -c%s "$fw" 2>/dev/null)
    echo -e "  ${GREEN}✓${NC} Size: ${SIZE} (${SIZE_BYTES} bytes)"
    
    # Calculate checksums
    echo -e "  ${BLUE}⟳${NC} Calculating checksums..."
    SHA256=$(calc_sha256 "$fw")
    MD5=$(calc_md5 "$fw")
    
    # Display checksums
    if [ "$SHA256" != "unavailable" ]; then
        echo -e "    SHA256: ${GREEN}${SHA256}${NC}"
    fi
    
    if [ "$MD5" != "unavailable" ]; then
        echo -e "    MD5:    ${GREEN}${MD5}${NC}"
    fi
    
    # Verify against known checksums
    if [ -f "SHA256SUMS" ]; then
        if grep -q "$SHA256" SHA256SUMS 2>/dev/null; then
            echo -e "  ${GREEN}✓ SHA256 checksum verified!${NC}"
            ((TOTAL_VERIFIED++))
        else
            echo -e "  ${RED}✗ SHA256 checksum mismatch!${NC}"
            ((TOTAL_FAILED++))
        fi
    fi
    
    echo ""
done

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  VERIFICATION SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"

echo -e "Total binaries checked: ${BLUE}${#FIRMWARE_FILES[@]}${NC}"
echo -e "Verified successfully:  ${GREEN}${TOTAL_VERIFIED}${NC}"

if [ $TOTAL_FAILED -gt 0 ]; then
    echo -e "Failed verification:    ${RED}${TOTAL_FAILED}${NC}"
    echo -e "\n${RED}⚠  WARNING: Some files failed verification!${NC}"
    echo -e "Consider re-downloading the firmware files."
    exit 1
else
    echo -e "\n${GREEN}✓ All firmware files verified successfully!${NC}"
    echo -e "Files are ready for flashing.\n"
fi

# Recommendations
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  RECOMMENDATIONS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"

echo -e "${GREEN}✓${NC} Recommended for TTL flashing: ${YELLOW}V550ABOM3C0.bin${NC}"
echo -e "  - Smallest size (22MB)"
echo -e "  - Most tested version"
echo -e "  - Best compatibility"

echo -e "\n${BLUE}Alternative options:${NC}"
echo -e "  - ${YELLOW}V550ABOM6C0.bin${NC} (27MB) - Enhanced features"
echo -e "  - ${YELLOW}V550ABOM7C0.bin${NC} (32MB) - Latest version"

echo -e "\n${BLUE}Next steps:${NC}"
echo -e "  1. Run: ${GREEN}./prepare-flash.sh${NC} - Prepare system for flashing"
echo -e "  2. Read: ${BLUE}FIRMWARE_FLASHING_GUIDE.md${NC} - Complete guide"
echo -e "  3. Read: ${BLUE}TTL_FLASH_QUICK_REFERENCE.md${NC} - Quick reference"

echo -e "\n${GREEN}Ready to proceed with flashing! 🎉${NC}\n"
