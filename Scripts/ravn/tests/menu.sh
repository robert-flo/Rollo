#!/usr/bin/env bash
set -euo pipefail

output=""
output=$(printf 'q\n' | bash "$(dirname "${BASH_SOURCE[0]}")/../setup.sh")

grep -q "Verify current configuration" <<<"$output"
grep -q "Run full setup" <<<"$output"
grep -q "Run integration test" <<<"$output"
grep -q "Reset selected tasks" <<<"$output"
grep -q "Exit" <<<"$output"

printf 'PASS: task menu\n'
