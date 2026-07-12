#!/usr/bin/env bash
# ─── RaVN Framework — HTTPS upstream shell-installer backend ────────────────

upstream_task() {
  local task_name="${UPSTREAM_COMMAND//[^a-zA-Z0-9_-]/-}"
  local task_root="${XDG_DATA_HOME:-${HOME}/.local/share}/ravn/tasks/${task_name}"

  # shellcheck disable=SC2034
  PACKAGE="${UPSTREAM_COMMAND}"
  # shellcheck disable=SC2034
  TASK_ID="${UPSTREAM_COMMAND}"
  # shellcheck disable=SC2034
  DESCRIPTION="${UPSTREAM_DESCRIPTION:-${UPSTREAM_COMMAND} managed by upstream installer}"
  # shellcheck disable=SC2034
  TASK_FAMILY="cli-tools"
  # shellcheck disable=SC2034
  INSTALLER_STRATEGY="upstream"
  # shellcheck disable=SC2034
  TEST_LEVEL="isolated"
  # shellcheck disable=SC2034
  DEPENDS=(curl)
  # shellcheck disable=SC2034
  INTERACTIVE=false

  UPSTREAM_ROOT="$task_root"
  UPSTREAM_INSTALL_DIR="${UPSTREAM_INSTALL_DIR:-${task_root}/install}"
  UPSTREAM_INSTALL_HOME="${UPSTREAM_INSTALL_HOME:-${task_root}/installer-home}"
  UPSTREAM_WRAPPER="${HOME}/.local/bin/${UPSTREAM_COMMAND}"
  UPSTREAM_SHELL="${UPSTREAM_INSTALL_SHELL:-bash}"
  if ! declare -p UPSTREAM_INSTALL_ARGS &>/dev/null; then
    UPSTREAM_INSTALL_ARGS=()
  fi
  if ! declare -p UPSTREAM_VERSION_ARGS &>/dev/null; then
    UPSTREAM_VERSION_ARGS=(--version)
  fi
  # shellcheck disable=SC2034
  RAVN_UPDATE_AVAILABLE=false
}

upstream_binary() {
  printf '%s/%s' "$UPSTREAM_INSTALL_DIR" "$UPSTREAM_COMMAND"
}

upstream_download() {
  local destination="$1"
  local curl_bin="${RAVN_UPSTREAM_CURL_BIN:-curl}"

  "$curl_bin" --fail --location --retry 3 --silent --show-error \
    "$UPSTREAM_INSTALL_URL" -o "$destination"
}

upstream_write_wrapper() {
  local binary=""

  binary=$(upstream_binary)

  mkdir -p "${HOME}/.local/bin" || return 1
  cat >"$UPSTREAM_WRAPPER" <<EOF
#!/usr/bin/env bash
exec "$binary" "\$@"
EOF
  chmod +x "$UPSTREAM_WRAPPER"
}

upstream_record_version() {
  local binary=""
  local output=""

  binary=$(upstream_binary)
  output=$("$binary" "${UPSTREAM_VERSION_ARGS[@]}" 2>&1) || return 1
  [[ -n $output ]] || return 1
  # shellcheck disable=SC2034
  RAVN_EVIDENCE_RESOLVED_VERSION="${output%%$'\n'*}"
  # shellcheck disable=SC2034
  RAVN_EVIDENCE_REQUESTED_VERSION="${UPSTREAM_VERSION:-latest}"
}

upstream_verify_checksum() {
  local script="$1"
  local actual=""

  actual=$(sha256sum "$script") || return 1
  RAVN_EVIDENCE_UPSTREAM_SHA256="${actual%% *}"
  if [[ -n ${UPSTREAM_SHA256:-} && $RAVN_EVIDENCE_UPSTREAM_SHA256 != "$UPSTREAM_SHA256" ]]; then
    printf 'Error: upstream installer checksum mismatch.\n' >&2
    return 1
  fi
}

upstream_install_script() {
  local script_dir=""
  local script=""

  [[ ${UPSTREAM_INSTALL_URL:-} == https://* ]] || {
    printf 'Error: upstream installer URL must use HTTPS.\n' >&2
    return 1
  }

  script_dir=$(mktemp -d "${TMPDIR:-/tmp}/ravn-upstream.XXXXXX") || return 1
  script="${script_dir}/install.sh"
  if ! upstream_download "$script"; then
    rm -rf "$script_dir"
    return 1
  fi
  if ! upstream_verify_checksum "$script"; then
    rm -rf "$script_dir"
    return 1
  fi

  mkdir -p "$UPSTREAM_INSTALL_DIR" "$UPSTREAM_INSTALL_HOME" || {
    rm -rf "$script_dir"
    return 1
  }
  local install_env=()
  if [[ -n ${UPSTREAM_INSTALL_DIR_ENV:-} ]]; then
    install_env=("${UPSTREAM_INSTALL_DIR_ENV}=${UPSTREAM_INSTALL_DIR}")
  fi
  if ! env HOME="$UPSTREAM_INSTALL_HOME" PATH="${UPSTREAM_INSTALL_DIR}:${HOME}/.local/bin:${PATH}" \
    UPSTREAM_COMMAND="$UPSTREAM_COMMAND" \
    UPSTREAM_INSTALL_DIR="$UPSTREAM_INSTALL_DIR" \
    "${install_env[@]}" \
    "$UPSTREAM_SHELL" "$script" "${UPSTREAM_INSTALL_ARGS[@]}"; then
    rm -rf "$script_dir"
    return 1
  fi
  rm -rf "$script_dir"
  upstream_write_wrapper || return 1
  upstream_record_version
}

check() {
  verify
}

install() {
  upstream_install_script
}

verify() {
  local binary=""

  binary=$(upstream_binary)
  [[ -x $binary && -x $UPSTREAM_WRAPPER ]] || return 1
  upstream_record_version
  "$UPSTREAM_WRAPPER" "${UPSTREAM_VERSION_ARGS[@]}" >/dev/null 2>&1
}

reset() {
  rm -f "$UPSTREAM_WRAPPER"
  rm -rf "$UPSTREAM_ROOT"
}

verify_reset() {
  [[ ! -e $UPSTREAM_WRAPPER && ! -e $UPSTREAM_ROOT ]]
}
