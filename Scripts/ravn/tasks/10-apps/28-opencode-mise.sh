#!/usr/bin/env bash
# ─── RaVN Task: OpenCode CLI (mise pilot) ────────────────────────────────────
# Experimental pilot for the mise installer strategy. The legacy `opencode`
# task remains untouched and this pilot owns a separate command/configuration.

# shellcheck disable=SC2034
PACKAGE="opencode-mise"
# shellcheck disable=SC2034
TASK_ID="opencode-mise"
DESCRIPTION="OpenCode CLI pilot managed by mise"
# shellcheck disable=SC2034
TASK_FAMILY="cli-tools"
# shellcheck disable=SC2034
INSTALLER_STRATEGY="mise"
# shellcheck disable=SC2034
TEST_LEVEL="isolated"
DEPENDS=("mise" "node")
INTERACTIVE=false

OPENCODE_PACKAGE="opencode-ai"
OPENCODE_VERSION="1.17.18"
OPENCODE_COMMAND="opencode-mise"
OPENCODE_ROOT="${XDG_DATA_HOME:-${HOME}/.local/share}/ravn/tasks/opencode-mise"
OPENCODE_CONFIG_DIR="${OPENCODE_ROOT}/mise"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/mise.toml"
OPENCODE_WRAPPER="${HOME}/.local/bin/${OPENCODE_COMMAND}"

check() {
  [[ -x $OPENCODE_WRAPPER && -f ${OPENCODE_CONFIG_DIR}/mise.toml ]]
}

install() {
  local install_root=""

  if ! command -v mise > /dev/null 2>&1; then
    echo "Error: mise no está instalado" >&2
    return 1
  fi

  mkdir -p "$OPENCODE_CONFIG_DIR" "${HOME}/.local/bin"
  touch "$OPENCODE_CONFIG_FILE"
  mise use --path "$OPENCODE_CONFIG_FILE" --pin --yes \
    node@22 "npm:${OPENCODE_PACKAGE}@${OPENCODE_VERSION}"

  install_root=$(mise where "npm:${OPENCODE_PACKAGE}@${OPENCODE_VERSION}")
  mise exec --cd "$OPENCODE_CONFIG_DIR" -- node \
    "${install_root}/lib/node_modules/${OPENCODE_PACKAGE}/postinstall.mjs"

  cat > "$OPENCODE_WRAPPER" << EOF
#!/usr/bin/env bash
exec mise exec --cd "$OPENCODE_CONFIG_DIR" -- opencode "\$@"
EOF
  chmod +x "$OPENCODE_WRAPPER"
}

verify() {
  local output=""

  [[ -x $OPENCODE_WRAPPER && -f ${OPENCODE_CONFIG_DIR}/mise.toml ]]
  output=$("$OPENCODE_WRAPPER" --version 2>&1) || return 1
  [[ -n $output ]]
}

reset() {
  rm -f "$OPENCODE_WRAPPER"
  rm -rf "$OPENCODE_ROOT"
  mise uninstall --yes "npm:${OPENCODE_PACKAGE}@${OPENCODE_VERSION}" || true
}

verify_reset() {
  [[ ! -e $OPENCODE_WRAPPER && ! -e $OPENCODE_ROOT ]]
}
