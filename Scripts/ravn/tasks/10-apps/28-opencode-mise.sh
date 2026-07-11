#!/usr/bin/env bash
# ─── RaVN Task: OpenCode CLI (mise reference lifecycle) ─────────────────────

# shellcheck disable=SC2034
PACKAGE="opencode-mise"
# shellcheck disable=SC2034
TASK_ID="opencode-mise"
DESCRIPTION="OpenCode CLI managed by mise"
# shellcheck disable=SC2034
TASK_FAMILY="cli-tools"
# shellcheck disable=SC2034
INSTALLER_STRATEGY="mise"
# shellcheck disable=SC2034
TEST_LEVEL="isolated"
DEPENDS=("mise" "node")
INTERACTIVE=false

OPENCODE_PACKAGE="opencode-ai"
OPENCODE_VERSION_REQUEST="latest"
OPENCODE_NODE_REQUEST="latest"
OPENCODE_COMMAND="opencode-mise"
OPENCODE_ROOT="${XDG_DATA_HOME:-${HOME}/.local/share}/ravn/tasks/opencode-mise"
OPENCODE_CONFIG_DIR="${OPENCODE_ROOT}/mise"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/mise.toml"
OPENCODE_WRAPPER="${HOME}/.local/bin/${OPENCODE_COMMAND}"

opencode_mise_bin() {
  ravn_verify_mise > /dev/null || return 1
  ravn_mise_binary
}

opencode_record_versions() {
  local mise_bin="$1"
  local command_version=""
  local node_version=""

  command_version=$("$OPENCODE_WRAPPER" --version) || return 1
  node_version=$("$mise_bin" exec --cd "$OPENCODE_CONFIG_DIR" -- node --version) || return 1

  RAVN_EVIDENCE_REQUESTED_VERSION="$OPENCODE_VERSION_REQUEST"
  RAVN_EVIDENCE_RESOLVED_VERSION="${command_version%%$'\n'*}"
  RAVN_EVIDENCE_RUNTIME_VERSION="${node_version#v}"
}

check() {
  verify
}

install() {
  local mise_bin=""
  local install_root=""
  local package_version=""
  local postinstall=""

  mise_bin=$(opencode_mise_bin) || {
    echo "Error: mise no está instalado o no es funcional" >&2
    return 1
  }

  mkdir -p "$OPENCODE_CONFIG_DIR" "${HOME}/.local/bin"
  "$mise_bin" use --path "$OPENCODE_CONFIG_FILE" --pin --yes \
    "node@${OPENCODE_NODE_REQUEST}" "npm:${OPENCODE_PACKAGE}@${OPENCODE_VERSION_REQUEST}"

  install_root=$("$mise_bin" where "npm:${OPENCODE_PACKAGE}@${OPENCODE_VERSION_REQUEST}")
  package_version=$("$mise_bin" exec --cd "$OPENCODE_CONFIG_DIR" -- node -p \
    "require('${install_root}/lib/node_modules/${OPENCODE_PACKAGE}/package.json').version")
  [[ -n $package_version ]] || return 1
  postinstall="${install_root}/lib/node_modules/${OPENCODE_PACKAGE}/postinstall.mjs"
  if [[ -f $postinstall ]]; then
    "$mise_bin" exec --cd "$OPENCODE_CONFIG_DIR" -- node "$postinstall"
  fi

  cat > "$OPENCODE_WRAPPER" << EOF
#!/usr/bin/env bash
exec "$mise_bin" exec --cd "$OPENCODE_CONFIG_DIR" -- opencode "\$@"
EOF
  chmod +x "$OPENCODE_WRAPPER"
  opencode_record_versions "$mise_bin"
}

verify() {
  local mise_bin=""

  [[ -x $OPENCODE_WRAPPER && -f $OPENCODE_CONFIG_FILE ]] || return 1
  mise_bin=$(opencode_mise_bin) || return 1
  opencode_record_versions "$mise_bin"
}

reset() {
  rm -f "$OPENCODE_WRAPPER"
  rm -rf "$OPENCODE_ROOT"
}

verify_reset() {
  [[ ! -e $OPENCODE_WRAPPER && ! -e $OPENCODE_ROOT ]]
}
