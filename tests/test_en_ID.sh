#!/bin/bash
set -uo pipefail

# Test script for en_ID locale
# Usage: ./test_en_ID.sh [category]

declare -r LOCALE="en_ID.UTF-8"
declare -r BUILD_DIR="$(dirname "$0")/../build"
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0

# Colors for output
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[1;33m'
declare -r NC='\033[0m' # No Color

# Test function
run_test() {
  local description="$1"
  local command="$2"
  local expected="$3"
  
  echo -n "Testing $description... "
  
  # Set locale path to our build directory
  local actual
  actual=$(LOCPATH="$BUILD_DIR" LC_ALL="$LOCALE" $command 2>/dev/null || echo "")
  
  if [[ "$actual" == "$expected" ]]; then
    echo -e "${GREEN}PASSED${NC}"
    ((TESTS_PASSED++))
  else
    echo -e "${RED}FAILED${NC}"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    ((TESTS_FAILED++))
  fi
}

# Test categories
test_monetary() {
  echo -e "\n${YELLOW}Testing LC_MONETARY${NC}"
  
  # Test currency symbol
  run_test "currency symbol" "locale currency_symbol" "Rp"
  
  # Test international currency symbol  
  run_test "int_curr_symbol" "locale int_curr_symbol" "IDR "
  
  # Test decimal point
  run_test "mon_decimal_point" "locale mon_decimal_point" "."
  
  # Test thousands separator
  run_test "mon_thousands_sep" "locale mon_thousands_sep" ","
}

test_numeric() {
  echo -e "\n${YELLOW}Testing LC_NUMERIC${NC}"
  
  # Test decimal point
  run_test "decimal_point" "locale decimal_point" "."
  
  # Test thousands separator
  run_test "thousands_sep" "locale thousands_sep" ","
  
  # Test number formatting - note: may show warnings in build environment
  echo "  Note: Number formatting may show warnings without system locale"
}

test_time() {
  echo -e "\n${YELLOW}Testing LC_TIME${NC}"
  
  # Note: date command tests require system locale installation
  # These tests verify the locale file has correct data
  echo "  Note: Time format tests require system locale installation"
  echo "  Skipping date/time formatting tests in build environment"
}

test_messages() {
  echo -e "\n${YELLOW}Testing LC_MESSAGES${NC}"
  
  # Test yes/no expressions (en_SG uses different patterns)
  run_test "yesexpr" "locale yesexpr" "^[+1yY]"
  run_test "noexpr" "locale noexpr" "^[-0nN]"
  run_test "yesstr" "locale yesstr" "yes"
  run_test "nostr" "locale nostr" "no"
}

test_paper() {
  echo -e "\n${YELLOW}Testing LC_PAPER${NC}"
  
  # Test paper size (A4)
  run_test "paper height" "locale height" "297"
  run_test "paper width" "locale width" "210"
}

test_telephone() {
  echo -e "\n${YELLOW}Testing LC_TELEPHONE${NC}"
  
  # Test international format
  run_test "tel_int_fmt" "locale tel_int_fmt" "+%c ;%a ;%l"
}

test_address() {
  echo -e "\n${YELLOW}Testing LC_ADDRESS${NC}"
  
  # Test country codes
  run_test "country_ab2" "locale country_ab2" "ID"
  run_test "country_ab3" "locale country_ab3" "IDN"
  run_test "country_num" "locale country_num" "360"
}

test_measurement() {
  echo -e "\n${YELLOW}Testing LC_MEASUREMENT${NC}"
  
  # Test measurement system (1 = metric)
  run_test "measurement" "locale measurement" "1"
}

# Main execution
main() {
  echo "======================================"
  echo "Testing en_ID locale"
  echo "======================================"
  
  # Check if locale is available in build directory
  if [[ ! -d "$BUILD_DIR/$LOCALE" ]]; then
    echo -e "${RED}Error: Locale not found in build directory${NC}"
    echo "Please run 'make compile' first"
    exit 1
  fi
  
  # Run specific test or all tests
  local category="${1:-all}"
  
  case "$category" in
    LC_MONETARY) test_monetary ;;
    LC_NUMERIC) test_numeric ;;
    LC_TIME) test_time ;;
    LC_MESSAGES) test_messages ;;
    LC_PAPER) test_paper ;;
    LC_TELEPHONE) test_telephone ;;
    LC_ADDRESS) test_address ;;
    LC_MEASUREMENT) test_measurement ;;
    all)
      test_monetary
      test_numeric
      test_time
      test_messages
      test_paper
      test_telephone
      test_address
      test_measurement
      ;;
    *)
      echo "Unknown category: $category"
      echo "Usage: $0 [category|all]"
      echo "Categories: LC_MONETARY, LC_NUMERIC, LC_TIME, LC_MESSAGES, LC_PAPER, LC_TELEPHONE, LC_ADDRESS, LC_MEASUREMENT"
      exit 1
      ;;
  esac
  
  # Summary
  echo -e "\n======================================"
  echo "Test Summary:"
  echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
  echo "======================================"
  
  [[ $TESTS_FAILED -eq 0 ]] && exit 0 || exit 1
}

main "$@"
#fin