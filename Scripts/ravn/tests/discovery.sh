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
[[ ${#TASKS[@]} -eq 0 ]]
[[ $(printf '%s\n' "${TASKS[@]}" | grep -c '/00-core/' || true) -eq 0 ]]
[[ $(printf '%s\n' "${TASKS[@]}" | grep -c '/30-system/' || true) -eq 0 ]]
[[ $(printf '%s\n' "${TASKS[@]}" | grep -c '/10-npm-apps/' || true) -eq 0 ]]
if printf '%s\n' "${TASKS[@]}" | grep -q 'tasks_legacy'; then
  printf 'FAIL: legacy tasks were discovered\n' >&2
  exit 1
fi

printf 'PASS: active task discovery is empty while core, system, and references remain quarantined\n'
