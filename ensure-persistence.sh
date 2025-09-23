#!/bin/bash
set -euo pipefail

# Script to ensure en_ID locale persists through system updates
# Works on Debian/Ubuntu, Fedora/RHEL, and Arch Linux systems

# Colors for output
declare -- RED='' GREEN='' NC=''
if [[ -t 2 ]]; then
  RED=$'\033[0;31m'
  GREEN='\033[0;32m'
  NC=$'\033[0m'
fi
readonly -- RED GREEN NC

# Check if running as root
if ((EUID)); then
  >&2 echo -e "${RED}This script must be run as root or with sudo${NC}"
  exit 1
fi

echo -e "${GREEN}Ensuring en_ID locale persistence...${NC}"

# Detect distribution
declare -- DISTRO=""
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
    DISTRO="debian"
  elif [[ "$ID" == "fedora" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "centos" ]] || [[ "$ID_LIKE" == *"rhel"* ]] || [[ "$ID_LIKE" == *"fedora"* ]]; then
    DISTRO="fedora"
  elif [[ "$ID" == "arch" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    DISTRO="arch"
  fi
fi

if [[ -z "$DISTRO" ]]; then
  >&2 echo -e "${RED}Unable to detect distribution${NC}"
  exit 1
fi

echo "Detected distribution: $DISTRO"

# Check if en_ID locale definition exists
if [[ ! -f /usr/share/i18n/locales/en_ID ]]; then
  >&2 echo -e "${RED}en_ID locale definition not found at /usr/share/i18n/locales/en_ID${NC}"
  echo "Please install the en_ID locale first using the appropriate install script."
  exit 1
fi

declare -i changes_made=0

# Debian/Ubuntu specific persistence
if [[ "$DISTRO" == "debian" ]]; then
  echo "Setting up Debian/Ubuntu persistence mechanisms..."

  # Add to locale.gen
  if [[ -f /etc/locale.gen ]]; then
    if ! grep -q "^en_ID.UTF-8" /etc/locale.gen; then
      echo "en_ID.UTF-8 UTF-8" >> /etc/locale.gen
      echo -e "${GREEN}Added en_ID to /etc/locale.gen${NC}"
      changes_made=1
    else
      echo "en_ID already in /etc/locale.gen"
    fi
  fi

  # Create APT hook
  declare -- APT_HOOK_FILE="/etc/apt/apt.conf.d/99en-id-locale-gen"
  if [[ ! -f "$APT_HOOK_FILE" ]]; then
    cat > "$APT_HOOK_FILE" << 'EOF'
// Automatically regenerate en_ID locale after package updates
DPkg::Post-Invoke { "if [ -f /etc/locale.gen ] && grep -q '^en_ID.UTF-8' /etc/locale.gen; then locale-gen en_ID.UTF-8 2>/dev/null || true; fi"; };
EOF
    echo -e "${GREEN}Created APT hook for automatic locale regeneration${NC}"
    changes_made=1
  else
    echo "APT hook already exists"
  fi

  # Regenerate locale now
  if ((changes_made)); then
    echo "Regenerating locale..."
    locale-gen en_ID.UTF-8
  fi

# Fedora/RHEL specific persistence
elif [[ "$DISTRO" == "fedora" ]]; then
  echo "Setting up Fedora/RHEL persistence mechanisms..."

  # Create DNF/YUM post-transaction hook
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
    echo -e "${GREEN}Created DNF/YUM hook for automatic locale regeneration${NC}"
    changes_made=1
  else
    echo "DNF/YUM hook already exists"
  fi

  # Regenerate locale now
  echo "Regenerating locale..."
  localedef -i en_ID -f UTF-8 en_ID.UTF-8

# Arch Linux specific persistence
elif [[ "$DISTRO" == "arch" ]]; then
  echo "Setting up Arch Linux persistence mechanisms..."

  # Add to locale.gen
  if [[ -f /etc/locale.gen ]]; then
    if ! grep -q "^en_ID.UTF-8" /etc/locale.gen; then
      echo "en_ID.UTF-8 UTF-8" >> /etc/locale.gen
      echo -e "${GREEN}Added en_ID to /etc/locale.gen${NC}"
      changes_made=1
    else
      echo "en_ID already in /etc/locale.gen"
    fi
  fi

  # Create pacman hook
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
    echo -e "${GREEN}Created Pacman hook for automatic locale regeneration${NC}"
    changes_made=1
  else
    echo "Pacman hook already exists"
  fi

  # Regenerate locale now
  if ((changes_made)); then
    echo "Regenerating locale..."
    locale-gen
  fi
fi

# Verify locale is available
echo
echo "Verifying locale availability..."
if locale -a 2>/dev/null | grep -q 'en_ID'; then
  echo -e "${GREEN}✓ en_ID locale is available${NC}"
else
  >&2 echo -e "${RED}✗ en_ID locale is not available${NC}"
  exit 1
fi

# Test the locale
echo
echo "Testing locale..."
if LC_ALL=en_ID.UTF-8 date +"%x" >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Locale test successful${NC}"
  LC_ALL=en_ID.UTF-8 date +"%x = %A, %d %B %Y"
else
  >&2 echo -e "${RED}✗ Locale test failed${NC}"
  exit 1
fi

echo
echo -e "${GREEN}Persistence mechanisms successfully configured!${NC}"
echo
echo "The en_ID locale will now be automatically regenerated after system updates."
echo "This prevents the locale from being removed when glibc or locale packages are updated."

exit 0
#fin