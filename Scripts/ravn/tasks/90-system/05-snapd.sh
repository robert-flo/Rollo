#!/usr/bin/env bash
# ─── RaVN Task: Snapd Configuration ──────────────────────────────────────────
# Manages snapd, AppArmor service, snapd socket, and classic snap support.

# shellcheck disable=SC2034
ADMIN_TASK_ID="snapd"
# shellcheck disable=SC2034
ADMIN_TASK_FAMILY="system-config"
# shellcheck disable=SC2034
ADMIN_EXECUTION_PROFILE="privileged-system-config"
# shellcheck disable=SC2034
ADMIN_REQUIRES_PRIVILEGE=true
# shellcheck disable=SC2034
ADMIN_OWNED_RESOURCES=("snapd package" "snapd.apparmor.service" "snapd.socket" "/snap symlink")
# shellcheck disable=SC2034
ADMIN_RESOURCE_CONFLICTS=()
# shellcheck disable=SC2034
ADMIN_REVERSIBILITY="reversible"
# shellcheck disable=SC2034
ADMIN_ACTIVATION_BOUNDARY="new session or reboot"
# shellcheck disable=SC2034
ADMIN_TEST_LEVEL="isolated,docker"

readonly SNAPD_PACKAGE="snapd"
readonly APPARMOR_SERVICE="snapd.apparmor.service"
readonly SNAPD_SOCKET="snapd.socket"
readonly SNAP_LINK="/snap"
readonly SNAP_TARGET="/var/lib/snapd/snap"

_run_as_root() {
  if ((EUID == 0)); then
    "$@"
  else
    sudo "$@"
  fi
}

_pkg_installed() {
  _run_as_root pacman -Q "$1" > /dev/null 2>&1
}

_systemctl_enabled() {
  _run_as_root systemctl is-enabled --quiet "$1" 2> /dev/null
}

_systemctl_active() {
  _run_as_root systemctl is-active --quiet "$1" 2> /dev/null
}

_symlink_correct() {
  [[ -L $SNAP_LINK ]] && [[ "$(readlink "$SNAP_LINK")" == "$SNAP_TARGET" ]]
}

admin_plan() {
  ADMIN_PLAN_ACTIONS=(
    "install snapd package"
    "enable and start snapd.apparmor.service"
    "enable and start snapd.socket"
    "create /snap -> /var/lib/snapd/snap symlink"
  )
  command -v sudo > /dev/null 2>&1 &&
    command -v pacman > /dev/null 2>&1 &&
    command -v systemctl > /dev/null 2>&1 || return 1
  return 0
}

admin_apply() {
  admin_plan || return 1

  if ! _pkg_installed "$SNAPD_PACKAGE"; then
    _run_as_root pacman -S --needed --noconfirm "$SNAPD_PACKAGE" || return 1
  fi

  _systemctl_enabled "$APPARMOR_SERVICE" ||
    _run_as_root systemctl enable --now "$APPARMOR_SERVICE" || return 1
  _systemctl_enabled "$SNAPD_SOCKET" ||
    _run_as_root systemctl enable --now "$SNAPD_SOCKET" || return 1

  if ! _symlink_correct; then
    _run_as_root ln -sf "$SNAP_TARGET" "$SNAP_LINK" || return 1
  fi
}

admin_verify() {
  _pkg_installed "$SNAPD_PACKAGE" || return 1
  _systemctl_enabled "$APPARMOR_SERVICE" || return 1
  _systemctl_active "$APPARMOR_SERVICE" || return 1
  _systemctl_enabled "$SNAPD_SOCKET" || return 1
  _systemctl_active "$SNAPD_SOCKET" || return 1
  _symlink_correct || return 1
  return 0
}

admin_rollback() {
  admin_reset
}

admin_reset() {
  admin_plan || return 1

  if _systemctl_enabled "$SNAPD_SOCKET"; then
    _run_as_root systemctl disable --now "$SNAPD_SOCKET" || true
  fi
  if _systemctl_enabled "$APPARMOR_SERVICE"; then
    _run_as_root systemctl disable --now "$APPARMOR_SERVICE" || true
  fi
  if _symlink_correct; then
    _run_as_root rm -f "$SNAP_LINK" || true
  fi
  return 0
}

admin_verify_reset() {
  ! _systemctl_enabled "$APPARMOR_SERVICE" || return 1
  ! _systemctl_enabled "$SNAPD_SOCKET" || return 1
  ! _symlink_correct || return 1
  return 0
}

check() { admin_verify; }
install() { admin_apply; }
verify() { admin_verify; }
reset() { admin_reset; }
verify_reset() { admin_verify_reset; }
