#!/bin/bash
set -euo pipefail

# Script to install en_ID locale and automatically set it as system default
# For Fedora/RHEL/CentOS/Rocky/AlmaLinux
# Fully automated installation

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

# Update package lists
echo 'Installing required packages...'
dnf install -y -q git make glibc-locale-source glibc-langpack-en

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

# Use localectl if available (systemd systems)
if command -v localectl &>/dev/null; then
  localectl set-locale LANG=en_ID.UTF-8
fi

# Also update /etc/environment for some applications
if ! grep -q 'LANG=en_ID.UTF-8' /etc/environment 2>/dev/null; then
  echo 'LANG=en_ID.UTF-8' >> /etc/environment
  echo 'LC_ALL=en_ID.UTF-8' >> /etc/environment
fi

# Create DNF/YUM post-transaction hook for persistence
declare -- HOOK_DIR="/etc/dnf/plugins"
declare -- HOOK_FILE="$HOOK_DIR/post-transaction-actions.d/en_id_locale.action"

# Create directory if it doesn't exist
if [[ ! -d "$HOOK_DIR/post-transaction-actions.d" ]]; then
  mkdir -p "$HOOK_DIR/post-transaction-actions.d"
fi

if [[ ! -f "$HOOK_FILE" ]]; then
  cat > "$HOOK_FILE" << 'EOF'
# Regenerate en_ID locale after glibc updates
glibc*:update:/usr/bin/localedef -i en_ID -f UTF-8 en_ID.UTF-8 2>/dev/null || true
glibc*:install:/usr/bin/localedef -i en_ID -f UTF-8 en_ID.UTF-8 2>/dev/null || true
EOF
  echo 'Created DNF/YUM hook to maintain en_ID locale after system updates'
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

# Test the locale
echo
echo 'Testing locale (date format):'
LC_ALL=en_ID.UTF-8 date +"%x = %A, %d %B %Y"

exit 0
#fin