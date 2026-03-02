#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="${SCRIPT_DIR}/eodhd"
TESTS_RUN=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "${expected}" != "${actual}" ]]; then
    fail "${label}: expected '${expected}' got '${actual}'"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "${haystack}" != *"${needle}"* ]]; then
    fail "${label}: missing '${needle}'"
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "${haystack}" == *"${needle}"* ]]; then
    fail "${label}: found forbidden '${needle}'"
  fi
}

run_capture() {
  local stdout_file stderr_file status
  stdout_file="$(mktemp)"
  stderr_file="$(mktemp)"

  set +o errexit
  "$@" >"${stdout_file}" 2>"${stderr_file}"
  status=$?
  set -o errexit

  printf '%s\n' "${status}"
  printf '%s\n' "${stdout_file}"
  printf '%s\n' "${stderr_file}"
}

cleanup_capture() {
  rm -f "$1" "$2"
}

main() {
  mapfile -t result < <(run_capture "${CLI}" --help)
  assert_eq "0" "${result[0]}" "help exits zero"
  assert_contains "$(cat "${result[1]}")" "Usage:" "help prints usage"
  cleanup_capture "${result[1]}" "${result[2]}"

  mapfile -t result < <(run_capture "${CLI}")
  assert_eq "2" "${result[0]}" "no args exits usage"
  cleanup_capture "${result[1]}" "${result[2]}"

  mapfile -t result < <(run_capture "${CLI}" eod AAPL.US)
  assert_eq "3" "${result[0]}" "missing auth exits correctly"
  assert_contains "$(cat "${result[2]}")" "EODHD_API_KEY is required" "missing auth message"
  cleanup_capture "${result[1]}" "${result[2]}"

  mapfile -t result < <(run_capture env EODHD_API_KEY=super-secret-token "${CLI}" --dry-run eod AAPL.US --from 2024-01-01 --query filter=last_close)
  assert_eq "0" "${result[0]}" "dry run exits zero"
  assert_contains "$(cat "${result[1]}")" "***REDACTED***" "dry run masks token"
  assert_not_contains "$(cat "${result[1]}")" "super-secret-token" "dry run hides raw token"
  assert_contains "$(cat "${result[1]}")" "AAPL.US" "dry run includes symbol"
  cleanup_capture "${result[1]}" "${result[2]}"

  mapfile -t result < <(run_capture env EODHD_API_KEY=super-secret-token "${CLI}" --dry-run search "apple inc" --query limit=5)
  assert_eq "0" "${result[0]}" "search dry run exits zero"
  assert_contains "$(cat "${result[1]}")" "q=apple%20inc" "search encodes query"
  assert_contains "$(cat "${result[1]}")" "limit=5" "search carries repeated query"
  cleanup_capture "${result[1]}" "${result[2]}"

  printf 'PASS: %s smoke tests\n' "${TESTS_RUN}"
}

main "$@"
