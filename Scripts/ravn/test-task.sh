#!/usr/bin/env bash
# =============================================================================
# test-task.sh — Isolated Docker Tester for RaVN Task Modules
# =============================================================================
#
# Purpose:
#   Allows safe, reproducible testing of any RaVN task module in a clean
#   Docker environment (Arch Linux) without affecting the host system.
#
#   This is the recommended way to validate tasks before committing them.
#
# Usage:
#   ./test-task.sh --all
#   ./test-task.sh hermes
#   ./test-task.sh 25-hermes
#   ./test-task.sh 10-apps
#   ./test-task.sh hermes codex grok
#   ./test-task.sh hermes --dry-run
#   ./test-task.sh hermes --keep
#
# Supported selectors:
#   --all                 → All discovered tasks
#   <name>                → Matches filename or PACKAGE= value
#   <category>            → e.g. 00-core, 10-apps, 30-system
#   <NN-name.sh>          → Specific task file
#
# Options:
#   --dry-run             Run in simulation mode inside the container
#   --keep                Do not remove the container after execution (debugging)
#   -h, --help            Show this help
#
# How it works:
#   1. Starts a fresh Arch Linux container
#   2. Sources global_fn.sh (required by most tasks)
#   3. Sources the task module
#   4. Executes its install() function
#   5. Verifies that check() returns success afterwards
#   6. Reports PASS / FAIL for each task
#
# This script was created after successfully validating the Hermes task
# (25-hermes.sh) in complete isolation.
#
# Location: Scripts/ravn/test-task.sh
# =============================================================================

set -e

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TASKS_DIR="${RAVN_DIR}/tasks"
GLOBAL_FN="${RAVN_DIR}/global_fn.sh"

DOCKER_IMAGE="archlinux:latest"

print_usage() {
  cat << EOF
test-task.sh — Pruebas aisladas de tareas RaVN (Docker)

Uso:
  $(basename "$0") --all                    # Todas las tareas
  $(basename "$0") <nombre|patrón>          # Una o varias por nombre
  $(basename "$0") 10-apps                  # Todas las de una categoría
  $(basename "$0") hermes codex             # Varias tareas específicas

Opciones:
  --dry-run     Ejecuta install() en modo simulación
  --keep        Mantiene el contenedor después de la prueba (debug)
  -h, --help    Muestra esta ayuda

Ejemplos:
  ./test-task.sh hermes
  ./test-task.sh 25-hermes --dry-run
  ./test-task.sh --all
EOF
}

get_task_test_level() {
  local task_file="$1"
  local test_level=""

  test_level=$(
    # shellcheck disable=SC1091,SC1090
    source "${RAVN_DIR}/framework/package.sh"
    # shellcheck disable=SC1090
    source "$task_file"
    printf '%s' "${TEST_LEVEL:-}"
  )
  printf '%s' "$test_level"
}

run_static_test() {
  local task_file="$1"

  bash -n "$task_file" && shellcheck "$task_file"
}

