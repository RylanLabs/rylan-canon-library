#!/usr/bin/env bash
# Script: sync-canon.sh
# Purpose: Synchronize local repository with Tier 0 Canon (rylan-canon-library)
# Guardian: Carter (Identity/Bootstrap)
# Maturity: v2.0.0
# Date: 2026-01-14

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================

CANON_LIB_PATH="${CANON_LIB_PATH:-$(pwd)/../rylan-canon-library}"
MANIFEST_FILE="$CANON_LIB_PATH/canon-manifest.yaml"
AUDIT_LOG=".audit/canon/sync.log"

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

fail() {
    log "ERROR: $1"
    exit 1
}

check_dependencies() {
    if ! command -v yq &> /dev/null; then
        fail "yq is required for manifest parsing."
    fi
}

sync_file() {
    local src="$1"
    local dest="$2"
    local immutable="$3"

    local src_full
    src_full="$CANON_LIB_PATH/$src"
    local dest_full
    dest_full="$(pwd)/$dest"

    if [[ ! -f "$src_full" ]]; then
        log "WARNING: Source file missing from library: $src"
        return
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$dest_full")"

    # Handle symlinking
    if [[ -L "$dest_full" ]]; then
        rm "$dest_full"
    elif [[ -f "$dest_full" ]]; then
        if [[ "$immutable" == "true" ]]; then
            log "REPLACING immutable file: $dest"
            rm "$dest_full"
        else
            log "SKIPPING existing customizable file: $dest (use manual update)"
            return
        fi
    fi

    ln -s "$src_full" "$dest_full"
    log "LINKED: $dest -> $src"
}

# ============================================================================
# EXECUTION
# ============================================================================

mkdir -p "$(dirname "$AUDIT_LOG")"
log "Starting Canon Synchronization..."

if [[ ! -d "$CANON_LIB_PATH" ]]; then
    fail "rylan-canon-library not found at $CANON_LIB_PATH. Please clone it or set CANON_LIB_PATH."
fi

check_dependencies

# Parse manifest and sync files by ministry
# Note: In a real environment, ministries would be filtered by repo declaration
log "Parsing manifest: $MANIFEST_FILE"

# Get all ministries from manifest
ministries=$(yq -r '.sacred_files | keys | .[]' "$MANIFEST_FILE")

for ministry in $ministries; do
    log "Processing Ministry: $ministry"
    
    # Iterate through entries for this ministry
    length=$(yq -r ".sacred_files.$ministry | length" "$MANIFEST_FILE")
    for ((i=0; i<length; i++)); do
        src=$(yq -r ".sacred_files.${ministry}[${i}].src" "$MANIFEST_FILE")
        dest=$(yq -r ".sacred_files.${ministry}[${i}].dest" "$MANIFEST_FILE")
        immutable=$(yq -r ".sacred_files.${ministry}[${i}].immutable" "$MANIFEST_FILE")
        
        sync_file "$src" "$dest" "$immutable"
    done
done

log "FINAL STATUS: SYNC COMPLETED."
