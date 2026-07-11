#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TASKS=(
  "${RAVN_DIR}/tests/fixtures/verified.sh"
  "${RAVN_DIR}/tests/fixtures/legacy.sh"
  "${RAVN_DIR}/tests/fixtures/baseline.sh"
)

# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/package.sh"
# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/hooks.sh"
# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/contract.sh"
# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/runner.sh"

TASKS=("${TASKS[@]}")

info() { :; }
success() { :; }
warn_msg() { :; }
error_msg() { :; }
step() { :; }
print_task_results() { :; }

resolve_task_files verified
[[ ${#RESOLVED_TASKS[@]} -eq 1 && ${RESOLVED_TASKS[0]} == *verified.sh ]]

if run_selected_tasks verify verified; then
  :
else
  exit 1
fi
[[ ${TASK_RESULTS[0]} == "verified:verified" ]]

if run_selected_tasks run legacy; then
  exit 1
else
  :
fi
[[ ${TASK_RESULTS[0]} == "legacy:unverified" ]]

if run_selected_tasks run BASELINE; then
  :
else
  exit 1
fi
[[ ${TASK_RESULTS[0]} == "baseline:verified" ]]

printf 'PASS: direct task runner\n'
