#!/usr/bin/env bash
# Script: shellcheck-wrapper.sh
# Purpose: Run ShellCheck with RylanLabs canon exclusions and formatted output
# Domain: Validation
# Agent: Bauer
# Author: rylanlab canonical
# Date: 2025-12-19
# Usage: ./shellcheck-wrapper.sh [--fix] [--recursive] <path...>

set -euo pipefail
IFS=$'\n\t'

#######################################
# Pattern sourcing (if available)
#######################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/../patterns/error-handling.sh" ]]; then
  source "${SCRIPT_DIR}/../patterns/error-handling.sh"
  source "${SCRIPT_DIR}/../patterns/audit-logging.sh" 2>/dev/null || true
  setup_error_traps
fi

#######################################
# Constants
#######################################
readonly SCRIPT_NAME="$(basename "$0")"

# Canon-justified exclusions
# SC2034: Appears unused — intentional in sourced libraries
# SC2086: Quote to prevent word splitting — disabled only for intentional cases (e.g., PATH)
# SC2154: Var referenced but not assigned — used in sourced contexts
# SC1090: Can't follow non-constant source — dynamic sourcing
# SC1091: Not following sourced file — external libs
readonly EXCLUDES="SC2034,SC2086,SC2154,SC1090,SC1091"

#######################################
# Require shellcheck
#######################################
if ! command -v shellcheck &>/dev/null; then
  fail "ShellCheck not installed" 3 "Install via: sudo apt install shellcheck (Debian/Ubuntu) or brew install shellcheck (macOS)"
fi

#######################################
# Usage
#######################################
usage() {
  cat << EOF
${SCRIPT_NAME} — RylanLabs canon ShellCheck validator

Usage: ${SCRIPT_NAME} [options] <file|directory...>

Options:
  -h, --help       Show this help
  -f, --fix        Show detailed fix suggestions
  -r, --recursive  Validate all .sh files recursively
  -x, --external   Include external sources in checks

Description:
  Runs ShellCheck with canon-compliant exclusions.
  Exit 0: Clean | 1: Warnings | >1: Errors

EOF
  exit 0
}

#######################################
# Run ShellCheck on targets
#######################################
run_shellcheck() {
  local files=("$@")
  local args=("-f" "gcc" "-C" "-a")

  # Add excludes
  args+=("-e" "${EXCLUDES}")

  # Optional flags
  [[ "${FIX:-false}" == true ]] && args+=("-s" "bash")
  [[ "${EXTERNAL:-false}" == true ]] && args+=("--external-sources")

  if declare -F log_info &>/dev/null; then
    log_info "Running ShellCheck on ${#files[@]} file(s)"
    audit_log "VALIDATE_SHELLCHECK" "start" "files=${#files[@]}"
  fi

  shellcheck "${args[@]}" "${files[@]}"
  local sc_exit=$?

  if (( sc_exit == 0 )); then
    if declare -F log_info &>/dev/null; then
      log_info "ShellCheck clean — canon compliant"
      audit_log "VALIDATE_SHELLCHECK" "success"
    fi
  else
    if declare -F log_error &>/dev/null; then
      log_error "ShellCheck found issues (exit ${sc_exit})"
      audit_log "VALIDATE_SHELLCHECK" "failure" "exit=${sc_exit}"
    fi
  fi

  return ${sc_exit}
}

#######################################
# Main
#######################################
main() {
  local fix=false recursive=false external=false
  local targets=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage ;;
      -f|--fix) fix=true; shift ;;
      -r|--recursive) recursive=true; shift ;;
      -x|--external) external=true; shift ;;
      *) targets+=("$1"); shift ;;
    esac
  done

  [[ ${#targets[@]} -eq 0 ]] && fail "No targets specified" 2 "Provide files/directories or use --recursive"

  FIX="${fix}" EXTERNAL="${external}"

  local files_to_check=()

  if [[ "${recursive}" == true ]]; then
    for target in "${targets[@]}"; do
      [[ -d "${target}" ]] || fail "Recursive target must be directory: ${target}"
      mapfile -t found < <(find "${target}" -type f -name "*.sh" -print)
      files_to_check+=("${found[@]}")
    done
  else
    files_to_check=("${targets[@]}")
  fi

  [[ ${#files_to_check[@]} -eq 0 ]] && fail "No .sh files found"

  timer_start "shellcheck-validation"
  run_shellcheck "${files_to_check[@]}"
  local exit_code=$?
  timer_end

  exit "${exit_code}"
}

main "$@"