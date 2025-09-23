#!/bin/bash
set -euo pipefail

# Script to install en_ID locale and automatically set it as system default
# For Arch Linux and derivatives
# Fully automated installation with persistence

# Repository URL (can be overridden by environment variable)
readonly REPO_URL="${EN_ID_REPO_URL:-https://github.com/Open-Technology-Foundation/en_ID.git}"

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

# Install required packages
echo 'Installing required packages...'
pacman -S --needed --noconfirm git make glibc

# Clone the repository to temp directory
declare -- TEMP_DIR
TEMP_DIR=$(mktemp -d)
echo 'Downloading en_ID locale...'
if ! git clone --quiet "$REPO_URL" "$TEMP_DIR"/en_ID; then
  >&2 echo -e "${RED}Failed to download en_ID repository${NC}"
  rm -rf "${TEMP_DIR:?}"
  exit 1
fi

# Change to repo directory
cd "$TEMP_DIR"/en_ID

# Install the locale
echo 'Installing locale files...'
make install

# Add to locale.gen if not already present
if ! grep -q "^en_ID.UTF-8" /etc/locale.gen; then
  echo "en_ID.UTF-8 UTF-8" >> /etc/locale.gen
fi

# Generate locales
echo 'Generating locale...'
locale-gen

# Verify installation
if ! locale -a | grep -q 'en_ID'; then
  >&2 echo -e "${RED}Failed to install en_ID locale${NC}"
  exit 1
fi

echo -e "${GREEN}en_ID locale installed successfully${NC}"

# Backup current locale settings
if [[ -f /etc/locale.conf ]]; then
  cp /etc/locale.conf /etc/locale.conf.backup
  echo 'Backed up current locale settings to /etc/locale.conf.backup'
fi

# Set en_ID as default locale
echo 'Setting en_ID as default locale...'
# Write comprehensive locale settings
cat > /etc/locale.conf <<EOF
LANG=en_ID.UTF-8
LC_ALL=en_ID.UTF-8
LC_CTYPE=en_ID.UTF-8
LC_NUMERIC=en_ID.UTF-8
LC_TIME=en_ID.UTF-8
LC_COLLATE=en_ID.UTF-8
LC_MONETARY=en_ID.UTF-8
LC_MESSAGES=en_ID.UTF-8
LC_PAPER=en_ID.UTF-8
LC_NAME=en_ID.UTF-8
LC_ADDRESS=en_ID.UTF-8
LC_TELEPHONE=en_ID.UTF-8
LC_MEASUREMENT=en_ID.UTF-8
LC_IDENTIFICATION=en_ID.UTF-8
EOF

# Also update /etc/environment for some applications
if ! grep -q 'LANG=en_ID.UTF-8' /etc/environment 2>/dev/null; then
  echo 'LANG=en_ID.UTF-8' >> /etc/environment
  echo 'LC_ALL=en_ID.UTF-8' >> /etc/environment
fi

# Create pacman hook for persistence
declare -- HOOK_DIR="/etc/pacman.d/hooks"
declare -- HOOK_FILE="$HOOK_DIR/en_id_locale.hook"

# Create directory if it doesn't exist
if [[ ! -d "$HOOK_DIR" ]]; then
  mkdir -p "$HOOK_DIR"
fi

if [[ ! -f "$HOOK_FILE" ]]; then
  cat > "$HOOK_FILE" << 'EOF'
[Trigger]
Operation = Upgrade
Type = Package
Target = glibc

[Action]
Description = Regenerate en_ID locale
When = PostTransaction
Exec = /usr/bin/bash -c "if grep -q '^en_ID.UTF-8' /etc/locale.gen; then locale-gen en_ID.UTF-8 2>/dev/null || true; fi"
EOF
  echo 'Created Pacman hook to maintain en_ID locale after system updates'
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
  echo -e "${YELLOW}      sudo systemctl restart sshd${NC}"
fi

# Arch-specific note
echo
echo -e "${YELLOW}Note: You may need to regenerate your initramfs if using early userspace.${NC}"
echo -e "${YELLOW}      Run: mkinitcpio -P${NC}"

# Test the locale
echo
echo 'Testing locale (date format):'
LC_ALL=en_ID.UTF-8 date +"%x = %A, %d %B %Y"

exit 0
#fin