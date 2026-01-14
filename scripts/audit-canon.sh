#!/usr/bin/env bash
# Script: audit-canon.sh
# Purpose: Detect drift between local repo and Tier 0 Canon
# Guardian: Bauer (Auditor)
# Maturity: v2.0.0
# Date: 2026-01-14

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================

CANON_LIB_PATH="${CANON_LIB_PATH:-$(pwd)/../rylan-canon-library}"
MANIFEST_FILE="$CANON_LIB_PATH/canon-manifest.yaml"
AUDIT_LOG=".audit/canon/drift.log"

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$AUDIT_LOG"
}

fail() {
    log "ERROR: $1"
    exit 1
}

check_drift() {
    local src="$1"
    local dest="$2"
    local immutable="$3"

    local src_full
    src_full="$CANON_LIB_PATH/$src"
    local dest_full
    dest_full="$(pwd)/$dest"

    if [[ ! -f "$dest_full" ]]; then
        log "[MISSING] $dest"
        return 1
    fi

    if [[ "$immutable" == "true" ]]; then
        # Check if it's a symlink or if the content matches
        if [[ ! -L "$dest_full" ]]; then
            # If not a symlink, check checksums
            src_sum=$(sha256sum "$src_full" | cut -d' ' -f1)
            dest_sum=$(sha256sum "$dest_full" | cut -d' ' -f1)
            
            if [[ "$src_sum" != "$dest_sum" ]]; then
                log "[DRIFTED] $dest (Content mismatch)"
                return 1
            fi
        fi
    fi

    return 0
}

# ============================================================================
# EXECUTION
# ============================================================================

mkdir -p "$(dirname "$AUDIT_LOG")"
log "Starting Canon Drift Audit..."

if [[ ! -d "$CANON_LIB_PATH" ]]; then
    fail "rylan-canon-library not found at $CANON_LIB_PATH."
fi

drift_detected=0
ministries=$(yq -r '.sacred_files | keys | .[]' "$MANIFEST_FILE")

for ministry in $ministries; do
    length=$(yq -r ".sacred_files.${ministry} | length" "$MANIFEST_FILE")
    for ((i=0; i<length; i++)); do
        src=$(yq -r ".sacred_files.${ministry}[${i}].src" "$MANIFEST_FILE")
        dest=$(yq -r ".sacred_files.${ministry}[${i}].dest" "$MANIFEST_FILE")
        immutable=$(yq -r ".sacred_files.${ministry}[${i}].immutable" "$MANIFEST_FILE")
        
        if ! check_drift "$src" "$dest" "$immutable"; then
            drift_detected=1
        fi
    done
done

if [[ "$drift_detected" -eq 1 ]]; then
    fail "Drift detected in Sacred files. Run sync-canon.sh to remediate."
fi

log "FINAL STATUS: CANON COMPLIANT."
