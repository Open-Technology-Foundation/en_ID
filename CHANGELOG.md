# Changelog

All notable changes to the en_ID locale will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Persistence mechanism via `ensure-persistence.sh` script
- `make install-persistent` target for automatic locale regeneration after system updates
- Support for preventing locale removal during glibc/locale package updates
- Automatic setup improvements in installation scripts
- Package manager hooks for Debian/Ubuntu, Fedora/RHEL, and Arch Linux
- `make uninstall`, `make info`, and `make help` targets
- Error handling for git clone failures in installation scripts
- Configurable repository URL via EN_ID_REPO_URL environment variable

### Changed
- Installation scripts now include persistence setup by default
- Improved documentation for troubleshooting locale persistence issues
- Updated README with comprehensive build and installation options
- **Modernized locale definition to use direct UTF-8 text instead of Unicode code points**
  - Replaced legacy `<U0041>` format with direct text like "A"
  - Improved readability and maintainability
  - Aligned with modern locale best practices (en_GB, en_US, etc.)

### Fixed
- Removed unused YELLOW variable from ensure-persistence.sh
- Corrected installation script documentation to reflect automatic setup

## [1.0.0] - 2024-06-26

### Added
- Initial release of en_ID locale
- Support for English language with Indonesian regional settings
- Complete locale definition covering all standard categories:
  - LC_MONETARY: Indonesian Rupiah (IDR) formatting
  - LC_NUMERIC: Decimal point and comma thousands separator
  - LC_TIME: 24-hour format with ISO 8601 dates
  - LC_MESSAGES: English yes/no strings (inherited from en_SG)
  - LC_PAPER: A4 paper size
  - LC_ADDRESS: Indonesian country codes
  - LC_TELEPHONE: International dialing format
  - LC_MEASUREMENT: Metric system
- Comprehensive test suite
- Build system using Makefile
- GitHub Actions CI/CD workflow
- Documentation and contribution guidelines

### Technical Details
- Based on en_GB for British English spelling
- Incorporates Indonesian formatting conventions
- Compatible with GNU libc locale system
- UTF-8 character encoding

[1.0.0]: https://github.com/Open-Technology-Foundation/en_ID/releases/tag/v1.0.0