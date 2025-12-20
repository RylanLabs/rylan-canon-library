#!/usr/bin/env bash
# Script: error-handling.sh
# Purpose: Provide reusable error handling, traps, and validation for sourced scripts
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/error-handling.sh" && setup_error_traps
# Domain: Verification (Error/Recovery)
# Agent: Bauer
# Author: rylanlab canonical
# Date: 2025-12-19

set -euo pipefail
IFS=$'\n\t'

#######################################
# Constants
#######################################
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL=1
readonly EXIT_MISUSE=2
readonly EXIT_CONFIG=3
readonly EXIT_NETWORK=4
readonly EXIT_PERMISSION=5
readonly EXIT_NOT_FOUND=127
readonly EXIT_CANNOT_EXEC=126

readonly COLOR_RED='\033[0;31m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_NC='\033[0m'

# Respect NO_COLOR convention
[[ "${NO_COLOR:-false}" == "true" ]] && COLOR_RED="" COLOR_YELLOW="" COLOR_NC=""

#######################################
# Structured error reporting
# Globals:
#   BASH_COMMAND, LINENO, BASH_LINENO, BASH_SOURCE
# Arguments:
#   $1 - Exit code from failed command
# Outputs:
#   Detailed error to stderr, audit log if available
#######################################
error_handler() {
  local exit_code="${1:-1}"
  local line_no="${LINENO:-unknown}"
  local command="${BASH_COMMAND:-unknown}"

  local msg="[ERROR] Failure at line ${line_no}: '${command}' (code ${exit_code})"

  echo -e "${COLOR_RED}${msg}${COLOR_NC}" >&2
  echo "   Fix: Review command context and preconditions" >&2

  # Stack trace (simple)
  echo "${COLOR_RED}   Trace:${COLOR_NC}" >&2
  local i=0
  while caller $i &>/dev/null; do
    echo "     $(caller $i)" >&2
    ((i++))
  done

  # Audit integration (if audit_log function exists)
  if declare -F audit_log &>/dev/null; then
    audit_log "ERROR" "Script failure" "line=${line_no} command=${command} code=${exit_code}"
  fi

  exit "${exit_code}"
}

#######################################
# Cleanup on exit (success or failure)
# Globals:
#   None (extend with your resources)
# Arguments:
#   None
# Outputs:
#   Warn on failure cleanup
#######################################
cleanup_on_exit() {
  local exit_code=$?

  # Placeholder: Add resource release here
  # rm -f /tmp/myapp.* 2>/dev/null || true
  # flock -u 200 || true

  if (( exit_code != EXIT_SUCCESS )); then
    echo -e "${COLOR_YELLOW}[WARN] Cleanup triggered after failure (code: ${exit_code})${COLOR_NC}" >&2

    if declare -F audit_log &>/dev/null; then
      audit_log "CLEANUP" "Post-failure cleanup" "exit_code=${exit_code}"
    fi
  fi

  # Do not override original exit code
}

#######################################
# Fail immediately with actionable message
# Arguments:
#   $1 - Message
#   $2 - Exit code (default: EXIT_GENERAL)
#   $3 - Remediation hint (optional)
#######################################
fail() {
  local message="$1"
  local code="${2:-${EXIT_GENERAL}}"
  local fix="${3:-}"

  echo -e "${COLOR_RED}[ERROR] ${message}${COLOR_NC}" >&2
  [[ -n "${fix}" ]] && echo "   Fix: ${fix}" >&2

  if declare -F audit_log &>/dev/null; then
    audit_log "FAIL" "${message}" "code=${code}"
  fi

  exit "${code}"
}

#######################################
# Warn without exiting
# Arguments:
#   $1 - Message
#######################################
warn() {
  local message="$1"
  echo -e "${COLOR_YELLOW}[WARN] ${message}${COLOR_NC}" >&2

  if declare -F audit_log &>/dev/null; then
    audit_log "WARN" "${message}"
  fi
}

#######################################
# Require external command exists
# Arguments:
#   $1 - Command name
#######################################
require_command() {
  local cmd="$1"
  if ! command -v "${cmd}" &>/dev/null; then
    fail "Required command missing: ${cmd}" "${EXIT_NOT_FOUND}" "Install ${cmd} package"
  fi
}

#######################################
# Require file exists and readable
# Arguments:
#   $1 - Path
#######################################
require_file() {
  local path="$1"
  [[ -f "${path}" ]] || fail "File not found: ${path}" "${EXIT_GENERAL}" "Create or check path"
  [[ -r "${path}" ]] || fail "File not readable: ${path}" "${EXIT_PERMISSION}" "chmod 644 ${path}"
}

#######################################
# Setup recommended traps (call once after sourcing)
# Outputs:
#   None (silent)
#######################################
setup_error_traps() {
  trap 'error_handler $?' ERR
  trap cleanup_on_exit EXIT
}

# Silence on source — caller invokes setup_error_traps explicitly
# No output, no TODO noise

#######################################
# Future Extensions (canon-ready)
#######################################
# retry_command() { ... }  # Exponential backoff
# with_timeout() { ... }   # Timeout wrapper