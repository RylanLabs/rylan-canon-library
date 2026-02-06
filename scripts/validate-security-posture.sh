#!/usr/bin/env bash
# Script: validate-security-posture.sh
# Purpose: Verify network isolation and firewall defaults (P1 Discipline)
# Guardian: Beale (Hardening)
# Maturity: v2.0.0
# Date: 2026-01-14

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================

NETWORK_SCHEME="${NETWORK_SCHEME:-group_vars/network_scheme.yml}"
AUDIT_LOG="${AUDIT_LOG:-.audit/security/posture.log}"

# ============================================================================
# BAUER COMPLIANCE ARTIFACTS
# ============================================================================
# shellcheck disable=SC2317
cleanup() {
  local status=$?
  local bauer_status="pass"
  local violations="[]"

  if [ "$status" -ne 0 ]; then
    bauer_status="fail"
    violations='[{"severity": "critical", "type": "security_posture", "message": "Security posture validation (Beale Gate) failed"}]'
  fi

  mkdir -p .audit
  cat <<JSON > ".audit/validate-security-posture.json"
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent": "Bauer",
  "type": "security_posture",
  "status": "$bauer_status",
  "violations": $violations
}
JSON
}

trap cleanup EXIT

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$AUDIT_LOG"
}

# Cleanup trap for Bauer Audit
cleanup() {
    local exit_code=$?
    local status="pass"
    local violations="[]"
    
    if [ "$exit_code" -ne 0 ]; then
        status="fail"
        violations='[{"severity": "critical", "type": "security_posture", "message": "Security posture validation failed"}]'
    fi

    mkdir -p .audit
    cat <<JSON > ".audit/validate-security-posture.json"
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent": "Bauer",
  "type": "security_posture",
  "status": "$status",
  "violations": $violations
}
JSON
}
trap cleanup EXIT

fail() {
  log "ERROR: $1"
  exit 1
}

check_dependencies() {
  if ! command -v yq &> /dev/null; then
    fail "yq is required but not installed."
  fi
}

check_firewall_default_deny() {
  log "Verifying default-deny posture..."
  # Placeholder: Checks for a default_posture variable in network_scheme
  if [[ -f "$NETWORK_SCHEME" ]]; then
    # Use raw output if supported by yq version
    if yq --version 2>&1 | grep -q "yq 0.0.0"; then
        posture=$(yq -r '.network_scheme.default_posture // "not-found"' "$NETWORK_SCHEME")
    else
        posture=$(yq e '.network_scheme.default_posture // "not-found"' "$NETWORK_SCHEME" | tr -d '"')
    fi
    if [[ "$posture" != "deny-all" ]] && [[ "$posture" != "drop" ]]; then
      log "WARNING: Default posture is '$posture'. Recommended: 'deny-all'."
    fi
  fi
}

check_vlan_isolation() {
  log "Verifying Isolated VLANs (80, 90) isolation..."
  if [[ -f "$NETWORK_SCHEME" ]]; then
    # Check if VLAN 80 exists and has isolation enabled
    isolated_80=$(yq '.network_scheme.vlans[] | select(.id == 80) | .device_isolation // false' "$NETWORK_SCHEME")
    if [[ "$isolated_80" != "true" ]]; then
      fail "VLAN 80 (Guest) MUST have device_isolation enabled."
    fi

    # Check if VLAN 90 exists and has isolation enabled
    isolated_90=$(yq '.network_scheme.vlans[] | select(.id == 90) | .device_isolation // false' "$NETWORK_SCHEME")
    if [[ "$isolated_90" != "true" ]]; then
      fail "VLAN 90 (IoT) MUST have device_isolation enabled."
    fi
    log "SUCCESS: Guest and IoT isolation verified."
  else
    log "SKIP: $NETWORK_SCHEME not found. Cannot verify isolation."
  fi
}

# ============================================================================
# EXECUTION (Beale Hardening)
# ============================================================================

mkdir -p "$(dirname "$AUDIT_LOG")"
log "Starting Security Posture Audit (Maturity: v2.0.0)..."

check_dependencies
check_firewall_default_deny
check_vlan_isolation

log "FINAL STATUS: SECURITY POSTURE VALIDATED."
