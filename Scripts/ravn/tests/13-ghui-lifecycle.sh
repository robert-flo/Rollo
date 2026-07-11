#!/usr/bin/env bash
# Ghui-only lifecycle contract: a failed update must not replace the verified install.
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export RAVN_DIR

# shellcheck disable=SC1091
source "${RAVN_DIR}/global_fn.sh"
for fw in "${RAVN_DIR}"/framework/*.sh; do
  # shellcheck disable=SC1090
  source "$fw"
done

if ! command -v mise &>/dev/null || ! ravn_verify_mise &>/dev/null; then
  printf 'SKIP: ghui lifecycle — mise unavailable on host\n'
  exit 0
fi

discover_tasks

if ! run_selected_tasks run ghui; then
  printf 'FAIL: ghui install required for lifecycle test\n' >&2
  exit 1
fi

version_before=""
version_before=$(~/.local/bin/ghui --version)

export RAVN_TEST_UPDATE_VERIFY_FAIL=1
TASK_RESULTS=()
if run_selected_tasks update ghui; then
  printf 'FAIL: ghui update should fail when candidate promotion is blocked\n' >&2
  exit 1
fi
unset RAVN_TEST_UPDATE_VERIFY_FAIL

[[ ${TASK_RESULTS[0]} == "ghui:update-failed" ]] || {
  printf 'FAIL: expected ghui:update-failed, got %s\n' "${TASK_RESULTS[0]:-}" >&2
  exit 1
}

version_after=""
version_after=$(~/.local/bin/ghui --version)
if [[ $version_before != "$version_after" ]]; then
  printf 'FAIL: ghui version changed after failed update (%s -> %s)\n' \
    "$version_before" "$version_after" >&2
  exit 1
fi

if ! run_selected_tasks verify ghui; then
  printf 'FAIL: ghui verify after failed update\n' >&2
  exit 1
fi

printf 'PASS: ghui update rollback preserves verified version\n'
