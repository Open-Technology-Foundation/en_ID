#!/bin/bash
set -euo pipefail

# Script to install en_ID locale and set it as system default
# For Ubuntu Desktop and Server
# No user intervention

# Colors for output
declare -- RED='' GREEN='' YELLOW='' NC=''
if [[ -t 2 ]]; then
  RED=$'\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW=$'\033[0;33m' 
  NC=$'\033[0m'
fi
readonly -- RED GREEN YELLOW NC

# Check if running as root
if ((EUID)); then
  >&2 echo -e "${RED}This script must be run as root or with sudo${NC}"
  exit 1
fi

echo -e "${GREEN}Installing en_ID locale as system default...${NC}"

# Update package lists
echo 'Updating package lists...'
# Find and temporarily disable command-not-found hook if it exists
declare -- CNF_HOOK=''
for conf in /etc/apt/apt.conf.d/*; do
  if grep -q 'cnf-update-db' "$conf" 2>/dev/null; then
    CNF_HOOK="$conf"
    break
  fi
done
# If we found the problematic hook, disable it temporarily
if [[ -n "$CNF_HOOK" ]]; then
  mv "$CNF_HOOK" "$CNF_HOOK".disabled 2>/dev/null || true
  apt-get update -qq
  mv "$CNF_HOOK".disabled "$CNF_HOOK" 2>/dev/null || true
else
  # No problematic hook found, run normally
  apt-get update -qq
fi

# Install required packages
echo 'Installing required packages...'
apt-get install -y -qq git make locales

# Clone the repository to temp directory
declare -- TEMP_DIR
TEMP_DIR=$(mktemp -d)
echo 'Downloading en_ID locale...'
git clone --quiet https://github.com/Open-Technology-Foundation/en_ID.git "$TEMP_DIR"/en_ID

# Change to repo directory
cd "$TEMP_DIR"/en_ID

# Install the locale
echo 'Installing locale files...'
make install

# Verify installation
if ! locale -a | grep -q 'en_ID'; then
  >&2 echo -e "${RED}Failed to install en_ID locale${NC}"
  exit 1
fi

echo -e "${GREEN}en_ID locale installed successfully${NC}"

# Backup current locale settings
if [[ -f /etc/default/locale ]]; then
  cp /etc/default/locale /etc/default/locale.backup
  echo 'Backed up current locale settings to /etc/default/locale.backup'
fi

# Set en_ID as default locale
echo 'Setting en_ID as default locale...'
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
if ! grep -q 'LANG=en_ID.UTF-8' /etc/environment; then
  echo 'LANG=en_ID.UTF-8' >> /etc/environment
  echo 'LC_ALL=en_ID.UTF-8' >> /etc/environment
fi

# Check SSH configuration
declare -i SSH_CONFIG_UPDATED=0
if [[ -f /etc/ssh/sshd_config ]]; then
  if ! grep -q "^AcceptEnv.*LC_\*" /etc/ssh/sshd_config; then
    echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
    SSH_CONFIG_UPDATED=1
  fi
fi

# Clean up
rm -rf "${TEMP_DIR:?}"

echo -e "${GREEN}Installation complete!${NC}"
echo
echo 'Current locale settings:'
locale

echo
echo -e "${YELLOW}IMPORTANT: You need to log out and log back in for the changes to take full effect.${NC}"
echo -e "${YELLOW}For SSH sessions, reconnect to apply the new locale.${NC}"

if ((SSH_CONFIG_UPDATED)); then
  echo
  echo -e "${YELLOW}NOTE: SSH configuration was updated to accept locale environment variables.${NC}"
  echo -e "${YELLOW}      You should restart the SSH service when convenient:${NC}"
  echo -e "${YELLOW}      sudo systemctl restart ssh${NC}"
fi

# Test the locale
echo
echo 'Testing locale (date format):'
LC_ALL=en_ID.UTF-8 date +"%x = %A, %d %B %Y"

exit 0
#fin
