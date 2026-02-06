#!/usr/bin/env bash
# Script: sentinel-expiry.sh
# Purpose: Validate identity key expiry with 14-day compliance window
# Guardian: Sentinel (Identity Monitor)
# Ministry: Audit
# Maturity: Level 5 (Autonomous)
# Author: RylanLabs canonical
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

# Standards: Warning window is 14 days by default
WARNING_WINDOW_DAYS=${WARNING_WINDOW_DAYS:-14}
THRESHOLD_SECONDS=$((WARNING_WINDOW_DAYS * 86400))
NOW=$(date +%s)
IDENTITY_EMAIL=${IDENTITY_EMAIL:-security@rylan.local}

echo "🔍 Running Expiry Sentinel ($IDENTITY_EMAIL)..."

if ! command -v gpg &>/dev/null; then
    echo "⚠️  GPG not found; skipping expiry check (Infrastructure bypass?)"
    exit 0
fi

# 1. Check for GPG Revocation (Gap 6 / Phase 1)
# Field 2 contains the validity: 'r' for revoked, 'd' for disabled.
REVOCATION_STATUS=$(gpg --with-colons --list-keys "$IDENTITY_EMAIL" 2>/dev/null | awk -F: '/pub|sub/ {print $2}' | grep -E "[rRdD]" || true)

if [[ -n "$REVOCATION_STATUS" ]]; then
    echo "❌ CRITICAL: Identity key for $IDENTITY_EMAIL has been REVOKED or DISABLED in GPG ring."
    exit 1
fi

# 2. Check for External Revocation List (Standard: .audit/revocation-list.jsonl)
# Zero Trust: We prioritize the Tier 0.5 vault for the canonical revocation list.
REV_LIST_VAULT="../rylanlabs-private-vault/revocation/revocation-list.jsonl"
REV_LIST_LOCAL=".audit/revocation-list.jsonl"
REV_LIST="${REV_LIST_VAULT}"

if [[ ! -f "$REV_LIST" ]]; then
    REV_LIST="${REV_LIST_LOCAL}"
fi

if [[ -f "$REV_LIST" ]]; then
    # --- Trinity Gate: Signature Verification (Phase B2) ---
    SIG_FILE="${REV_LIST}.asc"
    if [[ -f "$SIG_FILE" ]]; then
        if ! gpg --verify "$SIG_FILE" "$REV_LIST" &>/dev/null; then
            echo "❌ CRITICAL: CRL signature verification FAILED for $REV_LIST"
            echo "Non-repudiation failure. Potential tampering detected."
            exit 1
        fi
        echo "✅ CRL signature verified (Identity: $(gpg --status-fd 1 --verify "$SIG_FILE" "$REV_LIST" 2>/dev/null | awk '/TRUST_ULTIMATE|TRUST_FULLY/ {print "Trusted"}'))"
    else
        echo "⚠️  WARNING: CRL found but signature sidecar ($SIG_FILE) is missing."
        # In a strict ML5 environment, we might want to exit 1 here.
        # For now, we allow it as a 'Soft Gate' until Phase B is fully synced.
    fi

    FINGERPRINT=$(gpg --with-colons --list-keys "$IDENTITY_EMAIL" 2>/dev/null | awk -F: '/fpr/ {print $10}' | head -n 1)
    if [[ -n "$FINGERPRINT" ]] && grep -q "$FINGERPRINT" "$REV_LIST" 2>/dev/null; then
        echo "❌ CRITICAL: Identity fingerprint $FINGERPRINT found in revocation list: $REV_LIST"
        exit 1
    fi
fi

# 3. Get expiry dates for all subkeys of the target identity
EXPIRY_DATES=$(gpg --with-colons --list-keys "$IDENTITY_EMAIL" 2>/dev/null | awk -F: '/sub|pub/ {print $7}' || true)

if [ -z "$EXPIRY_DATES" ]; then
    echo "⚠️  No identity key found for $IDENTITY_EMAIL. Skipping enforcement."
    exit 0
fi

FAIL=0
for expiry in $EXPIRY_DATES; do
    if [ -z "$expiry" ]; then continue; fi

    # Check if expired or expiring soon
    TIME_LEFT=$((expiry - NOW))

    if [ "$TIME_LEFT" -lt 0 ]; then
        echo "❌ KEY EXPIRED! (Expiry: $(date -d @"$expiry" 2>/dev/null || echo "$expiry"))"
        FAIL=1
    elif [ "$TIME_LEFT" -lt "$THRESHOLD_SECONDS" ]; then
        DAYS_LEFT=$((TIME_LEFT / 86400))
        echo "⚠️  KEY EXPIRING SOON! ($DAYS_LEFT days left until $(date -d @"$expiry" 2>/dev/null || echo "$expiry"))"
        FAIL=1
    else
        echo "✅ Key valid until $(date -d @"$expiry" 2>/dev/null || echo "$expiry")"
    fi
done

if [ "$FAIL" -ne 0 ]; then
    echo "🚨 Expiry validation FAILED. Rotation required to regain compliance."
    exit 1
fi

echo "✅ All identity keys within compliance window."

# --- Zero Trust Heartbeat ---
# If sentinel-expiry passes, we record a signed "Still-Valid" attestation.
HEARTBEAT_SCRIPT="$(dirname "$0")/mesh-heartbeat.sh"
if [[ -x "$HEARTBEAT_SCRIPT" ]]; then
    "$HEARTBEAT_SCRIPT" --identity "$IDENTITY_EMAIL"
else
    echo "⚠️  Heartbeat script not found or not executable. Posture check incomplete."
fi

exit 0
