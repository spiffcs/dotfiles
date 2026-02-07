# shellcheck shell=bash
# Shared output helpers and spinner for long-running commands.
# Sourced by install.sh — do not execute directly.

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

print_info() {
  echo -e "${BLUE}[INFO]${NC} ${1}"
}

print_success() {
  echo -e "${GREEN}[OK]${NC} ${1}"
}

print_warning() {
  echo -e "${YELLOW}[WARN]${NC} ${1}" >&2
}

print_error() {
  echo -e "${RED}[ERROR]${NC} ${1}" >&2
}

print_dry() {
  echo -e "${YELLOW}[DRY-RUN]${NC} ${1}"
}

# -----------------------------------------------------------------------------
# Spinner for long-running commands
# -----------------------------------------------------------------------------

_spinner_pid=""

# Starts a background spinner with a message.
# Globals:
#   _spinner_pid
# Arguments:
#   msg - text to display next to the spinner
_start_spinner() {
  local msg="${1}"
  if [[ ! -t 1 ]]; then
    printf "  ... %s\n" "${msg}"
    return
  fi
  (
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while true; do
      printf "\r  ${BLUE}%s${NC} %s" "${spin:i++%${#spin}:1}" "${msg}"
      sleep 0.1
    done
  ) &
  _spinner_pid=$!
}

# Stops the spinner and prints a success/failure indicator.
# Globals:
#   _spinner_pid
# Arguments:
#   exit_code - 0 for success, non-zero for failure
#   msg - text to display next to the indicator
_stop_spinner() {
  local exit_code="${1}"
  local msg="${2}"
  if [[ -n "${_spinner_pid}" ]]; then
    kill "${_spinner_pid}" 2>/dev/null
    wait "${_spinner_pid}" 2>/dev/null || true
    _spinner_pid=""
  fi
  if [[ -t 1 ]]; then
    if (( exit_code == 0 )); then
      printf "\r  ${GREEN}✔${NC} %s\n" "${msg}"
    else
      printf "\r  ${RED}✘${NC} %s\n" "${msg}"
    fi
  fi
}

# Runs a command with a spinner, showing progress to the user.
# Globals:
#   DRY_RUN
# Arguments:
#   msg - description shown during execution
#   ... - command and arguments to run
# Returns:
#   Exit code of the executed command.
run_with_spinner() {
  local msg="${1}"
  shift
  if ${DRY_RUN}; then
    print_dry "Would run: $*"
    return 0
  fi
  _start_spinner "${msg}"
  local output
  local exit_code=0
  output=$("$@" 2>&1) || exit_code=$?
  _stop_spinner "${exit_code}" "${msg}"
  if (( exit_code != 0 )); then
    echo "${output}" | tail -5 >&2
  fi
  return "${exit_code}"
}
