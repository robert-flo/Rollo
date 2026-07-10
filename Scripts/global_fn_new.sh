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
# │ Hardware Detection                                                           │
# └──────────────────────────────────────────────────────────────────────────────┘

nvidia_detect() {
  local gpu_name=""
  local gpu_code=""
  local index=""

  readarray -t dGPU < <(lspci -k | grep -E "(VGA|3D)" | awk -F ': ' '{print $NF}')

  case "${1:-}" in
    --verbose)
      for index in "${!dGPU[@]}"; do
        echo -e "${GREEN}[gpu${index}]${NC} detected :: ${dGPU[$index]}"
      done
      return 0
      ;;
    --drivers)
      for gpu_name in "${dGPU[@]}"; do
        gpu_code="${gpu_name%% *}"
        awk -F '|' -v nvc="$gpu_code" 'substr(nvc, 1, length($3)) == $3 {split(FILENAME, driver, "/"); print driver[length(driver)], "\nnvidia-utils"}' "${scrDir}"/nvidia-db/nvidia*dkms
      done
      return 0
      ;;
  esac

  grep -iq nvidia <<< "${dGPU[*]}"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Interactive Utilities                                                        │
# └──────────────────────────────────────────────────────────────────────────────┘

prompt_timer() {
  local message="$2"
  local prompt_input="/dev/stdin"
  local remaining_seconds="$1"

  unset PROMPT_INPUT

  if [[ -t 0 && -r /dev/tty ]]; then
    prompt_input="/dev/tty"
  fi

  while ((remaining_seconds >= 0)); do
    echo -ne "\r :: ${message} (${remaining_seconds}s) : "
    if IFS= read -r -t 1 -n 1 PROMPT_INPUT < "$prompt_input"; then
      break
    fi
    ((remaining_seconds--))
  done

  export PROMPT_INPUT
  echo ""
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

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Console Output & Logging                                                     │
# └──────────────────────────────────────────────────────────────────────────────┘

info() {
  print_info "$*"
}

success() {
  print_success "$*"
}

warn_msg() {
  print_warn "$*" >&2
}

error_msg() {
  print_error "$*" >&2
}

step() {
  print_step "$*"
}

print_log() {
  local color=""
  local executable="${0##*/}"
  local log_file="${cacheDir}/logs/${RAVN_LOG:-}/${executable}.log"
  local message=""
  local section="${log_section:-}"

  if [[ -n $section ]]; then
    message+="${GREEN}[${section}] ${NC}"
  fi

  while (($#)); do
    case "$1" in
      -r | +r)
        message+="${RED}${2}${NC}"
        shift 2
        ;;
      -g | +g)
        message+="${GREEN}${2}${NC}"
        shift 2
        ;;
      -y | +y)
        message+="${YELLOW}${2}${NC}"
        shift 2
        ;;
      -b | +b)
        message+="${BLUE}${2}${NC}"
        shift 2
        ;;
      -m | +m)
        message+="${MAGENTA}${2}${NC}"
        shift 2
        ;;
      -c | +c)
        message+="${CYAN}${2}${NC}"
        shift 2
        ;;
      -wt | +w)
        message+="${WHITE}${2}${NC}"
        shift 2
        ;;
      -n | +n)
        message+="\033[0;96m${2}${NC}"
        shift 2
        ;;
      -stat)
        message+="\033[30;46m ${2} ${NC} :: "
        shift 2
        ;;
      -crit)
        message+="\033[97;41m ${2} ${NC} :: "
        shift 2
        ;;
      -warn)
        message+="WARNING :: \033[30;43m ${2} ${NC} :: "
        shift 2
        ;;
      +)
        printf -v color '\033[38;5;%sm' "$2"
        message+="${color}${3}${NC}"
        shift 3
        ;;
      -sec)
        message+="${GREEN}[${2}] ${NC}"
        shift 2
        ;;
      -err)
        message+="ERROR :: \033[4;31m${2} ${NC}"
        shift 2
        ;;
      *)
        message+="$1"
        shift
        ;;
    esac
  done

  message+="\n"
  mkdir -p "$(dirname "$log_file")"

  if [[ -n ${RAVN_LOG:-} ]]; then
    printf '%b' "$message" | tee >(sed 's/\x1b\[[0-9;]*m//g' >> "$log_file")
  else
    printf '%b' "$message"
  fi
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Execution Helpers                                                            │
# └──────────────────────────────────────────────────────────────────────────────┘

