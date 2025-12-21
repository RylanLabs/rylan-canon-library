#!/usr/bin/env bash
# Script: validate-bash.sh
# Purpose: Bash validation orchestrator (ShellCheck + shfmt) with canonical exclusions
# Guardian: Holy Scholar 📜
# Author: rylanlab canonical
# Date: 2025-12-21
# Ministry: ministry-whispers
# Tag: bash-validator
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SCRIPT_DIR REPO_ROOT

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════
readonly SHELLCHECK_ARGS=(-x -S style)
readonly SHFMT_ARGS=(-i 2 -ci)
EXIT_CODE=0
FIX_MODE=false

# Parse arguments
[[ "${1:-}" == "--fix" ]] && FIX_MODE=true

# Canonical exclusion patterns (Hellodeolu v6 backup structure)
readonly EXCLUDE_PATTERNS=(
  "*/.backups/*"
  "*/.backup*/*"
  "*/backup/*"
  "*/node_modules/*"
  "*/.git/*"
  "*/.venv/*"
  "*/venv/*"
)

# ═══════════════════════════════════════════════════════════════════════════
# LOGGING (Trinity Pattern: Bauer Audit Trail)
# ═══════════════════════════════════════════════════════════════════════════
log() {
  local msg_temp
  msg_temp="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  printf '%s\n' "${msg_temp}"
  printf '%s\n' "${msg_temp}" >>"${AUDIT_LOG}"
}

log_pass() {
  log "✓ $*"
}

log_fail() {
  log "✗ $*"
}

log_warn() {
  log "⚠ $*"
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN VALIDATION
# ═══════════════════════════════════════════════════════════════════════════
main() {
  # Audit logging
  mkdir -p "${REPO_ROOT}/.audit"
  local audit_log_temp shellcheck_log_temp shfmt_log_temp
  audit_log_temp="${REPO_ROOT}/.audit/bash-validation-$(date +%Y%m%d-%H%M%S).log"
  shellcheck_log_temp="${REPO_ROOT}/.audit/shellcheck-$(date +%Y%m%d-%H%M%S).log"
  shfmt_log_temp="${REPO_ROOT}/.audit/shfmt-$(date +%Y%m%d-%H%M%S).log"
  readonly AUDIT_LOG="$audit_log_temp"
  readonly SHELLCHECK_LOG="$shellcheck_log_temp"
  readonly SHFMT_LOG="$shfmt_log_temp"

  local START_TIME
  START_TIME=$(date +%s)

  log "════════════════════════════════════════════════════════════════"
  log "  BASH CANON VALIDATION — ShellCheck + shfmt (T3-ETERNAL v∞.5.2)"
  log "  Mode: $([[ ${FIX_MODE} == true ]] && echo "FIX" || echo "CHECK")"
  log "════════════════════════════════════════════════════════════════"

  # Allow collection of all failures without aborting on first one
  set +e

  # Build find exclusion arguments
  local find_args=()
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    find_args+=(-not -path "${pattern}")
  done

  # Find all bash scripts (shebang #!/usr/bin/env bash or #!/bin/bash)
  local bash_scripts
  bash_scripts=$(find "${REPO_ROOT}" -type f \
    \( -name "*.sh" -o -path "*/scripts/*" \) \
    "${find_args[@]}" \
    -exec grep -l "^#!/.*bash" {} \; 2>/dev/null | sort -u)

  if [[ -z "${bash_scripts}" ]]; then
    log_warn "No bash scripts found"
    set -e
    return 0
  fi

  # Count stats
  local total_scripts=0
  local passed_scripts=0
  local failed_scripts=0

  # Validate each script
  while IFS= read -r script; do
    ((total_scripts++))
    local script_name="${script#"${REPO_ROOT}"/}"
    local script_failed=0

    # ShellCheck validation (exit 0 = pass, exit 1+ = fail)
    local shellcheck_out
    shellcheck_out=$(shellcheck "${SHELLCHECK_ARGS[@]}" "${script}" 2>&1) || true

    if [[ -z "${shellcheck_out}" ]]; then
      log_pass "ShellCheck: ${script_name}"
    else
      log_fail "ShellCheck: ${script_name}"
      echo "${shellcheck_out}" | tee -a "${SHELLCHECK_LOG}"
      script_failed=1
      EXIT_CODE=1
    fi

    # shfmt check (exit 0 = no changes, exit 1 = changes needed)
    if [[ ${FIX_MODE} == true ]]; then
      shfmt "${SHFMT_ARGS[@]}" -w "${script}" 2>&1 | tee -a "${SHFMT_LOG}" || true
      log_pass "shfmt fixed: ${script_name}"
    else
      local shfmt_out
      shfmt_out=$(shfmt "${SHFMT_ARGS[@]}" -d "${script}" 2>&1) || true

      if [[ -z "${shfmt_out}" ]]; then
        log_pass "shfmt format: ${script_name}"
      else
        log_fail "shfmt format issue: ${script_name}"
        # Truncate large diffs to prevent hang / huge stdout; full output appended to log
        printf '%s\n' "${shfmt_out}" | head -n 20 | tee -a "${SHFMT_LOG}"
        if [[ $(wc -c <<<"${shfmt_out}") -gt 4096 ]]; then
          printf '  [... diff truncated, see %s for full output]\n' "${SHFMT_LOG}" | tee -a "${SHFMT_LOG}"
        fi
        script_failed=1
        EXIT_CODE=1
      fi
    fi

    # Count script pass/fail once
    if [[ ${script_failed} -eq 0 ]]; then
      ((passed_scripts++))
    else
      ((failed_scripts++))
    fi
  done <<<"${bash_scripts}"

  # RTO calculation
  local END_TIME
  END_TIME=$(date +%s)
  local RTO=$((END_TIME - START_TIME))

  # Summary
  log ""
  log "════════════════════════════════════════════════════════════════"
  log "BASH VALIDATION SUMMARY"
  log "  Total scripts: ${total_scripts}"
  log "  Passed: ${passed_scripts}"
  log "  Failed: ${failed_scripts}"
  log "  RTO: ${RTO}s"
  log "  Audit log: ${AUDIT_LOG}"
  log "════════════════════════════════════════════════════════════════"

  if [[ ${EXIT_CODE} -eq 0 ]]; then
    log_pass "ALL BASH SCRIPTS VALID"
  else
    log_fail "BASH VALIDATION FAILED"
    log "  ShellCheck errors: ${SHELLCHECK_LOG}"
    log "  shfmt issues: ${SHFMT_LOG}"
  fi

  # Restore strict mode and return aggregated status
  set -e
  return ${EXIT_CODE}
}

# Trap handler
trap 'log "Validation interrupted"; exit 130' INT TERM

main "$@"
