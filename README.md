# English Locale for Indonesia (en_ID)

A locale definition for English language users in Indonesia, combining international English standards with Indonesian regional conventions.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Design Decisions](#design-decisions)
- [Contributing](#contributing)
- [License](#license)

## Overview

The `en_ID` locale provides English language support tailored for Indonesia. It combines:
- **British English** spelling conventions (inherited from `en_GB`)
- **Indonesian** currency format (IDR/Rp)
- **International** business standards (ISO 8601 dates, Anglo number formatting, 24-hour time)

### Who needs this?

- International businesses operating in Indonesia
- Indonesian professionals working in English
- Software systems requiring English UI with Indonesian regional settings
- Educational institutions using English as medium of instruction

## Features

| Category | Setting | Example |
|----------|---------|---------|
| **Language** | English (British spelling) | colour, centre |
| **Currency** | Indonesian Rupiah | Rp 1,234,567.89 |
| **Numbers** | Decimal point, comma separator | 1,234,567.89 |
| **Date** | ISO 8601 format | 2024-01-15 |
| **Time** | 24-hour format | 14:30:45 |
| **First Day** | Monday | - |
| **Paper** | A4 (297×210mm) | - |
| **Measurement** | Metric | - |

## Quick Start

Install en_ID as your default locale with one command:

### Ubuntu/Debian
```bash
wget -O- https://raw.githubusercontent.com/Open-Technology-Foundation/en_ID/main/install-ubuntu.sh | sudo bash
```

### Fedora/RHEL/CentOS
```bash
wget -O- https://raw.githubusercontent.com/Open-Technology-Foundation/en_ID/main/install-fedora.sh | sudo bash
```

### Arch Linux
```bash
wget -O- https://raw.githubusercontent.com/Open-Technology-Foundation/en_ID/main/install-arch.sh | sudo bash
```

## Installation

### Automated Installation

The quick start commands above will:
- ✓ Install the en_ID locale files
- ✓ Generate the locale
- ✓ Optionally set as system default
- ✓ Backup existing locale settings
- ✓ Test the installation

### Manual Installation

<details>
<summary>Ubuntu/Debian</summary>

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID

# Install
sudo make install

# Verify
locale -a | grep en_ID
```
</details>

<details>
<summary>Fedora/RHEL/CentOS</summary>

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID

# Install locale file
sudo cp localedata/en_ID /usr/share/i18n/locales/

# Generate locale
sudo localedef -i en_ID -f UTF-8 en_ID.UTF-8

# Set as default (optional)
sudo localectl set-locale LANG=en_ID.UTF-8
```
</details>

<details>
<summary>Arch Linux</summary>

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID

# Install locale file
sudo cp localedata/en_ID /usr/share/i18n/locales/

# Add to locale.gen
echo "en_ID.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen

# Generate locale
sudo locale-gen

# Set as default (optional)
echo "LANG=en_ID.UTF-8" | sudo tee /etc/locale.conf
```
</details>

**Note**: Systems may display the locale as `en_ID.utf8` or `en_ID.UTF-8`. Both refer to the same locale.

## Usage

### Set as System Default
```bash
# Ubuntu/Debian
sudo update-locale LANG=en_ID.UTF-8 LC_ALL=en_ID.UTF-8

# Fedora/RHEL
sudo localectl set-locale LANG=en_ID.UTF-8

# Arch Linux
echo "LANG=en_ID.UTF-8" | sudo tee /etc/locale.conf
```

### Use in Current Session
```bash
export LANG=en_ID.UTF-8
export LC_ALL=en_ID.UTF-8
```

### Use for Single Application
```bash
LC_ALL=en_ID.UTF-8 your-application
```

**Important**: Use `LC_ALL` to ensure all locale categories use en_ID. Using only `LANG` may result in some categories falling back to system defaults.

## Testing

Verify your installation:

```bash
# Check if installed
locale -a | grep en_ID

# Test date format (should show: 2024-01-15)
LC_ALL=en_ID.UTF-8 date +%x

# Test time format (should show: 14:30:45)
LC_ALL=en_ID.UTF-8 date +%X

# Test currency (number formatting)
LC_MONETARY=en_ID.UTF-8 printf "%'.2f\n" 1234567.89
# Output: 1,234,567.89

# Show all locale settings
LC_ALL=en_ID.UTF-8 locale
```

## Design Decisions

### LC_NAME Omission

The LC_NAME category is intentionally left minimal. Indonesian naming conventions don't map to Western name formatting:

- **Single names** are common (Sukarno, Suharto, Junarti)
- **Name origins** vary widely (Javanese, Balinese, Chinese, Arabic)
- **Titles** like Pak/Bu are Indonesian, not English
- **English contexts** typically use Mr./Ms. anyway

Rather than misrepresent Indonesian names, LC_NAME uses a minimal definition.

### Date and Number Formats

This locale uses international business formats rather than traditional Indonesian formats:
- **Dates**: ISO 8601 (YYYY-MM-DD) instead of Indonesian DD/MM/YYYY
- **Numbers**: Anglo format (1,234.56) instead of Indonesian (1.234,56)

This design choice prioritizes international compatibility for English-language business and technical contexts.

### British vs American English

British English was chosen because:
- It's the standard in Indonesian education
- Used by neighboring Singapore and Malaysia
- Common in Commonwealth countries

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Reporting Issues

Please report bugs or suggestions via [GitHub Issues](https://github.com/Open-Technology-Foundation/en_ID/issues).

## License

This locale definition is released under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.

## Author

Created and maintained by [Yayasan Teknologi Terbuka Indonesia](https://yatti.id) (Indonesian Open Technology Foundation).

Contact: admin@yatti.id

## See Also

- [GNU C Library Locales](https://www.gnu.org/software/libc/manual/html_node/Locales.html)
- [ISO 639 Language Codes](https://www.loc.gov/standards/iso639-2/)
- [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html)
- [Unicode CLDR](http://cldr.unicode.org/)

