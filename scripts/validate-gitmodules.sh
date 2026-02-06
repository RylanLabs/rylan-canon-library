#!/usr/bin/env bash
# Script: validate-gitmodules.sh
# Guardian: Beale (Security/Hardening)
# Purpose: Enforce URL allow-listing for Git submodules to prevent supply-chain attacks.
# Compliance: Hellodeolu v7, Beale Gates
# Version: v1.0.0

set -euo pipefail
IFS=$'\n\t'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [BEALE] $1"
}

if [[ ! -f ".gitmodules" ]]; then
    log "No .gitmodules found. Skipping integrity check."
    exit 0
fi

log "Verifying .gitmodules integrity..."

# Define your allow-listed domains/patterns here
# Current canonical policy: ONLY RylanLabs or rylan-labs repositories on GitHub
ALLOW_REGEX="github\.com/(RylanLabs|rylanlabs)"

# Extract URLs from .gitmodules
NON_COMPLIANT_URLS=$(git config --file .gitmodules --get-regexp url | awk '{print $2}' | grep -vE "$ALLOW_REGEX" || true)

if [[ -n "$NON_COMPLIANT_URLS" ]]; then
    log "🚨 BEALE GATE VIOLATION: Unauthorized submodule URLs detected:"
    echo "$NON_COMPLIANT_URLS"
    log "Remediation: Ensure all submodules point to the rylanlabs organization."
    exit 1
fi

log "✅ .gitmodules integrity verified (Allow-list: $ALLOW_REGEX)"
exit 0
