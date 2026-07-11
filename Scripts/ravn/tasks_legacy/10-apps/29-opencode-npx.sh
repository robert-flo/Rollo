#!/usr/bin/env bash
# ─── RaVN Task: OpenCode CLI (omarchy-npx-install pilot) ────────────────────
# Experimental comparison backend. The legacy `opencode` task and the mise
# pilot remain untouched and this pilot owns a separate command.

# shellcheck disable=SC2034
PACKAGE="opencode-npx"
# shellcheck disable=SC2034
TASK_ID="opencode-npx"
DESCRIPTION="OpenCode CLI pilot via hardened omarchy-npx-install"
# shellcheck disable=SC2034
TASK_FAMILY="cli-tools"
# shellcheck disable=SC2034
INSTALLER_STRATEGY="omarchy-npx"
# shellcheck disable=SC2034
TEST_LEVEL="isolated"
DEPENDS=("mise" "node")
INTERACTIVE=false

OPENCODE_PACKAGE="opencode-ai"
OPENCODE_VERSION="1.17.18"
OPENCODE_NODE_VERSION="22"
OPENCODE_COMMAND="opencode-npx"
OPENCODE_BIN="opencode"
OPENCODE_WRAPPER="${HOME}/.local/bin/${OPENCODE_COMMAND}"

check() {
  [[ -x $OPENCODE_WRAPPER ]]
}

install() {
  local installer="${OMARCHY_NPX_INSTALLER:-${RAVN_DIR}/omarchy-npx-install}"

  if ! command -v mise > /dev/null 2>&1; then
    echo "Error: mise no está instalado" >&2
    return 1
  fi
  if [[ ! -x $installer ]]; then
    echo "Error: omarchy-npx-install no está disponible" >&2
    return 1
  fi

  "$installer" "$OPENCODE_PACKAGE" "$OPENCODE_COMMAND" \
    "$OPENCODE_VERSION" "$OPENCODE_NODE_VERSION" "$OPENCODE_BIN"
}

verify() {
  local output=""

  [[ -x $OPENCODE_WRAPPER ]]
  if ! output=$("$OPENCODE_WRAPPER" --version 2>&1); then
    printf '%s\n' "$output" >&2
    return 1
  fi
  [[ -n $output ]]
}

reset() {
  rm -f "$OPENCODE_WRAPPER"
}

verify_reset() {
  [[ ! -e $OPENCODE_WRAPPER ]]
}
