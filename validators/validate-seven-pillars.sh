#!/usr/bin/env bash
# Script: validate-seven-pillars.sh
# Purpose: Verify scripts demonstrate all Seven Pillars of Hellodeolu v6
# Domain: Validation
# Agent: Bauer
# Author: rylanlab canonical
# Date: 2025-12-19
# Usage: ./validate-seven-pillars.sh [--strict] [--explain] <path...>

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
readonly PILLARS=(1 2 3 4 5 6 7)

#######################################
# Usage
#######################################
usage() {
  cat << EOF
${SCRIPT_NAME} — Seven Pillars compliance validator

Usage: ${SCRIPT_NAME} [options] <file|directory...>

Options:
  -h, --help     Show this help
  -s, --strict   Treat missing pillars as errors
  -e, --explain  Show detailed reasoning
  -r, --recursive Validate recursively

Description:
  Heuristic validation of Seven Pillars demonstration.
  Exit 0: Compliant | 1: Warnings | 2: Errors (strict or critical)

EOF
  exit 0
}

#######################################
# Check single pillar in file
#######################################
check_pillar() {
  local file="$1"
  local pillar="$2"
  local strict="$3"
  local explain="$4"
  local found=false
  local reason=""

  case "${pillar}" in
    1) # Idempotency
      if grep -qE "idempotency\.sh|marker_exists|run_idempotent|acquire_lock" "$file"; then
        found=true
        reason="Detected sourcing or use of idempotency patterns"
      else
        reason="No idempotency patterns (marker/lock) detected"
      fi
      ;;
    2) # Error Handling
      if grep -qE "setup_error_traps|trap.*ERR|fail \+|error-handling\.sh" "$file"; then
        found=true
        reason="Detected canon error handling (traps or fail())"
      else
        reason="No error traps or fail() usage found"
      fi
      ;;
    3) # Audit Logging
      if grep -qE "audit_log|log_info|log_error|audit-logging\.sh" "$file"; then
        found=true
        reason="Detected audit_log or structured logging"
      else
        reason="No audit_log calls detected"
      fi
      ;;
    4) # Documentation Clarity
      if grep -qE "^# Purpose:|^# Usage:|^# Agent:" "$file" && grep -q "rylanlab canonical" "$file"; then
        found=true
        reason="Canonical header with Purpose, Usage, Agent present"
      else
        reason="Incomplete or non-canonical header"
      fi
      ;;
    5) # Validation
      if grep -qE "require_command|require_file|validate_|[[ -z|\[\[ -n" "$file"; then
        found=true
        reason="Detected input/precondition validation"
      else
        reason="No input validation patterns found"
      fi
      ;;
    6) # Reversibility
      if grep -qE "cleanup|trap.*EXIT|rollback|remove_marker" "$file"; then
        found=true
        reason="Detected cleanup trap or rollback pattern"
      else
        reason="No cleanup trap or reversibility pattern"
      fi
      ;;
    7) # Observability
      if grep -qE "timer_start|timer_end|log_debug|log_info.*progress" "$file"; then
        found=true
        reason="Detected timing or progress logging"
      else
        reason="Limited observability indicators"
      fi
      ;;
  esac

  if ! "$found"; then
    local severity="WARN"
    (( strict )) && severity="ERROR"

    echo "${severity}: Pillar ${pillar} not demonstrated in ${file}" >&2
    [[ "$explain" == true ]] && echo "   Reason: ${reason}" >&2
    [[ "$explain" == true ]] && echo "   Fix: Implement pattern from rylan-canon-library" >&2

    return 1
  else
    [[ "$explain" == true ]] && echo "PASS: Pillar ${pillar} — ${reason}"
    return 0
  fi
}

#######################################
# Validate file against all pillars
#######################################
validate_file() {
  local file="$1"
  local strict="$2"
  local explain="$3"
  local failures=0

  log_info "Validating Seven Pillars: ${file}"

  for pillar in "${PILLARS[@]}"; do
    check_pillar "$file" "$pillar" "$strict" "$explain" || ((failures++))
  done

  if (( failures == 0 )); then
    log_info "All Seven Pillars demonstrated: ${file}"
    audit_log "PILLARS_VALIDATION" "success" "file=${file}"
    return 0
  elif (( strict || failures >= 3 )); then
    audit_log "PILLARS_VALIDATION" "error" "file=${file}" "missing=${failures}"
    return 2
  else
    audit_log "PILLARS_VALIDATION" "warning" "file=${file}" "missing=${failures}"
    return 1
  fi
}

#######################################
# Main
#######################################
main() {
  local strict=false explain=false recursive=false
  local targets=()
  local max_exit=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage ;;
      -s|--strict) strict=true; shift ;;
      -e|--explain) explain=true; shift ;;
      -r|--recursive) recursive=true; shift ;;
      *) targets+=("$1"); shift ;;
    esac
  done

  [[ ${#targets[@]} -eq 0 ]] && fail "No targets specified" 2 "Provide files/directories"

  local files=()

  if [[ "$recursive" == true ]]; then
    for target in "${targets[@]}"; do
      mapfile -t found < <(find "$target" -type f -name "*.sh")
      files+=("${found[@]}")
    done
  else
    files=("${targets[@]}")
  fi

  [[ ${#files[@]} -eq 0 ]] && fail "No scripts found"

  timer_start "seven-pillars-validation"

  for file in "${files[@]}"; do
    [[ -f "$file" && -r "$file" ]] || { warn "Skipping unreadable: $file"; continue; }
    validate_file "$file" "$strict" "$explain"
    local status=$?
    (( status > max_exit )) && max_exit=$status
  done

  timer_end

  exit "${max_exit}"
}

main "$@"