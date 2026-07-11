#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export RAVN_DIR HOME XDG_DATA_HOME
HOME=$(mktemp -d)
XDG_DATA_HOME=$(mktemp -d)
trap 'rm -rf "$HOME" "$XDG_DATA_HOME"' EXIT

# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/package.sh"
# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/upstream.sh"
# shellcheck disable=SC1091
source "${RAVN_DIR}/framework/state.sh"

fixture_dir=$(mktemp -d)
fixture_script="${fixture_dir}/installer.sh"
cat >"$fixture_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$UPSTREAM_INSTALL_DIR"
cat >"${UPSTREAM_INSTALL_DIR}/${UPSTREAM_COMMAND}" <<'COMMAND'
#!/usr/bin/env bash
printf '%s\n' 'upstream-fixture 1.0.0'
COMMAND
chmod +x "${UPSTREAM_INSTALL_DIR}/${UPSTREAM_COMMAND}"
EOF
chmod +x "$fixture_script"

fake_curl="${fixture_dir}/curl"
cat >"$fake_curl" <<EOF
#!/usr/bin/env bash
cp "$fixture_script" "\${@: -1}"
EOF
chmod +x "$fake_curl"

# shellcheck disable=SC2034
UPSTREAM_COMMAND="fixture-cli"
# shellcheck disable=SC2034
UPSTREAM_INSTALL_URL="https://vendor.example/install.sh"
# shellcheck disable=SC2034
UPSTREAM_VERSION_ARGS=(--version)
# shellcheck disable=SC2034
RAVN_UPSTREAM_CURL_BIN="$fake_curl"
upstream_task

install
verify
[[ $RAVN_EVIDENCE_RESOLVED_VERSION == "upstream-fixture 1.0.0" ]]
[[ -n $RAVN_EVIDENCE_UPSTREAM_SHA256 ]]
[[ -x $UPSTREAM_WRAPPER ]]
ravn_record_task_evidence "$TASK_ID" install verified 0 "fixture" ""
grep -q '"upstream_sha256": "'"$RAVN_EVIDENCE_UPSTREAM_SHA256"'"' \
  "$(ravn_task_state_dir "$TASK_ID")/last-result.json"

if [[ $RAVN_EVIDENCE_UPSTREAM_SHA256 == "invalid" ]]; then
  exit 1
fi

reset
verify_reset

# shellcheck disable=SC2034
UPSTREAM_SHA256="invalid"
if install; then
  printf 'FAIL: checksum mismatch was accepted\n' >&2
  exit 1
fi
unset UPSTREAM_SHA256
verify_reset

printf 'PASS: upstream installer contract\n'
