#!/usr/bin/env bash
# Script: audit-logging.sh
# Purpose: Provide structured logging and audit trail functions for sourced scripts
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/audit-logging.sh"  # Silent on success
# Domain: Verification (Audit/Observability)
# Agent: Bauer
# Author: rylanlab canonical
# Date: 2025-12-19

set -euo pipefail
IFS=$'\n\t'

#######################################
# Constants
#######################################
readonly LEVEL_DEBUG=0
readonly LEVEL_INFO=1
readonly LEVEL_WARN=2
readonly LEVEL_ERROR=3

readonly COLOR_RED='\033[0;31m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_NC='\033[0m'

# Configuration (env vars override)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-}"
AUDIT_FILE="${AUDIT_FILE:-}"
NO_COLOR="${NO_COLOR:-false}"  # Force no color if set

#######################################
# Get numeric log level
# Arguments:
#   $1 - Level string (default: INFO)
# Returns:
#   0-3 numeric level
#######################################
get_log_level() {
  local level="${1:-INFO}"
  case "${level^^}" in
    DEBUG)  echo "${LEVEL_DEBUG}" ;;
    INFO)   echo "${LEVEL_INFO}" ;;
    WARN)   echo "${LEVEL_WARN}" ;;
    ERROR)  echo "${LEVEL_ERROR}" ;;
    *)      echo "${LEVEL_INFO}" ;;
  esac
}

#######################################
# Check if should log message
# Arguments:
#   $1 - Message level string
# Returns:
#   0 (true) if should log
#######################################
should_log() {
  local msg_level current_level
  msg_level=$(get_log_level "$1")
  current_level=$(get_log_level "${LOG_LEVEL}")
  (( msg_level >= current_level ))
}

#######################################
# ISO8601 timestamp with seconds
# Outputs:
#   Timestamp string
#######################################
timestamp() {
  date -Iseconds
}

#######################################
# Internal: Write log message
# Globals:
#   None
# Arguments:
#   $1 - Level (INFO|WARN|ERROR|DEBUG)
#   $2+ - Message parts
# Outputs:
#   Formatted message to appropriate stream/file
#######################################
_log_message() {
  local level="$1"
  shift
  local message="$*"
  local ts color output_stream=1

  case "${level}" in
    ERROR|WARN) output_stream=2 color="${COLOR_RED}";;
    DEBUG)              color="${COLOR_BLUE}";;
    INFO)               color="${COLOR_NC}";;
  esac

  [[ "${NO_COLOR}" == "true" ]] && color=""

  local formatted="[$(timestamp)] [${level}] ${message}"

  # Terminal output
  if [[ -t ${output_stream} ]]; then
    echo -e "${color}${formatted}${COLOR_NC}" >&${output_stream}
  else
    echo "${formatted}" >&${output_stream}
  fi

  # File output (append with flock for safety)
  if [[ -n "${LOG_FILE}" ]]; then
    (
      flock 200
      echo "${formatted}"
    ) >> "${LOG_FILE}" 200>"${LOG_FILE}.lock"
  fi
}

#######################################
# Public logging functions
#######################################
log_info()  { should_log INFO  && _log_message INFO  "$@"; }
log_warn()  { should_log WARN  && _log_message WARN  "$@"; }
log_error() { should_log ERROR && _log_message ERROR "$@"; }
log_debug() { should_log DEBUG && _log_message DEBUG "$@"; }

#######################################
# Structured audit entry
# Arguments:
#   $1 - Event type (uppercase)
#   $2 - Description
#   $3+ - Optional key=value context
# Outputs:
#   Audit line to file + INFO log
#######################################
audit_log() {
  local event_type="$1"
  local desc="$2"
  shift 2
  local context="$*"

  local ts user host entry
  ts=$(timestamp)
  user="${USER:-unknown}"
  host="${HOSTNAME:-unknown}"

  entry="[${ts}] [AUDIT] [${event_type}] user=${user} host=${host} action=${desc}"
  [[ -n "${context}" ]] && entry="${entry} ${context}"

  if [[ -n "${AUDIT_FILE}" ]]; then
    (
      flock 200
      echo "${entry}"
    ) >> "${AUDIT_FILE}" 200>"${AUDIT_FILE}.lock"
  fi

  log_info "AUDIT: ${event_type} - ${desc}${context:+ ${context}}"
}

#######################################
# Timer functions (namespaced)
#######################################
_timer_start_time=0
_timer_operation=""

timer_start() {
  local operation="${1:-operation}"
  _timer_start_time=$(date +%s)
  _timer_operation="${operation}"
  log_debug "Timer started: ${operation}"
}

timer_end() {
  local end_time duration
  (( _timer_start_time == 0 )) && return 0
  end_time=$(date +%s)
  duration=$(( end_time - _timer_start_time ))

  log_info "${_timer_operation} completed in ${duration}s"
  audit_log "TIMING" "${_timer_operation}" "duration=${duration}s"

  # Reset
  _timer_start_time=0
  _timer_operation=""
}

# Silence on source — no output
# Trap not needed (caller responsible)

#######################################
# Future Extensions (canon-ready placeholders)
#######################################
# json_log() { ... }  # Structured JSON for aggregation
# rotate_logs() { ... }  # logrotate integration
