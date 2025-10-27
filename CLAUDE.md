# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository implements the `en_ID` locale - an English language locale tailored for Indonesia. It combines British English spelling with Indonesian regional conventions (currency, timezone, etc.) for use by international businesses and Indonesian professionals working in English.

## Core Commands

### Building and Testing
```bash
# Check locale syntax and compile to build directory
make

# Run full test suite
make test

# Install locale system-wide (requires sudo)
make install

# Install with persistence across system updates
make install-persistent

# Clean build artifacts
make clean
```

### Testing Specific Categories
```bash
# Test individual locale categories
./tests/test_en_ID.sh LC_TIME
./tests/test_en_ID.sh LC_MONETARY
./tests/test_en_ID.sh LC_NUMERIC
```

## Architecture

The locale is defined in a single file (`localedata/en_ID`) using GNU libc format with direct UTF-8 text. Key design decisions:

- **Inherits from en_GB**: British English spelling and language conventions
- **ISO 8601 dates**: YYYY-MM-DD format for international compatibility
- **Anglo number format**: Decimal point with comma separator (1,234.56)
- **24-hour time**: Standard international business format
- **Indonesian Rupiah**: Currency formatted as "Rp 1,234,567.89"
- **Minimal LC_NAME**: Indonesian naming conventions don't map to Western formats

## Installation Scripts

Distribution-specific installation scripts are provided:
- `install-ubuntu.sh`: For Ubuntu/Debian systems
- `install-fedora.sh`: For Fedora/RHEL/CentOS systems
- `install-arch.sh`: For Arch Linux systems
- `ensure-persistence.sh`: Cross-platform script to ensure locale persists through system updates

Each installation script:
1. Installs the locale file to `/usr/share/i18n/locales/`
2. Generates the compiled locale
3. Optionally sets as system default
4. Creates backups of existing locale settings
5. Runs verification tests

The persistence script creates appropriate configuration files for each distribution to prevent locale removal during system updates.

## Working with the Locale Definition

The locale file uses modern direct UTF-8 text format for better readability. When modifying:
- Maintain consistent indentation
- Follow GNU libc locale format specifications
- Use direct UTF-8 text (e.g., "Monday", "Rp") instead of Unicode code points
- Test changes with `make test` before committing
- Document rationale for non-obvious choices in comments

## Key Files

- `localedata/en_ID`: The actual locale definition file
- `tests/test_en_ID.sh`: Comprehensive test script for all locale categories
- `Makefile`: Build system for checking, compiling, and installing