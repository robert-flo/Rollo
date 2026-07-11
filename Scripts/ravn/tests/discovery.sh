#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export RAVN_DIR

# shellcheck disable=SC1091
source "${RAVN_DIR}/global_fn.sh"
# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/package.sh"
# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/discover.sh"

discover_tasks
[[ ${#TASKS[@]} -gt 0 ]]
[[ $(printf '%s\n' "${TASKS[@]}" | grep -c '/00-core/') -eq 3 ]]
[[ $(printf '%s\n' "${TASKS[@]}" | grep -c '/30-system/') -eq 9 ]]
[[ $(printf '%s\n' "${TASKS[@]}" | grep -c '/10-apps/') -eq 0 ]]
if printf '%s\n' "${TASKS[@]}" | grep -q 'tasks_legacy'; then
  printf 'FAIL: legacy tasks were discovered\n' >&2
  exit 1
fi

printf 'PASS: active task discovery excludes legacy and references\n'
