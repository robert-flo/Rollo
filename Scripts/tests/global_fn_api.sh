#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
baseline="${script_dir}/global_fn.sh"
candidate="${script_dir}/global_fn_new.sh"

die() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

list_functions() {
  local helper="$1"
  awk '/^[[:space:]]*[[:alnum:]_]+\(\)[[:space:]]*\{/ { sub(/^[[:space:]]*/, ""); sub(/\(.*/, ""); print }' "$helper"
}

list_exports() {
  local helper="$1"
  awk '/^[[:space:]]*export[[:space:]]+[[:alpha:]_][[:alnum:]_]*/ { sub(/^[[:space:]]*export[[:space:]]+/, ""); print $1 }' "$helper"
}

verify_helper() {
  local helper="$1"
  [[ -f "$helper" ]] || die "Missing helper: $helper"
  bash -n "$helper" || die "Syntax check failed: $helper"
}

compare_inventory() {
  local label="$1"
  local helper="$2"
  local output

  printf '\n[%s]\n' "$label"
  printf 'Functions:\n'
  output="$(list_functions "$helper")"
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  fi
  printf 'Exports:\n'
  output="$(list_exports "$helper")"
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  fi
}

verify_candidate_behavior() {
  local output

  output="$(bash -c 'source "$1"; print_header "Header"; print_section "Section"; print_step "Step"; print_success "Success"; print_error "Error"; print_warn "Warning"; print_info "Info"; command_exists bash' _ "$candidate")"
  [[ $output == *"Header"* ]] || die "Candidate header helper did not produce expected output"
  [[ $output == *"Section"* ]] || die "Candidate section helper did not produce expected output"
  [[ $output == *"Success"* ]] || die "Candidate success helper did not produce expected output"

  if bash -c 'source "$1"; command_exists command-that-does-not-exist' _ "$candidate"; then
    die "command_exists accepted a missing command"
  fi
}

verify_runtime_and_packages() {
  local helper=""
  local test_dir=""

  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN
  mkdir -p "$test_dir/bin" "$test_dir/Configs/.local/lib/hyde"

  cat > "$test_dir/bin/pacman" << 'EOF'
#!/usr/bin/env bash
[[ $1 == "-Q" && $2 == "installed-package" ]]
EOF
  cat > "$test_dir/Configs/.local/lib/hyde/pm.sh" << 'EOF'
#!/usr/bin/env bash
[[ $1 == "query" && $2 == "repository-package" ]] || [[ $1 == "info" && $2 == "aur-package" ]]
EOF
  chmod +x "$test_dir/bin/pacman" "$test_dir/Configs/.local/lib/hyde/pm.sh"

  for helper in "$baseline" "$candidate"; do
    CLONE_DIR="$test_dir" \
      XDG_CONFIG_HOME="$test_dir/config" \
      XDG_CACHE_HOME="$test_dir/cache" \
      PATH="$test_dir/bin:$PATH" \
      bash -c '
        source "$1"
        [[ $cloneDir == "$CLONE_DIR" ]]
        [[ $confDir == "$XDG_CONFIG_HOME" ]]
        [[ $cacheDir == "$XDG_CACHE_HOME/ravn" ]]
        [[ $pacmanCmd == "$CLONE_DIR/Configs/.local/lib/hyde/pm.sh" ]]
        [[ ${aurList[*]} == "yay paru" ]]
        [[ ${shlList[*]} == "zsh fish" ]]
        export -p | grep -q "declare -x cloneDir="
        export -p | grep -q "declare -x confDir="
        export -p | grep -q "declare -x cacheDir="
        pkg_installed installed-package
        ! pkg_installed missing-package
        pkg_available repository-package
        ! pkg_available missing-package
        aur_available aur-package
        ! aur_available missing-package
        chk_list selected_package missing-package installed-package
        [[ $selected_package == "installed-package" ]]
        export -p | grep -q "declare -x selected_package="
        ! chk_list missing_selection missing-package
      ' _ "$helper" || die "Runtime and package compatibility check failed: $helper"
  done
}

verify_hardware_and_interaction() {
  local helper=""
  local test_dir=""

  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN
  mkdir -p "$test_dir/bin" "$test_dir/nvidia-db"

  cat > "$test_dir/bin/lspci" << 'EOF'
#!/usr/bin/env bash
printf '%s\n' '01:00.0 VGA compatible controller: NVIDIA Corporation GP108M [GeForce MX150]'
EOF
  cat > "$test_dir/nvidia-db/nvidia-dkms" << 'EOF'
vendor|family|NVIDIA
EOF
  chmod +x "$test_dir/bin/lspci"

  for helper in "$baseline" "$candidate"; do
    PATH="$test_dir/bin:$PATH" bash -c '
      source "$1"
      scrDir="$2"
      nvidia_detect
      nvidia_detect --verbose | sed "s/\x1b\[[0-9;]*m//g" | grep -Fq "[gpu0] detected :: NVIDIA Corporation"
      nvidia_detect --drivers | grep -q "nvidia-dkms"
      nvidia_detect --drivers | grep -qx "nvidia-utils"
      prompt_timer 0 "Continue" <<<"y"
      [[ $PROMPT_INPUT == "y" ]]
      export -p | grep -q "declare -x PROMPT_INPUT=\"y\""
    ' _ "$helper" "$test_dir" || die "NVIDIA and prompt compatibility check failed: $helper"
  done

  cat > "$test_dir/bin/lspci" << 'EOF'
#!/usr/bin/env bash
printf '%s\n' '00:02.0 VGA compatible controller: Intel Corporation UHD Graphics'
EOF

  for helper in "$baseline" "$candidate"; do
    if PATH="$test_dir/bin:$PATH" bash -c 'source "$1"; nvidia_detect' _ "$helper"; then
      die "Non-NVIDIA hardware was incorrectly detected: $helper"
    fi
  done
}

