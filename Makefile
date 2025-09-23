# Makefile for en_ID locale

PREFIX ?= /usr
LOCALEDIR = $(PREFIX)/share/i18n/locales
CHARMAP = UTF-8
LOCALE_NAME = en_ID
LOCALE_FILE = localedata/$(LOCALE_NAME)

.PHONY: all install install-persistent uninstall test clean compile check

all: check compile

# Check locale file syntax
check:
	@echo "Checking locale file syntax..."
	@localedef --verbose --charmap=$(CHARMAP) --inputfile=$(LOCALE_FILE) 2>&1 | grep -E "(error|warning)" || echo "Syntax check passed"

# Compile locale to test
compile:
	@echo "Compiling locale..."
	@mkdir -p build
	@localedef -f $(CHARMAP) -i $(LOCALE_FILE) ./build/$(LOCALE_NAME).$(CHARMAP)

# Install locale system-wide
install: check
	@echo "Installing $(LOCALE_NAME) locale..."
	@sudo install -D -m 644 $(LOCALE_FILE) $(LOCALEDIR)/$(LOCALE_NAME)
	@echo "Generating locale..."
	@sudo localedef --charmap=$(CHARMAP) --inputfile=$(LOCALEDIR)/$(LOCALE_NAME) $(LOCALE_NAME).$(CHARMAP)
	@echo "Locale $(LOCALE_NAME).$(CHARMAP) installed successfully"
	@echo "Run 'locale -a | grep $(LOCALE_NAME)' to verify"

# Install with persistence mechanisms for Debian/Ubuntu
install-persistent: install
	@echo "Adding persistence mechanisms..."
	@if [ -f /etc/locale.gen ]; then \
		if ! grep -q "^$(LOCALE_NAME).$(CHARMAP)" /etc/locale.gen; then \
			echo "$(LOCALE_NAME).$(CHARMAP) $(CHARMAP)" | sudo tee -a /etc/locale.gen > /dev/null; \
			echo "Added $(LOCALE_NAME) to /etc/locale.gen"; \
		fi; \
	fi
	@if [ -d /etc/apt/apt.conf.d ] && [ ! -f /etc/apt/apt.conf.d/99en-id-locale-gen ]; then \
		echo 'DPkg::Post-Invoke { "if [ -f /etc/locale.gen ] && grep -q \"^$(LOCALE_NAME).$(CHARMAP)\" /etc/locale.gen; then locale-gen $(LOCALE_NAME).$(CHARMAP) 2>/dev/null || true; fi"; };' | sudo tee /etc/apt/apt.conf.d/99en-id-locale-gen > /dev/null; \
		echo "Created APT hook for automatic locale regeneration"; \
	fi
	@echo "Persistence mechanisms installed"

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
	@echo "  all               - Check syntax and compile (default)"
	@echo "  check             - Check locale file syntax"
	@echo "  compile           - Compile locale to build directory"
	@echo "  install           - Install locale system-wide (requires sudo)"
	@echo "  install-persistent- Install with persistence mechanisms (Debian/Ubuntu)"
	@echo "  uninstall         - Remove locale from system (requires sudo)"
	@echo "  test              - Run test suite"
	@echo "  clean             - Remove build artifacts"
	@echo "  info              - Display locale information"
	@echo "  help              - Show this help message"