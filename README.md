# English Locale for Indonesia (en_ID)

A locale definition for English language users in Indonesia, combining international English standards with Indonesian regional conventions.

## Overview

The `en_ID` locale provides English language support tailored for use in Indonesia. It's designed as a hybrid locale that:
- Uses British English spelling conventions (inherited from `en_GB`)
- Adopts Indonesian monetary, numeric, and date/time formats
- Follows Indonesian business conventions

## Features

- **Language**: English (British spelling)
- **Currency**: Indonesian Rupiah (IDR/Rp)
- **Number Format**: Decimal point (.), comma thousand separator (,)
- **Date Format**: ISO 8601 (YYYY-MM-DD)
- **Time Format**: 24-hour
- **First Weekday**: Monday
- **Paper Size**: A4 (297×210mm)
- **Measurement**: Metric

### Note on LC_NAME

The LC_NAME category has been intentionally omitted from this locale. Indonesian naming conventions are highly diverse and don't map well to the Western-centric name formatting system:

- Single names are common (e.g., Sukarno, Suharto, Junarti)
- Names may be of Javanese, Balinese, Chinese, Arabic, or other origins
- Traditional titles (Pak/Bu) are Indonesian language, not English
- In English contexts, Indonesians typically use Mr./Ms. anyway

Rather than force Indonesian names into an incompatible structure, LC_NAME is left undefined.

## Installation

### From Source

1. Clone this repository:
```bash
git clone https://github.com/Open-Technology-Foundation/en_ID.git
cd en_ID
```

2. Build and install the locale:
```bash
sudo make install
```

3. Verify installation:
```bash
locale -a | grep en_ID
# Should show: en_ID.utf8
```

Note: The system may show the locale as `en_ID.utf8` rather than `en_ID.UTF-8`. Both refer to the same locale.

### Testing Installation

```bash
# Test if locale is available
locale -a | grep en_ID

# Test locale settings (use either format)
LANG=en_ID.UTF-8 locale
# or
LANG=en_ID.utf8 locale

# Quick test - should show date in YYYY-MM-DD format
LANG=en_ID.utf8 date +%x
```

## Usage

### System-wide
```bash
sudo update-locale LANG=en_ID.UTF-8
```

### Per-session
```bash
export LANG=en_ID.UTF-8
export LC_ALL=en_ID.UTF-8
```

### Application-specific
```bash
LANG=en_ID.UTF-8 your-application
```

## Examples

```bash
# Date format
$ LANG=en_ID.UTF-8 date +%x
2024-01-15

# Currency format
$ LANG=en_ID.UTF-8 printf "%'.2f\n" 1234567.89
Rp1,234,567.89

# Time format (24-hour)
$ LANG=en_ID.UTF-8 date +%X
14:30:45
```

## Rationale

This locale addresses the needs of:
- International businesses operating in Indonesia
- Indonesian professionals working in English
- Software systems requiring English UI with Indonesian regional settings
- Educational institutions using English as medium of instruction

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on submitting improvements.

## License

This locale definition is released under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.

## Author

Created and maintained by Yayasan Teknologi Terbuka Indonesia.

## See Also

- [GNU C Library Locales](https://www.gnu.org/software/libc/manual/html_node/Locales.html)
- [ISO 639 Language Codes](https://www.loc.gov/standards/iso639-2/)
- [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html)