verify_console_and_logging() {
  local helper=""
  local test_dir=""

  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN

  for helper in "$baseline" "$candidate"; do
    CLONE_DIR="$test_dir" \
      XDG_CACHE_HOME="$test_dir/cache" \
      RAVN_LOG="console-test" \
      log_section="installer" \
      bash -c '
        source "$1"
        print_log -sec "core" -g "ready" -warn "careful" -err "broken" -stat "state" "active" -crit "stop" + 208 " manual"
      ' _ "$helper" > "$test_dir/output" || die "Console logging check failed: $helper"

    sed "s/\x1b\[[0-9;]*m//g" "$test_dir/output" > "$test_dir/output-clean"
    grep -Fq "[installer] [core] readyWARNING ::  careful" "$test_dir/output-clean" || die "Section and warning output changed: $helper"
    grep -Fq "ERROR :: broken" "$test_dir/output-clean" || die "Error output changed: $helper"
    grep -Fq "state  :: active stop  ::  manual" "$test_dir/output-clean" || die "Status output changed: $helper"

    log_file="$test_dir/cache/ravn/logs/console-test/_.log"
    [[ -f $log_file ]] || die "Log file was not created: $helper"
    ! grep -q $'\033' "$log_file" || die "Log file contains ANSI escapes: $helper"
    grep -Fq "ERROR :: broken" "$log_file" || die "Log file lost output: $helper"

    bash -c '
      source "$1"
      info "info message"
      success "success message"
      step "step message"
    ' _ "$helper" > "$test_dir/stdout" || die "Console aliases failed: $helper"
    bash -c '
      source "$1"
      warn_msg "warning message"
      error_msg "error message"
    ' _ "$helper" 2> "$test_dir/stderr" || die "Error aliases failed: $helper"
    grep -Fq "info message" "$test_dir/stdout" || die "Info alias lost output: $helper"
    grep -Fq "success message" "$test_dir/stdout" || die "Success alias lost output: $helper"
    grep -Fq "step message" "$test_dir/stdout" || die "Step alias lost output: $helper"
    grep -Fq "warning message" "$test_dir/stderr" || die "Warning alias lost stderr: $helper"
    grep -Fq "error message" "$test_dir/stderr" || die "Error alias lost stderr: $helper"

    # shellcheck disable=SC2016 # The child shell evaluates this compatibility fixture.
    CLONE_DIR="$test_dir/no-log" \
      XDG_CACHE_HOME="$test_dir/no-log/cache" \
      env -u RAVN_LOG bash -c '
        source "$1"
        print_log "without persisted log"
      ' _ "$helper" > /dev/null || die "Logging without RAVN_LOG failed: $helper"
    [[ -d $test_dir/no-log/cache/ravn/logs ]] || die "Log directory side effect changed: $helper"
    [[ ! -f $test_dir/no-log/cache/ravn/logs/_.log ]] || die "Unexpected persisted log without RAVN_LOG: $helper"
  done
}

verify_execution_and_retry() {
  local helper=""
  local test_dir=""

  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN
  mkdir -p "$test_dir/bin"

  cat > "$test_dir/bin/sleep" << 'EOF'
#!/usr/bin/env bash
:
EOF
  cat > "$test_dir/bin/sudo" << 'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$SUDO_LOG"
if [[ $1 == "-v" ]]; then
  exit 0
fi
"$@"
EOF
  cat > "$test_dir/transient-command" << 'EOF'
#!/usr/bin/env bash
count=0
if [[ -f $RETRY_COUNT ]]; then
  count=$(<"$RETRY_COUNT")
fi
count=$((count + 1))
printf '%s' "$count" > "$RETRY_COUNT"
((count >= 2))
EOF
  chmod +x "$test_dir/bin/sleep" "$test_dir/bin/sudo" "$test_dir/transient-command"

  for helper in "$baseline" "$candidate"; do
    rm -f "$test_dir/retry-count" "$test_dir/sudo-log"
    PATH="$test_dir/bin:$PATH" \
      RETRY_COUNT="$test_dir/retry-count" \
      SUDO_LOG="$test_dir/sudo-log" \
      bash -e -c '
        source "$1"
        (exit 0) &
        spin "$!" "successful spin"
        (exit 1) &
        if spin "$!" "failed spin"; then
          exit 1
        fi
        flg_DryRun=0
        run_with_status "real command" touch "$2/real-command"
        [[ -f $2/real-command ]]
        run_with_status "sudo command" sudo touch "$2/sudo-command"
        [[ -f $2/sudo-command ]]
        grep -qx -- "-v" "$SUDO_LOG"
        flg_DryRun=1
        run_with_status "dry command" touch "$2/dry-command"
        [[ ! -e $2/dry-command ]]
        retry 3 "$2/transient-command"
        [[ $(<"$RETRY_COUNT") == "2" ]]
        if retry 1 false; then
          exit 1
        fi
      ' _ "$helper" "$test_dir" || die "Execution and retry compatibility check failed: $helper"
  done
}

verify_helper "$baseline"
verify_helper "$candidate"
compare_inventory "Baseline" "$baseline"
compare_inventory "Candidate" "$candidate"
verify_candidate_behavior
verify_runtime_and_packages
verify_hardware_and_interaction
verify_console_and_logging
verify_execution_and_retry

printf '\nAPI inventory completed successfully.\n'
