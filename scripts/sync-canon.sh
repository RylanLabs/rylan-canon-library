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
MANIFEST_FILE="${MANIFEST_FILE:-${CANON_LIB_PATH}/canon-manifest.yaml}"
AUDIT_LOG_DIR=".audit"
SYNC_TIMESTAMP=$(date +%Y-%m-%dT%H%M%S)
AUDIT_LOG="${AUDIT_LOG_DIR}/sync-deps-${SYNC_TIMESTAMP}.json"

GPG_VERIFY=false
VALIDATE_CASCADE=false
HYBRID_MODE=false

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

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --gpg-verify) GPG_VERIFY=true; shift ;;
            --validate-cascade) VALIDATE_CASCADE=true; shift ;;
            --hybrid) HYBRID_MODE=true; shift ;;
            --canon-path) CANON_LIB_PATH="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
}

check_dependencies() {
    if ! command -v yq &> /dev/null; then
        fail "yq is required for manifest parsing."
    fi
    if [[ "$GPG_VERIFY" == "true" ]] && ! command -v gpg &> /dev/null; then
        fail "gpg is required for GPG verification."
    fi
}

beale_integrity_check() {
    log "Beale Gate: Checking .gitmodules integrity..."
    if [[ -f ".gitmodules" ]]; then
        # Ensure submodules only point to RylanLabs or permitted domains
        local bad_urls
        bad_urls=$(git config --file .gitmodules --get-regexp url | grep -vE "github\.com/(RylanLabs|rylanlabs)") || true
        if [[ -n "$bad_urls" ]]; then
            log "🚨 BEALE GATE VIOLATION: Unauthorized submodule URL detected:"
            echo "$bad_urls"
            exit 1
        fi
        log "✅ Beale Gate: Submodule URLs validated."
    else
        log "Skipping Beale Gate: No .gitmodules found."
    fi
}

verify_gpg_signatures() {
    log "Carter Gate: Verifying submodule signatures..."
    # shellcheck disable=SC2016
    git submodule foreach --quiet '
        if ! git verify-commit HEAD &>/dev/null; then
            echo "🚨 CARTER GATE: Unsigned commit in submodule $name"
            exit 1
        fi
    '
    log "✅ Carter Gate: All submodule signatures verified."
}

validate_cascade() {
    log "Bauer Gate: Validating tier cascade..."
    # Logic: Read canon-manifest.yaml 'dependencies' and ensure they exist in .rylan/
    if [[ ! -f "canon-manifest.yaml" ]]; then
        log "Skipping Cascade Validation: No local canon-manifest.yaml found."
        return
    fi

    local deps
    deps=$(yq -r '.dependencies[] // empty' canon-manifest.yaml)
    for dep in $deps; do
        if [[ ! -d ".rylan/$dep" ]]; then
            log "🚨 BAUER GATE: Missing mandatory dependency: $dep"
            log "   Ensure you have run: git submodule add <url> .rylan/$dep"
            exit 1
        fi
        log "   Verified: $dep inherits from .rylan/$dep"
    done
    log "✅ Bauer Gate: Tier cascade validated."
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

parse_args "$@"
mkdir -p "$AUDIT_LOG_DIR"
log "Starting Canon Synchronization (Audit: $AUDIT_LOG)..."

if [[ ! -d "$CANON_LIB_PATH" ]]; then
    fail "rylan-canon-library not found at $CANON_LIB_PATH. Please clone it or set CANON_LIB_PATH."
fi

check_dependencies

# Integrity and Security Gates
beale_integrity_check

if [[ "$GPG_VERIFY" == "true" ]]; then
    verify_gpg_signatures
fi

if [[ "$VALIDATE_CASCADE" == "true" ]]; then
    validate_cascade
fi

log "Parsing manifest: $MANIFEST_FILE"

# Initialize Audit Data
echo "{\"timestamp\": \"$(date -Iseconds)\", \"files\": []}" > "$AUDIT_LOG"

# Get all ministries from manifest
ministries=$(yq -r '.sacred_files | keys | .[]' "$MANIFEST_FILE")

FILES_SYNCED=0

for ministry in $ministries; do
    log "Processing Ministry: $ministry"
    
    # Iterate through entries for this ministry
    length=$(yq -r ".sacred_files.$ministry | length" "$MANIFEST_FILE")
    for ((i=0; i<length; i++)); do
        src=$(yq -r ".sacred_files.${ministry}[${i}].src" "$MANIFEST_FILE")
        dest=$(yq -r ".sacred_files.${ministry}[${i}].dest" "$MANIFEST_FILE")
        immutable=$(yq -r ".sacred_files.${ministry}[${i}].immutable" "$MANIFEST_FILE")
        
        sync_file "$src" "$dest" "$immutable"
        
        # Add to Bauer Audit Log
        # Use python to safely update JSON
        python3 -c "
import json, sys
data = json.load(open('$AUDIT_LOG'))
data['files'].append({'src': '$src', 'dest': '$dest', 'immutable': $immutable})
with open('$AUDIT_LOG', 'w') as f:
    json.dump(data, f, indent=2)
"
        ((FILES_SYNCED++))
    done
done

# Final Summary in JSON
python3 -c "
import json
data = json.load(open('$AUDIT_LOG'))
data['summary'] = {'files_synced': $FILES_SYNCED, 'status': 'PASS'}
with open('$AUDIT_LOG', 'w') as f:
    json.dump(data, f, indent=2)
"

log "FINAL STATUS: SYNC COMPLETED ($FILES_SYNCED files)."
