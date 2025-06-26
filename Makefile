# Makefile for en_ID locale

PREFIX ?= /usr
LOCALEDIR = $(PREFIX)/share/i18n/locales
CHARMAP = UTF-8
LOCALE_NAME = en_ID
LOCALE_FILE = localedata/$(LOCALE_NAME)

.PHONY: all install uninstall test clean compile check

all: check compile

# Check locale file syntax
check:
	@echo "Checking locale file syntax..."
	@localedef --verbose --charmap=$(CHARMAP) --inputfile=$(LOCALE_FILE) 2>&1 | grep -E "(error|warning)" || echo "Syntax check passed"

# Compile locale to test
compile:
	@echo "Compiling locale..."
	@mkdir -p build
	@localedef --verbose --charmap=$(CHARMAP) --inputfile=$(LOCALE_FILE) --outputdir=build $(LOCALE_NAME).$(CHARMAP)

# Install locale system-wide
install: check
	@echo "Installing $(LOCALE_NAME) locale..."
	@sudo install -D -m 644 $(LOCALE_FILE) $(LOCALEDIR)/$(LOCALE_NAME)
	@echo "Generating locale..."
	@sudo localedef --charmap=$(CHARMAP) --inputfile=$(LOCALEDIR)/$(LOCALE_NAME) $(LOCALE_NAME).$(CHARMAP)
	@echo "Locale $(LOCALE_NAME).$(CHARMAP) installed successfully"
	@echo "Run 'locale -a | grep $(LOCALE_NAME)' to verify"

# Uninstall locale
uninstall:
	@echo "Removing $(LOCALE_NAME) locale..."
	@sudo rm -f $(LOCALEDIR)/$(LOCALE_NAME)
	@sudo localedef --delete-from-archive $(LOCALE_NAME).$(CHARMAP) 2>/dev/null || true
	@echo "Locale $(LOCALE_NAME) removed"

# Run tests
test: compile
	@echo "Running locale tests..."
	@./tests/test_en_ID.sh

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build

# Display locale info
info:
	@echo "Locale: $(LOCALE_NAME)"
	@echo "Charmap: $(CHARMAP)"
	@echo "Source: $(LOCALE_FILE)"
	@echo "Install path: $(LOCALEDIR)/$(LOCALE_NAME)"

# Help
help:
	@echo "Available targets:"
	@echo "  all      - Check syntax and compile (default)"
	@echo "  check    - Check locale file syntax"
	@echo "  compile  - Compile locale to build directory"
	@echo "  install  - Install locale system-wide (requires sudo)"
	@echo "  uninstall- Remove locale from system (requires sudo)"
	@echo "  test     - Run test suite"
	@echo "  clean    - Remove build artifacts"
	@echo "  info     - Display locale information"
	@echo "  help     - Show this help message"