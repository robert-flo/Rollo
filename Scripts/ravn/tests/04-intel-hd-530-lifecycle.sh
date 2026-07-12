#!/usr/bin/env bash
set -euo pipefail

RAVN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
root=$(mktemp -d "${TMPDIR:-/tmp}/ravn-intel-hd-530-test.XXXXXX")
trap 'rm -rf "$root"' EXIT

fake_bin="$root/bin"
state="$root/pkgs"
mkdir -p "$fake_bin"

cat > "$fake_bin/sudo" << 'EOF'
#!/usr/bin/env bash
exec "$@"
EOF

cat > "$fake_bin/pacman" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
state_file="${RAVN_INTEL_PKGS_STATE:?}"
_last_pkg() {
  local pkg=""
  for arg in "$@"; do
    [[ $arg == -* ]] && continue
    pkg="$arg"
  done
  printf '%s\n' "$pkg"
}
case "${1:-}" in
  -Q)
    grep -qxF "$2" "$state_file"
    ;;
  -S)
    [[ ${RAVN_INTEL_SCENARIO:-active} != apply-failure ]] || exit 1
    for arg in "$@"; do
      [[ $arg == -* ]] && continue
      grep -qxF "$arg" "$state_file" || printf '%s\n' "$arg" >> "$state_file"
    done
    ;;
  -Rns)
    pkg=$(_last_pkg "$@")
    tmp=$(mktemp)
    grep -vxF "$pkg" "$state_file" > "$tmp" || true
    mv "$tmp" "$state_file"
    ;;
  *) exit 2 ;;
esac
EOF
chmod +x "$fake_bin"/*

export PATH="$fake_bin:$PATH" RAVN_INTEL_PKGS_STATE="$state"
: > "$state"
# shellcheck disable=SC1090,SC1091
source "$RAVN_DIR/tasks/90-system/04-intel-hd-530.sh"

# ─── Happy path ──────────────────────────────────────────────────────────────
admin_plan
admin_apply
admin_verify
admin_apply
admin_verify
admin_rollback
admin_verify_reset
admin_reset
admin_verify_reset
admin_apply
admin_verify

# ─── Apply failure ───────────────────────────────────────────────────────────
: > "$state"
export RAVN_INTEL_SCENARIO=apply-failure
if admin_apply; then
  printf 'FAIL: pacman apply failure unexpectedly passed\n' >&2
  exit 1
fi

# ─── Conflict removal on apply ──────────────────────────────────────────────
export RAVN_INTEL_SCENARIO=active
: > "$state"
printf '%s\n' intel-compute-runtime intel-graphics-compiler > "$state"
if admin_verify; then
  printf 'FAIL: conflicts present but verify passed\n' >&2
  exit 1
fi
admin_apply
admin_verify

printf 'PASS: Intel HD 530 administrative lifecycle\n'
