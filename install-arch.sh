#!/bin/bash
set -euo pipefail

# Script to install en_ID locale on Arch Linux
# No user intervention required

# Colors for output
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[1;33m'
declare -r NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root or with sudo${NC}"
   exit 1
fi

echo -e "${GREEN}Installing en_ID locale on Arch Linux...${NC}"

# Install required packages
echo "Installing required packages..."
pacman -S --needed --noconfirm git make glibc

# Clone the repository to temp directory
declare -r TEMP_DIR=$(mktemp -d)
echo "Downloading en_ID locale..."
git clone --quiet https://github.com/Open-Technology-Foundation/en_ID.git "$TEMP_DIR/en_ID"

# Copy locale file to system location
echo "Installing locale file..."
cp "$TEMP_DIR/en_ID/localedata/en_ID" /usr/share/i18n/locales/

# Add to locale.gen if not already present
if ! grep -q "^en_ID.UTF-8" /etc/locale.gen; then
    echo "en_ID.UTF-8 UTF-8" >> /etc/locale.gen
fi

# Generate locales
echo "Generating locale..."
locale-gen

# Verify installation
if ! locale -a | grep -q "en_ID"; then
    echo -e "${RED}Failed to install en_ID locale${NC}"
    exit 1
fi

echo -e "${GREEN}en_ID locale installed successfully${NC}"

# Set as default if requested
read -p "Set en_ID as system default locale? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Backup current locale settings
    if [[ -f /etc/locale.conf ]]; then
        cp /etc/locale.conf /etc/locale.conf.backup
        echo "Backed up current locale settings to /etc/locale.conf.backup"
    fi
    
    # Set system locale
    echo "LANG=en_ID.UTF-8" > /etc/locale.conf
    echo "LC_ALL=en_ID.UTF-8" >> /etc/locale.conf
    
    # Update for current session
    export LANG=en_ID.UTF-8
    export LC_ALL=en_ID.UTF-8
fi

# Clean up
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Installation complete!${NC}"
echo
echo "Current locale settings:"
locale

# Test the locale
echo
echo "Testing locale (date format):"
LC_ALL=en_ID.UTF-8 date +"%x = %A, %d %B %Y"

echo
echo -e "${YELLOW}Log out and back in for changes to take full effect.${NC}"

# Arch-specific note
echo -e "${YELLOW}Note: You may need to regenerate your initramfs if using early userspace.${NC}"
echo -e "${YELLOW}      Run: mkinitcpio -P${NC}"

exit 0
#fin