spin() {
  local character=""
  local exit_code=0
  local index=0
  local message="${2:-Working...}"
  local pid="$1"
  local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

  if [[ ! -t 1 ]]; then
    wait "$pid" || exit_code=$?
    return "$exit_code"
  fi

  tput civis 2> /dev/null || true

  while kill -0 "$pid" 2> /dev/null; do
    character="${spinner:$index:1}"
    printf "\r  ${CYAN}%s${NC} %s" "$character" "$message"
    index=$(((index + 1) % ${#spinner}))
    sleep 0.08
  done

  tput cnorm 2> /dev/null || true
  wait "$pid" || exit_code=$?

  if ((exit_code == 0)); then
    printf "\r  ${GREEN}${ICON_CHECK}${NC} %s\n" "$message"
  else
    printf "\r  ${RED}${ICON_CROSS}${NC} %s\n" "$message"
  fi

  return "$exit_code"
}

run_with_status() {
  local message="$1"
  shift

  if ((${flg_DryRun:-0} == 1)); then
    echo -e "  ${YELLOW}⊘${NC} ${message} (dry-run)"
    return 0
  fi

  if [[ ${1:-} == "sudo" ]]; then
    sudo -v 2> /dev/null || true
  fi

  "$@" &> /dev/null &
  spin "$!" "$message"
}

retry() {
  local max_tries="$1"
  local pause_seconds=2
  local remaining_tries="$1"
  shift

  if "$@"; then
    return 0
  fi

  remaining_tries=$((remaining_tries - 1))
  while ((remaining_tries > 0)); do
    warn_msg "Reintentando en ${pause_seconds}s (${remaining_tries} intentos restantes): $*"
    sleep "$pause_seconds"
    pause_seconds=$((pause_seconds * 2))

    if "$@"; then
      return 0
    fi

    remaining_tries=$((remaining_tries - 1))
  done

  error_msg "Falló después de ${max_tries} intentos: $*"
  return 1
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Download Helpers                                                             │
# └──────────────────────────────────────────────────────────────────────────────┘

download_file() {
  local output="${2:-}"
  local url="$1"

  if command_exists curl; then
    if [[ -n $output ]]; then
      curl -fsSL -o "$output" "$url"
    else
      curl -fsSL "$url"
    fi
  elif command_exists wget; then
    if [[ -n $output ]]; then
      wget -q -O "$output" "$url"
    else
      wget -q -O - "$url"
    fi
  else
    error_msg "Se requiere curl o wget, pero ninguno está instalado"
    return 1
  fi
}

download_with_spinner() {
  local message="${3:-Descargando...}"
  local output="$2"
  local url="$1"

  download_file "$url" "$output" &> /dev/null &
  spin "$!" "$message"
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Repository Helpers                                                           │
# └──────────────────────────────────────────────────────────────────────────────┘

clone_or_update_repo() {
  local destination="$3"
  local name="$1"
  local prefer_ssh="${5:-}"
  local ref="${4:-master}"
  local remote_url=""
  local repository="$2"

  remote_url="https://github.com/${repository}.git"

  if [[ $prefer_ssh == "ssh" ]]; then
    if { [[ -f $HOME/.ssh/id_ed25519 ]] || [[ -f $HOME/.ssh/id_rsa ]]; } && ssh -T -o ConnectTimeout=3 -o BatchMode=yes git@github.com 2>&1 | grep -q "successfully authenticated"; then
      remote_url="git@github.com:${repository}.git"
      info "Llave SSH autorizada detectada. Usando protocolo SSH para ${name}."
    elif [[ -f $HOME/.ssh/id_ed25519 || -f $HOME/.ssh/id_rsa ]]; then
      warn_msg "Llave SSH detectada pero no autorizada en GitHub. Usando protocolo HTTPS para ${name}."
    fi
  fi

  if ((${flg_DryRun:-0} == 1)); then
    echo -e "  ${YELLOW}⊘${NC} Clonar/actualizar ${name} (dry-run)"
    return 0
  fi

  if [[ -d $destination/.git ]]; then
    info "Actualizando ${name} existente..."
    git -C "$destination" remote set-url origin "$remote_url" &> /dev/null || true
    if retry 3 git -C "$destination" fetch origin "$ref" &> /dev/null &&
      git -C "$destination" checkout "$ref" &> /dev/null &&
      git -C "$destination" reset --hard "origin/${ref}" &> /dev/null; then
      success "${name} sincronizado en la rama ${ref}."
    else
      error_msg "No se pudo sincronizar ${name}."
      return 1
    fi
  else
    info "Clonando ${name} desde: ${remote_url}"
    if retry 3 git clone "$remote_url" "$destination" &> /dev/null; then
      git -C "$destination" fetch origin "$ref" &> /dev/null &&
        git -C "$destination" checkout "$ref" &> /dev/null

      if [[ $prefer_ssh == "ssh" && $remote_url == git@* ]]; then
        git -C "$destination" remote set-url origin "$remote_url"
      fi
      success "${name} sincronizado en la rama ${ref}."
    else
      error_msg "No se pudo clonar ${name}."
      return 1
    fi
  fi
}