# Parse arguments
TASKS_TO_TEST=()
DRY_RUN=0
KEEP_CONTAINER=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      mapfile -t TASKS_TO_TEST < <(find "$TASKS_DIR" -name "*.sh" | sort)
      shift
      ;;
    ALL | all)
      mapfile -t TASKS_TO_TEST < <(find "$TASKS_DIR" -name "*.sh" | sort)
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --keep)
      KEEP_CONTAINER=1
      shift
      ;;
    -h | --help)
      print_usage
      exit 0
      ;;
    *)
      if [[ -d "$TASKS_DIR/$1" ]]; then
        mapfile -t found < <(find "$TASKS_DIR/$1" -name "*.sh" | sort)
        TASKS_TO_TEST+=("${found[@]}")
      else
        mapfile -t found < <(find "$TASKS_DIR" -name "*${1}*.sh" | sort)
        if [[ ${#found[@]} -eq 0 ]]; then
          mapfile -t found < <(grep -rl "PACKAGE=.*${1}" "$TASKS_DIR" 2> /dev/null | sort)
        fi
        TASKS_TO_TEST+=("${found[@]}")
      fi
      shift
      ;;
  esac
done

if [[ ${#TASKS_TO_TEST[@]} -eq 0 ]]; then
  echo "Error: No se especificaron tareas para probar."
  print_usage
  exit 1
fi

# Deduplicate
mapfile -t TASKS_TO_TEST < <(printf "%s\n" "${TASKS_TO_TEST[@]}" | sort -u)

echo "==> RaVN Task Tester (entorno aislado Docker)"
echo "    Tareas a probar: ${#TASKS_TO_TEST[@]}"
echo ""

FAILED=()
PASSED=()
UNSUPPORTED=()

for task_file in "${TASKS_TO_TEST[@]}"; do
  [[ ! -f "$task_file" ]] && continue

  task_name=$(basename "$task_file" .sh)
  rel_path=${task_file#"$TASKS_DIR"/}

  echo "────────────────────────────────────────────────────────"
  echo "Probando: $rel_path"

  package=$(grep -oP 'PACKAGE="\K[^"]+' "$task_file" 2> /dev/null || echo "$task_name")
  test_level=$(get_task_test_level "$task_file")

  case "$test_level" in
    static)
      if run_static_test "$task_file"; then
        echo "✓ $package → PASÓ (static)"
        PASSED+=("$package")
      else
        echo "✗ $package → FALLÓ (static)"
        FAILED+=("$package")
      fi
      continue
      ;;
    live)
      echo "⚠ $package → NO VERIFICABLE (requiere live)"
      UNSUPPORTED+=("$package")
      continue
      ;;
    "" | isolated)
      ;;
    *)
      echo "⚠ $package → NO VERIFICABLE (TEST_LEVEL inválido: $test_level)"
      UNSUPPORTED+=("$package")
      continue
      ;;
  esac

  test_script=$(mktemp)
  cat > "$test_script" << EOF
#!/usr/bin/env bash
set -e
export PATH="\$HOME/.local/bin:\$PATH"
echo "=== Actualizando sistema base ==="
pacman -Syu --noconfirm curl git 2>&1 | tail -3

echo "=== Ejecutando tarea: $package ==="

# Source global_fn.sh first (provides step, warn_msg, info, success, etc.)
if [[ -f "/global_fn.sh" ]]; then
source "/global_fn.sh" 2>/dev/null || true
fi

source "/package.sh" 2>/dev/null || true
source "/hooks.sh" 2>/dev/null || true
source "/contract.sh" 2>/dev/null || true
source "/task.sh" 2>/dev/null || true

if declare -f install >/dev/null; then
  if (( $DRY_RUN == 1 )); then
    echo "Modo dry-run activado"
    if declare -f check >/dev/null; then
      if check; then
        echo "check() → ya instalado (skip)"
      else
        echo "check() → necesita instalación"
      fi
    fi
    echo "install() simulado correctamente"
  else
    install
  fi
else
  echo "⚠ La tarea no define función install()"
fi

echo "=== Verificando resultado ==="
if declare -f verify >/dev/null && task_capability verify; then
  if verify; then
    echo "✓ verify() pasó correctamente"
    exit 0
  else
    echo "✗ verify() falló después de la instalación"
    exit 1
  fi
elif declare -f check >/dev/null; then
  echo "⚠ verify() no está implementado; resultado no verificable"
  exit 42
else
  echo "⚠ Tarea sin verify() — resultado no verificable"
  exit 42
fi
EOF

  chmod +x "$test_script"

  container_name="ravn-test-$(date +%s)-$$"
  docker_args=("--name" "$container_name" "--rm")

  if ((KEEP_CONTAINER == 1)); then
    docker_args=("--name" "$container_name")
  fi

  if docker run "${docker_args[@]}" \
       -v "$task_file:/task.sh:ro" \
       -v "$GLOBAL_FN:/global_fn.sh:ro" \
       -v "$RAVN_DIR/framework/package.sh:/package.sh:ro" \
       -v "$RAVN_DIR/framework/hooks.sh:/hooks.sh:ro" \
       -v "$RAVN_DIR/framework/contract.sh:/contract.sh:ro" \
       -v "$test_script:/test.sh:ro" \
       "$DOCKER_IMAGE" bash /test.sh; then
    echo "✓ $package → PASÓ"
    PASSED+=("$package")
  else
    rc=$?
    if ((rc == 42)); then
      echo "⚠ $package → NO VERIFICABLE"
      UNSUPPORTED+=("$package")
    else
      echo "✗ $package → FALLÓ"
      FAILED+=("$package")
    fi
  fi

  rm -f "$test_script"
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "Resumen de pruebas"
echo "  ✓ Pasaron:  ${#PASSED[@]}"
echo "  ✗ Fallaron: ${#FAILED[@]}"
echo "  ⚠ No verificables: ${#UNSUPPORTED[@]}"
if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "  Fallidos: ${FAILED[*]}"
  exit 1
fi
echo "════════════════════════════════════════════════════════"
