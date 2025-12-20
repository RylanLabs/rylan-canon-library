#!/usr/bin/env bash
# Script: validate-bash-headers.sh
# Purpose: Verify bash scripts conform to RylanLabs canonical header standard
# Domain: Validation
# Agent: Bauer
# Author: rylanlab canonical
# Date: 2025-12-19
# Usage: ./validate-bash-headers.sh [--recursive] <path...>

set -euo pipefail
IFS=$'\n\t'

#######################################
# Pattern sourcing
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

# Required header lines (exact or pattern)
declare -r REQUIRED_LINES=(
  '^#!/usr/bin/env bash$'
  '^# Script: .+\.sh$'
  '^# Purpose: .+$'
  '^# Agent: (Carter|Bauer|Beale)(\s*\|\s*(Carter|Bauer|Beale))*$'
  '^# Author: rylanlab canonical$'
  '^# Date: [0-9]{4}-[0-9]{2}-[0-9]{2}$'
  '^set -euo pipefail$'
  "^IFS=\$'\n\t'$"
)

# Recommended but not fatal
declare -r RECOMMENDED_LINES=(
  '^# Domain: .+$'
  '^# Usage: .+$'
)

#######################################
# Usage
#######################################
usage() {
  cat << EOF
${SCRIPT_NAME} — RylanLabs canonical header validator

Usage: ${SCRIPT_NAME} [options] <file|directory...>

Options:
  -h, --help       Show this help
  -r, --recursive  Validate all .sh files recursively

Description:
  Ensures every bash script has complete canonical header.
  Exit 0: Valid | 1: Warnings | 2: Errors

EOF
  exit 0
}

#######################################
# Validate single file
#######################################
validate_file() {
  local file="$1"
  local lineno=1
  local errors=0
  local warnings=0
  local line

  if declare -F log_info &>/dev/null; then
    log_info "Validating headers: ${file}"
  fi

  # Read first 20 lines (headers should be early)
  while IFS= read -r line || [[ -n "$line" ]]; do
    ((lineno++))

    # Stop after script content starts (empty line or non-comment)
    [[ -z "$line" || "$line" =~ ^[^#] ]] && [[ $lineno -gt 15 ]] && break
  done < "$file"

  # Reset for actual checks
  lineno=1
  mapfile -t lines < <(head -n 20 "$file")

  # Required checks
  for pattern in "${REQUIRED_LINES[@]}"; do
    local found=false
    for i in "${!lines[@]}"; do
      if [[ "${lines[i]}" =~ $pattern ]]; then
        found=true
        break
      fi
    done

    if ! "$found"; then
      echo "ERROR: Missing required header element: ${pattern}" >&2
      echo "   File: ${file}" >&2
      echo "   Fix: Add matching line to header" >&2
      ((errors++))
    fi
  done

  # Recommended checks
  for pattern in "${RECOMMENDED_LINES[@]}"; do
    local found=false
    for line in "${lines[@]}"; do
      if [[ "$line" =~ $pattern ]]; then
        found=true
        break
      fi
    done

    if ! "$found"; then
      echo "WARN: Recommended header missing: ${pattern}" >&2
      echo "   File: ${file}" >&2
      ((warnings++))
    fi
  done

  if (( errors > 0 )); then
    if declare -F audit_log &>/dev/null; then
      audit_log "HEADER_VALIDATION" "error" "file=${file}" "errors=${errors}"
    fi
    return 2
  elif (( warnings > 0 )); then
    if declare -F audit_log &>/dev/null; then
      audit_log "HEADER_VALIDATION" "warning" "file=${file}" "warnings=${warnings}"
    fi
    return 1
  else
    if declare -F log_info &>/dev/null; then
      log_info "Headers valid: ${file}"
    fi
    if declare -F audit_log &>/dev/null; then
      audit_log "HEADER_VALIDATION" "success" "file=${file}"
    fi
    return 0
  fi
}

#######################################
# Main
#######################################
main() {
  local recursive=false
  local targets=()
  local max_exit=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage ;;
      -r|--recursive) recursive=true; shift ;;
      *) targets+=("$1"); shift ;;
    esac
  done

  [[ ${#targets[@]} -eq 0 ]] && fail "No targets specified" 2 "Provide files/directories"

  local files=()

  if [[ "$recursive" == true ]]; then
    for target in "${targets[@]}"; do
      [[ -d "$target" ]] || fail "Recursive target must be directory: $target"
      mapfile -t found < <(find "$target" -type f -name "*.sh")
      files+=("${found[@]}")
    done
  else
    files=("${targets[@]}")
  fi

  [[ ${#files[@]} -eq 0 ]] && fail "No .sh files found to validate"

  timer_start "header-validation"

  for file in "${files[@]}"; do
    [[ -f "$file" && -r "$file" ]] || { warn "Cannot read: $file"; continue; }
    validate_file "$file"
    local status=$?
    (( status > max_exit )) && max_exit=$status
  done

  timer_end

  if (( max_exit == 0 )); then
    log_info "All headers canon-compliant"
  fi

  exit "${max_exit}"
}

main "$@"