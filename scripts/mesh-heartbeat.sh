#!/usr/bin/env bash
# Script: mesh-heartbeat.sh
# Purpose: Generate GPG-signed heartbeat attestations for Zero Trust mesh health
# Guardian: Carter (Identity), Bauer (Verification)
# Maturity: Level 5 (Autonomous)
# Compliance: NIST SP 800-92, Hellodeolu v7, Zero Trust Posture
# Date: 2026-02-05

set -euo pipefail
IFS=$'\n\t'

# --- Configuration ---
AUDIT_DIR=".audit"
mkdir -p "$AUDIT_DIR"
HEARTBEAT_LOG="${AUDIT_DIR}/heartbeat.jsonl"
IDENTITY_EMAIL=${IDENTITY_EMAIL:-security@rylan.local}

# --- Terminal Styling ---
B_CYAN='\033[1;36m'
B_GREEN='\033[1;32m'
B_YELLOW='\033[1;33m'
B_RED='\033[1;31m'
NC='\033[0m'

log_info() { echo -e "${B_CYAN}[HEARTBEAT]${NC} $1"; }
log_success() { echo -e "${B_GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${B_YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${B_RED}[FAILURE]${NC} $1" >&2; }

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --tag          Create a signed Git tag as a mesh pulse"
    echo "  --verify       Verify the existing heartbeat signatures"
    echo "  --identity EMAIL  Override the signing identity (default: security@rylan.local)"
    exit 2
}

# --- Arguments ---
CREATE_TAG=false
VERIFY_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag) CREATE_TAG=true; shift ;;
        --verify) VERIFY_MODE=true; shift ;;
        --identity) IDENTITY_EMAIL="$2"; shift 2 ;;
        *) usage ;;
    esac
done

# --- Verification Mode ---
if [[ "$VERIFY_MODE" == "true" ]]; then
    log_info "Verifying heartbeat signatures..."
    SIG_FILES=$(find "$AUDIT_DIR" -maxdepth 1 -name "heartbeat-*.jsonl.asc")
    if [[ -z "$SIG_FILES" ]]; then
        log_error "No heartbeat signatures found."
        exit 1
    fi
    
    FAIL=0
    for sig in $SIG_FILES; do
        payload="${sig%.asc}"
        if gpg --verify "$sig" "$payload" >/dev/null 2>&1; then
            log_success "Verified: $(basename "$payload")"
        else
            log_error "TAMPER DETECTION: Signature mismatch in $(basename "$payload")"
            FAIL=1
        fi
    done
    exit "$FAIL"
fi

# --- Heartbeat Generation ---
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TS_FILE=$(date -u +"%Y%m%d-%H%M%S")
REPO_HASH=$(git rev-parse --verify HEAD 2>/dev/null || echo "unknown")
GATE_STATUS="GREEN"

# Detect environment
RUNNER="local"
[[ "${CI:-}" == "true" ]] && RUNNER="ci"

log_info "Generating signed pulse (Identity: $IDENTITY_EMAIL)"

# Build heartbeat JSON
HB_FILE="${AUDIT_DIR}/heartbeat-${TS_FILE}.jsonl"
if ! command -v jq >/dev/null 2>&1; then
    log_error "jq not found; required for heartbeat generation."
    exit 1
fi

jq -n \
    --arg ts "$TS" \
    --arg hash "$REPO_HASH" \
    --arg id "$IDENTITY_EMAIL" \
    --arg run "$RUNNER" \
    --arg sts "$GATE_STATUS" \
    '{"timestamp": $ts, "repo_hash": $hash, "identity": $id, "runner": $run, "status": $sts, "version": "v1.0.0"}' \
    > "$HB_FILE"

# GPG Signing (Armored Detached Signature)
if ! gpg --armor --local-user "$IDENTITY_EMAIL" --detach-sign --output "${HB_FILE}.asc" "$HB_FILE" 2>/dev/null; then
    log_warn "Standard GPG signing failed (No YubiKey/Password?). Attempting best-effort signing..."
    # Fallback to signing with default key if identity match fails
    if ! gpg --armor --detach-sign --output "${HB_FILE}.asc" "$HB_FILE"; then
        log_error "Cryptographic signing failed. Zero Trust Posture violated."
        exit 1
    fi
fi

log_success "Pulse recorded: $(basename "$HB_FILE") (Signature created)"

# --- Git Pulse (Optional) ---
if [[ "$CREATE_TAG" == "true" ]]; then
    log_info "Pulsing mesh with signed tag..."
    TAG_NAME="mesh-heartbeat-$(date +%G.%V.%u)"
    if git tag -s "$TAG_NAME" -m "Mesh heartbeat pulse: $TS" --force; then
        log_success "Signed tag created: $TAG_NAME"
    else
        log_error "Git tag signing failed. Ensure GPG_TTY is set or key is unlocked."
        exit 1
    fi
fi

exit 0
