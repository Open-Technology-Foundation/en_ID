#!/bin/bash
set -euo pipefail

# Script to install en_ID locale and set it as system default
# For Ubuntu Desktop and Server
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

echo -e "${GREEN}Installing en_ID locale as system default...${NC}"

# Update package lists
echo "Updating package lists..."
# Temporarily disable the command-not-found hook if it's broken
declare -r CNF_HOOK="/etc/apt/apt.conf.d/50command-not-found"
declare CNF_DISABLED=false
if [[ -f "$CNF_HOOK" ]] && grep -q "cnf-update-db" "$CNF_HOOK" 2>/dev/null; then
  mv "$CNF_HOOK" "${CNF_HOOK}.disabled" 2>/dev/null && CNF_DISABLED=true
fi

# Now run update
apt-get update -qq

# Restore the hook if we disabled it
if [[ "$CNF_DISABLED" == "true" ]]; then
  mv "${CNF_HOOK}.disabled" "$CNF_HOOK" 2>/dev/null || true
fi

# Install required packages
echo "Installing required packages..."
apt-get install -y -qq git make locales

# Clone the repository to temp directory
declare -r TEMP_DIR=$(mktemp -d)
echo "Downloading en_ID locale..."
git clone --quiet https://github.com/Open-Technology-Foundation/en_ID.git "$TEMP_DIR/en_ID"

# Change to repo directory
cd "$TEMP_DIR/en_ID"

# Install the locale
echo "Installing locale files..."
make install

# Verify installation
if ! locale -a | grep -q "en_ID"; then
    echo -e "${RED}Failed to install en_ID locale${NC}"
    exit 1
fi

echo -e "${GREEN}en_ID locale installed successfully${NC}"

# Backup current locale settings
if [[ -f /etc/default/locale ]]; then
    cp /etc/default/locale /etc/default/locale.backup
    echo "Backed up current locale settings to /etc/default/locale.backup"
fi

# Set en_ID as default locale
echo "Setting en_ID as default locale..."
update-locale LANG=en_ID.UTF-8 \
              LC_ALL=en_ID.UTF-8 \
              LC_CTYPE=en_ID.UTF-8 \
              LC_NUMERIC=en_ID.UTF-8 \
              LC_TIME=en_ID.UTF-8 \
              LC_COLLATE=en_ID.UTF-8 \
              LC_MONETARY=en_ID.UTF-8 \
              LC_MESSAGES=en_ID.UTF-8 \
              LC_PAPER=en_ID.UTF-8 \
              LC_NAME=en_ID.UTF-8 \
              LC_ADDRESS=en_ID.UTF-8 \
              LC_TELEPHONE=en_ID.UTF-8 \
              LC_MEASUREMENT=en_ID.UTF-8 \
              LC_IDENTIFICATION=en_ID.UTF-8

# Also update /etc/environment for some applications
if ! grep -q "LANG=en_ID.UTF-8" /etc/environment; then
    echo "LANG=en_ID.UTF-8" >> /etc/environment
    echo "LC_ALL=en_ID.UTF-8" >> /etc/environment
fi

# Check SSH configuration
declare SSH_CONFIG_UPDATED=false
if [[ -f /etc/ssh/sshd_config ]]; then
    if ! grep -q "^AcceptEnv.*LC_\*" /etc/ssh/sshd_config; then
        echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
        SSH_CONFIG_UPDATED=true
    fi
fi

# Clean up
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Installation complete!${NC}"
echo
echo "Current locale settings:"
locale

echo
echo -e "${YELLOW}IMPORTANT: You need to log out and log back in for the changes to take full effect.${NC}"
echo -e "${YELLOW}For SSH sessions, reconnect to apply the new locale.${NC}"

if [[ "$SSH_CONFIG_UPDATED" == "true" ]]; then
    echo
    echo -e "${YELLOW}NOTE: SSH configuration was updated to accept locale environment variables.${NC}"
    echo -e "${YELLOW}      You should restart the SSH service when convenient:${NC}"
    echo -e "${YELLOW}      sudo systemctl restart ssh${NC}"
fi

# Test the locale
echo
echo "Testing locale (date format):"
LC_ALL=en_ID.UTF-8 date +"%x = %A, %d %B %Y"

exit 0
#fin