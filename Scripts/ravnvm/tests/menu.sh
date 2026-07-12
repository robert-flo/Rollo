#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RAVNVM_SCRIPT="$SCRIPT_DIR/ravnvm.sh"
FIXTURE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ravnvm-test.XXXXXX")"
FAKE_BIN="$FIXTURE_DIR/bin"

cleanup() {
  rm -rf "$FIXTURE_DIR"
}

trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  grep -Fq "$needle" <<< "$haystack" || fail "expected output to contain: $needle"
}

mkdir -p "$FAKE_BIN"
touch "$FAKE_BIN/qemu-system-x86_64" "$FAKE_BIN/qemu-img"
chmod +x "$FAKE_BIN/qemu-system-x86_64" "$FAKE_BIN/qemu-img"
export PATH="$FAKE_BIN:$PATH"
export XDG_CACHE_HOME="$FIXTURE_DIR/cache"

menu_output=$(printf 'q\n' | "$RAVNVM_SCRIPT")
assert_contains "$menu_output" "Choose an action"
assert_contains "$menu_output" "Goodbye!"

invalid_output=$(printf 'x\n\nq\n' | "$RAVNVM_SCRIPT")
assert_contains "$invalid_output" "Invalid option: x"

revision_output=$(printf '1\nq\n\nq\n' | "$RAVNVM_SCRIPT")
assert_contains "$revision_output" "Choose a RaVN revision"
assert_contains "$revision_output" "Other branch or commit"

help_output=$("$RAVNVM_SCRIPT" --help)
assert_contains "$help_output" "Usage: ravnvm"

snapshot_output=$("$RAVNVM_SCRIPT" --list)
assert_contains "$snapshot_output" "Available RaVN snapshots"

storage_output=$(printf 'q\n' | "$RAVNVM_SCRIPT")
assert_contains "$storage_output" "VM cache:"
assert_contains "$storage_output" "Disk:"
assert_contains "$storage_output" "Free:"

make_output=$(make -s DRY_RUN=1 dev-vm REF=dev)
assert_contains "$make_output" "ravnvm.sh dev"

printf 'PASS: RavnVM interaction surfaces\n'
