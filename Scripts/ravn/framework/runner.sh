#!/usr/bin/env bash
# ─── RaVN Framework v1 — Direct Task Runner ─────────────────────────────────
# Resolves and executes explicitly selected tasks without changing the menu or
# the installer pipeline.

TASK_RESULTS=()
TASK_FAILURES=()

_runner_reset_task_contract() {
  # shellcheck disable=SC1091
  source "${RAVN_DIR}/framework/package.sh"
}

load_task() {
  local file="$1"

  _runner_reset_task_contract
  # shellcheck disable=SC1090
  source "$file"
}

task_name() {
  local file="$1"
  load_task "$file"
  printf '%s' "${PACKAGE:-$(basename "$file" .sh)}"
}

task_is_disabled() {
  local name="$1"

  [[ -f ${RAVN_DIR}/config/packages.conf ]] &&
    grep -Fxq "${name}=false" "${RAVN_DIR}/config/packages.conf"
}

_runner_match_task() {
  local file="$1"
  local selector="$2"
  local name=""
  name=$(task_name "$file")

  [[ $selector == "ALL" || $selector == "$name" || $selector == "$(basename "$file" .sh)" || $selector == "$file" ]]
}

resolve_task_files() {
  local selector file
  local -a selected=()

  if (($# == 0)); then
    error_msg "Debe especificar una tarea o ALL."
    return 1
  fi

  for selector in "$@"; do
    local found=0

    for file in "${TASKS[@]}"; do
      if _runner_match_task "$file" "$selector"; then
        selected+=("$file")
        found=1
      fi
    done

    if ((found == 0)); then
      error_msg "Tarea no encontrada: ${selector}"
      return 1
    fi
  done

  mapfile -t RESOLVED_TASKS < <(printf '%s\n' "${selected[@]}" | sort -u)
}

_runner_log_dir() {
  mkdir -p "${RAVN_DIR}/cache/logs"
}

_runner_record() {
  local name="$1"
  local result="$2"

  TASK_RESULTS+=("${name}:${result}")
  if [[ $result == "failed" || $result == "unverified" ]]; then
    TASK_FAILURES+=("$name")
  fi
}

verify_selected_task() {
  local file="$1"
  local name=""
  local log=""

  load_task "$file"
  name="${PACKAGE:-$(basename "$file" .sh)}"
  log="${RAVN_DIR}/cache/logs/${name}.log"
  _runner_log_dir

  if task_is_disabled "$name"; then
    info "${name}: Deshabilitado."
    _runner_record "$name" "disabled"
    return 0
  fi

  if ! task_capability verify; then
    warn_msg "${name}: Sin verify(); no se puede confirmar el postestado."
    _runner_record "$name" "unverified"
    return 1
  fi

  if verify >> "$log" 2>&1; then
    success "${name}: Verificado."
    _runner_record "$name" "verified"
    return 0
  fi

  error_msg "${name}: Verificación falló. Log: ${log}"
  _runner_record "$name" "failed"
  return 1
}

run_selected_task() {
  local file="$1"
  local name=""
  local log=""

  load_task "$file"
  name="${PACKAGE:-$(basename "$file" .sh)}"
  log="${RAVN_DIR}/cache/logs/${name}.log"
  _runner_log_dir

  if task_is_disabled "$name"; then
    info "${name}: Deshabilitado."
    _runner_record "$name" "disabled"
    return 0
  fi

  if check; then
    info "${name}: Ya satisfecho; omitido."
    _runner_record "$name" "skipped"
    return 0
  fi

  if ! install >> "$log" 2>&1; then
    error_msg "${name}: Instalación falló. Log: ${log}"
    _runner_record "$name" "failed"
    return 1
  fi

  if ! task_capability verify; then
    warn_msg "${name}: Instalado, pero sin verify(); resultado no confirmado."
    _runner_record "$name" "unverified"
    return 1
  fi

  if verify >> "$log" 2>&1; then
    success "${name}: Instalado y verificado."
    _runner_record "$name" "verified"
    return 0
  fi

  error_msg "${name}: Instalado, pero la verificación falló. Log: ${log}"
  _runner_record "$name" "failed"
  return 1
}

run_selected_tasks() {
  local action="$1"
  shift
  local file
  local status=0

  TASK_RESULTS=()
  TASK_FAILURES=()
  resolve_task_files "$@" || return 1

  for file in "${RESOLVED_TASKS[@]}"; do
    if [[ $action == "verify" ]]; then
      verify_selected_task "$file" || status=1
    else
      run_selected_task "$file" || status=1
    fi
  done

  print_task_results
  return "$status"
}

print_task_results() {
  local result

  echo ""
  step "Resultados de tareas"
  for result in "${TASK_RESULTS[@]}"; do
    printf '  %s\n' "$result"
  done
}
