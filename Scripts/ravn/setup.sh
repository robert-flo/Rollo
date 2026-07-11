#!/usr/bin/env bash
#|---/ /+-------------------------------+---/ /|#
#|--/ /-| RaVN Framework v1 — Bootstrap |--/ /-|#
#|-/ /--| Roberto Flores                |-/ /--|#
#|/ /---+-------------------------------+/ /---|#

set -e

# ─── Resolve paths ───────────────────────────────────────────────────────────
RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export RAVN_DIR

scrDir="$(dirname "$RAVN_DIR")"
export scrDir

# ─── Source runtime library ──────────────────────────────────────────────────
# shellcheck disable=SC1091
source "${RAVN_DIR}/global_fn.sh"

# ─── Inherit flags from parent installer or load from configuration ──────────
if [[ -z ${flg_DryRun:-} ]]; then
  if [[ -f "${RAVN_DIR}/config/ravn.conf" ]] && grep -q "^dry_run=true" "${RAVN_DIR}/config/ravn.conf"; then
    flg_DryRun=1
  else
    flg_DryRun=0
  fi
fi
export flg_DryRun

# ─── Source framework modules ────────────────────────────────────────────────
for fw in "${RAVN_DIR}"/framework/*.sh; do
  # shellcheck disable=SC1090
  source "$fw"
done

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  local action="${1:-}"

  if [[ -z $action ]]; then
    run_menu
    return
  fi

  if [[ $action == "verify" || $action == "run" || $action == "test" || $action == "reset" || $action == "baseline" || $action == "--baseline" ]]; then
    if [[ $action == "baseline" || $action == "--baseline" ]]; then
      action="run"
      set -- BASELINE
    elif [[ $action == "test" ]]; then
      shift
      discover_tasks
      test_selected_tasks "$@"
      return
    elif [[ $action == "reset" ]]; then
      shift
      discover_tasks
      reset_selected_tasks "$@"
      return
    else
      shift
    fi
    discover_tasks
    run_selected_tasks "$action" "$@"
    return
  fi

  step "Configuración Final"
  print_log -g "[FINAL CONFIG] " -b " :: " "Iniciando configuración final..."

  discover_tasks
  run_pipeline
}

main "$@"
