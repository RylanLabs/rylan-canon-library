#!/usr/bin/env bash
# Script: idempotency.sh
# Purpose: Provide secure idempotency, locking, and marker patterns for sourced scripts
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/idempotency.sh"
# Domain: Verification (Idempotency/State) | Hardening (Locking/Reversibility)
# Agent: Bauer | Beale
# Author: rylanlab canonical
# Date: 2025-12-19

set -euo pipefail
IFS=$'\n\t'

#######################################
# Constants
#######################################
readonly LOCK_DIR="${LOCK_DIR:-/var/run/rylan-idempotency}"
readonly MARKER_DIR="${MARKER_DIR:-/var/lib/rylan-markers}"
readonly LOCK_TIMEOUT="${LOCK_TIMEOUT:-300}"  # seconds

# Ensure directories exist with secure permissions
mkdir -p "${LOCK_DIR}" "${MARKER_DIR}" 2>/dev/null || true
chmod 755 "${LOCK_DIR}" "${MARKER_DIR}" 2>/dev/null || true

#######################################
# Atomic lock acquire using mkdir (race-free)
# Arguments:
#   $1 - Lock name (unique identifier)
# Returns:
#   0 if acquired, 1 if already held
# Outputs:
#   Status to stderr, audit if available
#######################################
acquire_lock() {
  local lock_name="$1"
  local lock_path="${LOCK_DIR}/${lock_name}.lock"

  if mkdir "${lock_path}" 2>/dev/null; then
    if declare -F audit_log &>/dev/null; then
      audit_log "LOCK_ACQUIRE" "Idempotency lock taken" "name=${lock_name}"
    fi
    return 0
  else
    if declare -F log_info &>/dev/null; then
      log_info "Lock already held: ${lock_name}"
    fi
    return 1
  fi
}

#######################################
# Release lock
# Arguments:
#   $1 - Lock name
#######################################
release_lock() {
  local lock_name="$1"
  local lock_path="${LOCK_DIR}/${lock_name}.lock"

  if [[ -d "${lock_path}" ]]; then
    rmdir "${lock_path}" 2>/dev/null || true
    if declare -F audit_log &>/dev/null; then
      audit_log "LOCK_RELEASE" "Idempotency lock released" "name=${lock_name}"
    fi
  fi
}

#######################################
# Wait for lock with timeout
# Arguments:
#   $1 - Lock name
#   $2 - Timeout seconds (default: LOCK_TIMEOUT)
# Returns:
#   0 if acquired, 1 on timeout
#######################################
wait_for_lock() {
  local lock_name="$1"
  local timeout="${2:-${LOCK_TIMEOUT}}"
  local elapsed=0
  local interval=5

  while ! acquire_lock "${lock_name}"; do
    sleep ${interval}
    elapsed=$((elapsed + interval))
    if (( elapsed >= timeout )); then
      if declare -F fail &>/dev/null; then
        fail "Timeout waiting for lock: ${lock_name}" 1 "Another instance may be running"
      else
        echo "ERROR: Timeout waiting for lock: ${lock_name}" >&2
        exit 1
      fi
    fi
    if declare -F log_info &>/dev/null; then
      log_info "Waiting for lock... (${elapsed}s/${timeout}s)"
    fi
  done
}

#######################################
# Check if marker exists (simple idempotency)
# Arguments:
#   $1 - Marker name
# Returns:
#   0 if exists (already done), 1 if needs action
#######################################
marker_exists() {
  local marker_name="$1"
  [[ -f "${MARKER_DIR}/${marker_name}.done" ]]
}

#######################################
# Create marker (mark as complete)
# Arguments:
#   $1 - Marker name
#   $2 - Optional details (e.g., version/checksum)
#######################################
create_marker() {
  local marker_name="$1"
  local details="${2:-}"
  local marker_file="${MARKER_DIR}/${marker_name}.done"

  mkdir -p "$(dirname "${marker_file}")"
  echo "${details:-$(date -Iseconds)}" > "${marker_file}"
  chmod 644 "${marker_file}"

  if declare -F audit_log &>/dev/null; then
    audit_log "MARKER_CREATE" "Idempotency marker set" "name=${marker_name} details=${details}"
  fi
}

#######################################
# Remove marker (for rollback/testing)
# Arguments:
#   $1 - Marker name
#######################################
remove_marker() {
  local marker_name="$1"
  local marker_file="${MARKER_DIR}/${marker_name}.done"

  if [[ -f "${marker_file}" ]]; then
    rm -f "${marker_file}"
    if declare -F audit_log &>/dev/null; then
      audit_log "MARKER_REMOVE" "Idempotency marker cleared" "name=${marker_name}"
    fi
  fi
}

#######################################
# Run command only if needed (idempotent wrapper)
# Globals:
#   None
# Arguments:
#   $1 - Lock name
#   $2 - Marker name
#   $3+ - Command to run if needed
# Returns:
#   0 always (success or already done)
#######################################
run_idempotent() {
  local lock_name="$1"
  local marker_name="$2"
  shift 2

  if marker_exists "${marker_name}"; then
    if declare -F log_info &>/dev/null; then
      log_info "Already complete (idempotent): ${marker_name}"
    fi
    return 0
  fi

  if ! acquire_lock "${lock_name}"; then
    if declare -F fail &>/dev/null; then
      fail "Could not acquire lock: ${lock_name}"
    else
      echo "ERROR: Lock held" >&2
      exit 1
    fi
  fi

  trap 'release_lock "${lock_name}"' EXIT

  # Run the action
  "$@"

  create_marker "${marker_name}" "completed by $(basename "$0") at $(date -Iseconds)"

  # Trap will release lock on exit
}

# Silence on source — no output
# Caller uses: run_idempotent "my-op" "config-applied" configure_system

#######################################
# Example Canon Usage (commented)
#######################################
# if run_idempotent "deploy-web" "web-v1.2.0" deploy_web_service; then
#   log_info "Deployment complete or already done"
# fi
