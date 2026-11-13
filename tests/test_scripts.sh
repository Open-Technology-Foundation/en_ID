#!/usr/bin/env bash
# Checks of the project's scripts rather than the locale data: the test
# harness itself, exit codes, and how the installers behave when piped.
# Runs unprivileged: the installer checks rely on being refused root.
set -euo pipefail
shopt -s inherit_errexit
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

declare -- SCRIPT_PATH
SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_PATH
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/} TESTS_DIR=${SCRIPT_PATH%/*}
declare -r REPO_DIR=${TESTS_DIR%/*}

if [[ -t 1 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' NC=''
fi

declare -i CHECKS_RUN=0 CHECKS_PASSED=0
declare -- WORK_DIR=''

die() {
  local -i code=$1
  local -- msg
  shift
  for msg in "$@"; do >&2 printf '%s: %s\n' "$SCRIPT_NAME" "$msg"; done
  exit "$code"
}

# shellcheck disable=SC2317,SC2329 # invoked via trap
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  [[ -z $WORK_DIR ]] || rm -rf -- "$WORK_DIR"
  exit "$exitcode"
}

# expect_rc DESCRIPTION RC COMMAND [ARG...]
# Passes when COMMAND exits with status RC. On failure, shows the tail of
# the command's output so the reason is visible without a rerun.
expect_rc() {
  local -- description=$1 output
  local -i expected=$2 actual=0
  shift 2
  CHECKS_RUN+=1
  output=$("$@" 2>&1 </dev/null) || actual=$?
  if ((actual == expected)); then
    CHECKS_PASSED+=1
    printf '%sPASS%s %s\n' "$GREEN" "$NC" "$description"
  else
    printf '%sFAIL%s %s: exit %d, expected %d\n' "$RED" "$NC" "$description" "$actual" "$expected"
    [[ -z $output ]] || tail -n 5 <<<"$output" | sed 's/^/  /'
  fi
}

# The suite must test the build it is given, even where en_ID is installed.
check_test_harness() {
  local -- mutant=$WORK_DIR/mutant nobuild=$WORK_DIR/nobuild
  mkdir -p -- "$mutant" "$nobuild"
  cp -R -- Makefile localedata tests "$mutant"/
  sed -i 's/^currency_symbol .*/currency_symbol       "XX"/' "$mutant"/localedata/en_ID
  make -s -C "$mutant" compile >/dev/null
  expect_rc 'suite fails when the source is wrong' 1 "$mutant"/tests/test_en_ID.sh LC_MONETARY

  cp -R -- tests "$nobuild"/
  expect_rc 'suite reports a missing build' 3 "$nobuild"/tests/test_en_ID.sh
  expect_rc 'unknown category is an argument error' 22 tests/test_en_ID.sh LC_BOGUS
}

main() {
  ((EUID)) || die 1 'Run as an ordinary user: the installer checks rely on being refused root'
  cd -- "$REPO_DIR"
  WORK_DIR=$(mktemp -d) || die 5 'Failed to create a temporary directory'
  trap 'cleanup $?' SIGINT SIGTERM EXIT

  check_test_harness

  printf 'Checks passed: %d of %d\n' "$CHECKS_PASSED" "$CHECKS_RUN"
  ((CHECKS_PASSED == CHECKS_RUN)) || exit 1
}

main "$@"
#fin
