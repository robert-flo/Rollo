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

  bash -c 'source "$1"; command_exists command-that-does-not-exist' _ "$candidate" && die "command_exists accepted a missing command"
}

verify_helper "$baseline"
verify_helper "$candidate"
compare_inventory "Baseline" "$baseline"
compare_inventory "Candidate" "$candidate"
verify_candidate_behavior

printf '\nAPI inventory completed successfully.\n'
