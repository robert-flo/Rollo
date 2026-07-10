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

verify_helper "$baseline"
verify_helper "$candidate"
compare_inventory "Baseline" "$baseline"
compare_inventory "Candidate" "$candidate"
verify_candidate_behavior
verify_runtime_and_packages
verify_hardware_and_interaction

printf '\nAPI inventory completed successfully.\n'
