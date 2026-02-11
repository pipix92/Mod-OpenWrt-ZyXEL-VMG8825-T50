#!/usr/bin/env bash
#
# TTL Flash Preparation Script for ZyXEL VMG8825-T50
# This script helps prepare your system for flashing firmware via TTL
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRMWARE_DIR="${SCRIPT_DIR}/build/stock"
RECOMMENDED_FIRMWARE="V550ABOM3C0.bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║      TTL Flash Preparation - ZyXEL VMG8825-T50                ║
║      Ready-to-Flash Firmware Binary Provider                  ║
╚════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root for network config
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}⚠️  Note: Some operations may require sudo privileges${NC}"
fi

# Function to print section headers
section_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: System Check
section_header "1. System Check"

echo -e "${GREEN}✓${NC} Checking operating system..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo -e "  Operating System: ${GREEN}Linux${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo -e "  Operating System: ${GREEN}macOS${NC}"
else
    OS="unknown"
    echo -e "  Operating System: ${YELLOW}$OSTYPE${NC}"
fi

# Step 2: Check Dependencies
section_header "2. Dependency Check"

MISSING_DEPS=()

# Check for serial terminal
if command_exists picocom; then
    echo -e "${GREEN}✓${NC} picocom installed"
elif command_exists screen; then
    echo -e "${YELLOW}⚠${NC}  picocom not found, but screen is available"
else
    echo -e "${RED}✗${NC} No serial terminal found (picocom or screen)"
    MISSING_DEPS+=("picocom or screen")
fi

# Check for TFTP client
if command_exists atftp; then
    echo -e "${GREEN}✓${NC} atftp installed"
elif command_exists tftp; then
    echo -e "${YELLOW}⚠${NC}  atftp not found, but tftp is available"
else
    echo -e "${RED}✗${NC} No TFTP client found"
    MISSING_DEPS+=("atftp or tftp")
fi

# Check for sha256sum
if command_exists sha256sum; then
    echo -e "${GREEN}✓${NC} sha256sum installed"
elif command_exists shasum; then
    echo -e "${GREEN}✓${NC} shasum installed (macOS alternative)"
else
    echo -e "${YELLOW}⚠${NC}  No checksum tool found"
fi

# If dependencies are missing, provide installation instructions
if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    section_header "Missing Dependencies"
    echo -e "${YELLOW}The following tools need to be installed:${NC}"
    for dep in "${MISSING_DEPS[@]}"; do
        echo -e "  - $dep"
    done
    
    echo -e "\n${BLUE}Installation commands:${NC}"
    if [ "$OS" = "linux" ]; then
        echo -e "\n  ${GREEN}Ubuntu/Debian:${NC}"
        echo -e "    sudo apt update"
        echo -e "    sudo apt install picocom atftp"
        echo -e "\n  ${GREEN}Fedora/RHEL:${NC}"
        echo -e "    sudo dnf install picocom tftp"
    elif [ "$OS" = "macos" ]; then
        echo -e "\n  ${GREEN}macOS (Homebrew):${NC}"
        echo -e "    brew install picocom"
        echo -e "    brew install inetutils  # for tftp"
    fi
    echo ""
fi

# Step 3: Firmware Check
section_header "3. Firmware Binary Check"

cd "$FIRMWARE_DIR"

# Check available firmware files
FIRMWARE_FILES=(V550ABOM3C0.bin V550ABOM6C0.bin V550ABOM7C0.bin)
AVAILABLE_FIRMWARE=()

echo "Checking firmware binaries..."
for fw in "${FIRMWARE_FILES[@]}"; do
    if [ -f "$fw" ]; then
        SIZE=$(du -h "$fw" | cut -f1)
        echo -e "${GREEN}✓${NC} $fw (${SIZE})"
        AVAILABLE_FIRMWARE+=("$fw")
    else
        echo -e "${RED}✗${NC} $fw (not found)"
    fi
done

if [ ${#AVAILABLE_FIRMWARE[@]} -eq 0 ]; then
    echo -e "\n${RED}ERROR: No firmware binaries found!${NC}"
    echo -e "Please ensure firmware files are in: $FIRMWARE_DIR"
    exit 1
fi

# Step 4: Checksum Verification
section_header "4. Firmware Verification"

if [ -f "SHA256SUMS" ]; then
    echo "Verifying firmware checksums..."
    if command_exists sha256sum; then
        if sha256sum -c SHA256SUMS 2>/dev/null; then
            echo -e "${GREEN}✓${NC} All checksums verified successfully!"
        else
            echo -e "${YELLOW}⚠${NC}  Checksum verification failed or incomplete"
            echo -e "    This may indicate corrupted firmware files"
        fi
    elif command_exists shasum; then
        if shasum -a 256 -c SHA256SUMS 2>/dev/null; then
            echo -e "${GREEN}✓${NC} All checksums verified successfully!"
        else
            echo -e "${YELLOW}⚠${NC}  Checksum verification failed or incomplete"
        fi
    fi
else
    echo -e "${YELLOW}⚠${NC}  No SHA256SUMS file found"
fi

# Step 5: Serial Port Detection
section_header "5. Serial Port Detection"

if [ "$OS" = "linux" ]; then
    echo "Detecting USB-TTL serial devices..."
    if ls /dev/ttyUSB* 1> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} USB serial devices found:"
        ls -l /dev/ttyUSB* | awk '{print "    " $NF}'
        SERIAL_PORT=$(ls /dev/ttyUSB* | head -n1)
        echo -e "\n  Suggested port: ${GREEN}$SERIAL_PORT${NC}"
    else
        echo -e "${YELLOW}⚠${NC}  No /dev/ttyUSB* devices found"
        echo -e "    Please connect your USB-TTL adapter"
    fi
elif [ "$OS" = "macos" ]; then
    echo "Detecting USB-TTL serial devices..."
    if ls /dev/tty.usb* 1> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} USB serial devices found:"
        ls -l /dev/tty.usb* | awk '{print "    " $NF}'
        SERIAL_PORT=$(ls /dev/tty.usb* | head -n1)
        echo -e "\n  Suggested port: ${GREEN}$SERIAL_PORT${NC}"
    else
        echo -e "${YELLOW}⚠${NC}  No /dev/tty.usb* devices found"
        echo -e "    Please connect your USB-TTL adapter"
    fi
fi

# Step 6: Network Configuration Check
section_header "6. Network Configuration"

echo "Checking network interfaces..."
if [ "$OS" = "linux" ]; then
    if command_exists ip; then
        echo -e "\nCurrent network interfaces:"
        ip addr show | grep -E "^[0-9]+:|inet " | grep -v "127.0.0.1"
    elif command_exists ifconfig; then
        echo -e "\nCurrent network interfaces:"
        ifconfig | grep -E "^[a-z]|inet " | grep -v "127.0.0.1"
    fi
elif [ "$OS" = "macos" ]; then
    echo -e "\nCurrent network interfaces:"
    ifconfig | grep -E "^[a-z]|inet " | grep -v "127.0.0.1"
fi

echo -e "\n${YELLOW}⚠  IMPORTANT:${NC} Configure your Ethernet adapter with:"
echo -e "    IP Address: ${GREEN}192.168.1.100${NC}"
echo -e "    Netmask:    ${GREEN}255.255.255.0${NC}"
echo -e "    Gateway:    ${GREEN}192.168.1.1${NC}"

# Step 7: Summary and Next Steps
section_header "7. Summary & Next Steps"

echo -e "${GREEN}✓${NC} Preparation check complete!"
echo -e "\n${BLUE}Recommended firmware:${NC} ${GREEN}$RECOMMENDED_FIRMWARE${NC}"
echo -e "${BLUE}Firmware location:${NC} $FIRMWARE_DIR/$RECOMMENDED_FIRMWARE"

if [ -n "$SERIAL_PORT" ]; then
    echo -e "${BLUE}Detected serial port:${NC} ${GREEN}$SERIAL_PORT${NC}"
fi

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  NEXT STEPS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

echo -e "\n${YELLOW}1.${NC} Connect hardware:"
echo -e "   - USB-TTL adapter to router (3.3V only!)"
echo -e "   - Ethernet cable between router and PC"
echo -e "   - Power supply to router"

echo -e "\n${YELLOW}2.${NC} Configure network:"
echo -e "   Set Ethernet adapter to: 192.168.1.100/24"

echo -e "\n${YELLOW}3.${NC} Open serial terminal:"
if [ -n "$SERIAL_PORT" ]; then
    if command_exists picocom; then
        echo -e "   ${GREEN}sudo picocom -b 115200 $SERIAL_PORT${NC}"
    elif command_exists screen; then
        echo -e "   ${GREEN}sudo screen $SERIAL_PORT 115200${NC}"
    fi
else
    echo -e "   ${GREEN}sudo picocom -b 115200 /dev/ttyUSB0${NC}"
fi

echo -e "\n${YELLOW}4.${NC} Follow flashing guide:"
echo -e "   See: ${BLUE}FIRMWARE_FLASHING_GUIDE.md${NC}"
echo -e "   Or:  ${BLUE}TTL_FLASH_QUICK_REFERENCE.md${NC}"

echo -e "\n${YELLOW}5.${NC} Flash procedure:"
echo -e "   - Boot router and enter ZHAL bootloader"
echo -e "   - Run: ${GREEN}ZHAL> atdc${NC} (disable model check)"
echo -e "   - Run: ${GREEN}ZHAL> atur $RECOMMENDED_FIRMWARE${NC}"
echo -e "   - Transfer via TFTP from another terminal"

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Ready to flash! Good luck! 🎉${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"

# Optional: Offer to open documentation
read -p "Open flashing guide? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command_exists less; then
        less "$SCRIPT_DIR/FIRMWARE_FLASHING_GUIDE.md"
    elif command_exists more; then
        more "$SCRIPT_DIR/FIRMWARE_FLASHING_GUIDE.md"
    else
        cat "$SCRIPT_DIR/FIRMWARE_FLASHING_GUIDE.md"
    fi
fi
