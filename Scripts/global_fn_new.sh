#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────────────────────────╮
# │                                                                              │
# │                        Global Functions & Variables                          │
# │                         Reusable Shell Script Utils                          │
# │                                                                              │
# ╰──────────────────────────────────────────────────────────────────────────────╯

# shellcheck disable=SC2034

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Colors & Styling                                                             │
# └──────────────────────────────────────────────────────────────────────────────┘

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m'

# Nerd Font Icons
readonly ICON_CHECK="✓"
readonly ICON_CROSS="✗"
readonly ICON_ARROW="→"
readonly ICON_WARN="⚠"
readonly ICON_INFO="ℹ"
readonly ICON_KEY="󰌋"
readonly ICON_LOCK="󰌾"
readonly ICON_GIT=""
readonly ICON_GITHUB=""
readonly ICON_GEAR="󰒓"
readonly ICON_ROCKET="󱓞"
readonly ICON_PACKAGE="󰏗"

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Global Variables                                                             │
# └──────────────────────────────────────────────────────────────────────────────┘

scrDir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cloneDir="${CLONE_DIR:-$(dirname "$scrDir")}"
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
cacheDir="${XDG_CACHE_HOME:-$HOME/.cache}/ravn"
aurList=("yay" "paru")
shlList=("zsh" "fish")
pacmanCmd="${cloneDir}/Configs/.local/lib/hyde/pm.sh"

export cloneDir
export confDir
export cacheDir
export aurList
export shlList

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Package Management                                                           │
# └──────────────────────────────────────────────────────────────────────────────┘

pkg_installed() {
  local package_name="$1"

  pacman -Q "$package_name" &> /dev/null
}

chk_list() {
  local variable_name="$1"
  local package_name=""
  local packages=("${@:2}")

  for package_name in "${packages[@]}"; do
    if pkg_installed "$package_name"; then
      printf -v "$variable_name" '%s' "$package_name"
      # shellcheck disable=SC2163 # Dynamic variable name is part of the public contract.
      export "$variable_name"
      return 0
    fi
  done

  return 1
}

pkg_available() {
  local package_name="$1"

  "$pacmanCmd" query "$package_name" &> /dev/null
}

aur_available() {
  local package_name="$1"

  "$pacmanCmd" info "$package_name" &> /dev/null
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Helper Functions                                                             │
# └──────────────────────────────────────────────────────────────────────────────┘

# cleanup() - Generic cleanup function template
# Each script should override this function to define its own cleanup logic.
# The trap is set in each individual script because it depends on script-specific resources.
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # Override this function in your script to add custom cleanup logic
  # Example:
  #   if [[ -f /tmp/my_temp_file ]]; then
  #     rm -f /tmp/my_temp_file
  #   fi
}

print_header() {
  echo ""
  echo -e "${CYAN}╭────────────────────────────────────────────────────────────╮${NC}"
  echo -e "${CYAN}│${NC}  ${WHITE}$1${NC}"
  echo -e "${CYAN}╰────────────────────────────────────────────────────────────╯${NC}"
}

print_section() {
  echo ""
  echo -e "${MAGENTA}  $1${NC}"
  echo -e "${GRAY}  ──────────────────────────────────────────────────────────${NC}"
}

print_step() {
  echo -e "  ${GRAY}${ICON_ARROW}${NC} $1"
}

print_success() {
  echo -e "  ${GREEN}${ICON_CHECK}${NC} $1"
}

print_error() {
  echo -e "  ${RED}${ICON_CROSS}${NC} $1"
}

print_warn() {
  echo -e "  ${YELLOW}${ICON_WARN}${NC} $1"
}

print_info() {
  echo -e "  ${BLUE}${ICON_INFO}${NC} $1"
}

command_exists() {
  command -v "$1" > /dev/null 2>&1
}
