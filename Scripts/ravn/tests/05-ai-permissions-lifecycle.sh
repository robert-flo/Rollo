#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
root=$(mktemp -d "${TMPDIR:-/tmp}/ravn-ai-permissions-test.XXXXXX")
trap 'rm -rf "$root"' EXIT

fake_bin="$root/bin"
state_files="$root/files"
state_groups="$root/groups"
state_usermod_count="$root/usermod_count"
mkdir -p "$fake_bin" "$state_files"

cat > "$fake_bin/sudo" << 'EOF'
#!/usr/bin/env bash
exec "$@"
EOF

cat > "$fake_bin/usermod" << 'EOF'
#!/usr/bin/env bash
# Track invocation count and simulate adding user to group
count_file="${RAVN_AI_USERMOD_COUNT:?}"
count=$(cat "$count_file")
printf '%d\n' $((count + 1)) > "$count_file"
for arg in "$@"; do
  [[ $arg == -aG ]] && continue
  [[ $arg == -* ]] && continue
  [[ $arg == "$USER" ]] && continue
  printf '%s\n' "$arg" >> "${RAVN_AI_GROUPS_STATE:?}"
done
EOF

cat > "$fake_bin/id" << 'EOF'
#!/usr/bin/env bash
# Report group memberships from state file (space-separated)
cat "${RAVN_AI_GROUPS_STATE:?}"
EOF

cat > "$fake_bin/tee" << 'EOF'
#!/usr/bin/env bash
# Write stdin to the test files directory, preserving the basename
target="${RAVN_AI_FILES_DIR:?}/$(basename "${!#}")"
mkdir -p "$(dirname "$target")"
cat >> "$target"
EOF

cat > "$fake_bin/chmod" << 'EOF'
#!/usr/bin/env bash
:
EOF

cat > "$fake_bin/rm" << 'EOF'
#!/usr/bin/env bash
while [[ ${1:-} == -* ]]; do shift; done
target="${RAVN_AI_FILES_DIR:?}/$(basename "${1:-}")"
[ -f "$target" ] && /usr/bin/rm -f "$target" || true
EOF

chmod +x "$fake_bin"/*

export PATH="$fake_bin:$PATH"
export RAVN_AI_FILES_DIR="$state_files"
export RAVN_AI_GROUPS_STATE="$state_groups"
export RAVN_AI_USERMOD_COUNT="$state_usermod_count"
printf 'wheel users\n' > "$state_groups"
printf '0\n' > "$state_usermod_count"

# shellcheck disable=SC1091
source "$RAVN_DIR/tasks/90-system/05-ai-permissions.sh"

_file_exists() {
  [[ -f $state_files/$(basename "$1") ]]
}

_user_in_group() {
  grep -qw "$1" "$state_groups" || false
}

# ─── Happy path ──────────────────────────────────────────────────────────────
admin_plan
admin_apply
admin_verify

# ─── Idempotent re-apply ─────────────────────────────────────────────────────
admin_apply
admin_verify

# ─── Rollback removes files, groups preserved ─────────────────────────────────
admin_rollback
! _file_exists "$POLKIT_RULES" || {
  printf 'FAIL: polkit rules not removed after rollback\n' >&2
  exit 1
}
! _file_exists "$SUDOERS_AI" || {
  printf 'FAIL: sudoers ai not removed after rollback\n' >&2
  exit 1
}
! _file_exists "$SUDOERS_HERMES" || {
  printf 'FAIL: sudoers hermes not removed after rollback\n' >&2
  exit 1
}
! _file_exists "$SYSTEMLIMITS_CONF" || {
  printf 'FAIL: systemd limits not removed after rollback\n' >&2
  exit 1
}
! _file_exists "$USER_OVERRIDE" || {
  printf 'FAIL: user override not removed after rollback\n' >&2
  exit 1
}
_user_in_group "systemd-journal" || {
  printf 'FAIL: systemd-journal group lost after rollback\n' >&2
  exit 1
}
_user_in_group "input" || {
  printf 'FAIL: input group lost after rollback\n' >&2
  exit 1
}

# ─── Reset removes files, groups preserved, usermod NOT called ───────────────
printf '0\n' > "$state_usermod_count"
admin_reset
admin_verify_reset
_user_in_group "systemd-journal" || {
  printf 'FAIL: systemd-journal group lost after reset\n' >&2
  exit 1
}
_user_in_group "input" || {
  printf 'FAIL: input group lost after reset\n' >&2
  exit 1
}
usermod_count=$(cat "$state_usermod_count")
if ((usermod_count > 0)); then
  printf 'FAIL: usermod called %d time(s) during reset\n' "$usermod_count" >&2
  exit 1
fi

# ─── Reinstall after reset ───────────────────────────────────────────────────
admin_apply
admin_verify

printf 'PASS: ai-permissions administrative lifecycle\n'
