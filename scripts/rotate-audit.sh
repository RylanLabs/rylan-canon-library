#!/usr/bin/env bash
# Script: rotate-audit.sh
# Purpose: Rotate, compress, and archive signed audit logs
# Guardian: Bauer (Auditor)
# Maturity: Level 5 (Autonomous)
# Compliance: Pillar 7 (Observability), NIST SP 800-92
# Date: 2026-02-05

set -euo pipefail
IFS=$'\n\t'

# --- Configuration ---
AUDIT_DIR=".audit"
ARCHIVE_DIR="${AUDIT_DIR}/archives/$(date +%Y-%m)"
VAULT_ARCHIVE_ROOT="../rylanlabs-private-vault/audit"
mkdir -p "$ARCHIVE_DIR"

# Threshold: Rotate files older than 7 days
RETENTION_DAYS=${RETENTION_DAYS:-7}
# --- Terminal Styling ---
B_CYAN='\033[1;36m'
B_GREEN='\033[1;32m'
B_YELLOW='\033[1;33m'
B_RED='\033[1;31m'
NC='\033[0m'

log_info() { echo -e "${B_CYAN}[ROTATE]${NC} $1"; }
log_success() { echo -e "${B_GREEN}[SUCCESS]${NC} $1"; }

log_info "Starting audit log rotation (Retention: $RETENTION_DAYS days)"

# 1. Identify candidates (excluding current .jsonl files being appended to)
# We rotate heartbeat files and previous static reports
# current files: audit-trail.jsonl, publish-gate.jsonl (we won't rotate these yet as they are appended to)
# but we can rotate them by renaming them first.

TARGETS=$(find "$AUDIT_DIR" -maxdepth 1 -name "*.jsonl" -o -name "*.json" -mtime +"$RETENTION_DAYS")

if [[ -z "$TARGETS" ]]; then
    log_info "No audit logs meet the rotation threshold."
    exit 0
fi

for file in $TARGETS; do
    filename=$(basename "$file")
    log_info "Archiving $filename..."
    
    # Check for companion signature
    sig="${file}.asc"
    
    # Target directory in Tier 0.5 if available
    VAULT_SUBDIR="${VAULT_ARCHIVE_ROOT}/$(date +%Y-%m)"
    
    # Move to local archive
    mv "$file" "$ARCHIVE_DIR/"
    if [[ -f "$sig" ]]; then
        mv "$sig" "$ARCHIVE_DIR/"
    fi
    
    # Optionally replicate to Tier 0.5 Canonical Anchor
    if [[ -d "$VAULT_ARCHIVE_ROOT" ]]; then
        mkdir -p "$VAULT_SUBDIR"
        cp "$ARCHIVE_DIR/$filename" "$VAULT_SUBDIR/"
        if [[ -f "$ARCHIVE_DIR/${filename}.asc" ]]; then
            cp "$ARCHIVE_DIR/${filename}.asc" "$VAULT_SUBDIR/"
        fi
        log_info "Replicated $filename to Tier 0.5 Vault Anchor."
    fi
    
    # Compress the file (keep signature uncompressed for easier verification if desired)
    # RylanLabs standard: individual compression to maintain per-file provenance
    gzip -f "$ARCHIVE_DIR/$filename"
done

log_success "Audit rotation complete. Archives stored in $ARCHIVE_DIR"

# 2. Cleanup old archives (Retention: 365 days)
MAX_ARCHIVE_AGE=365
find "${AUDIT_DIR}/archives" -mtime +$MAX_ARCHIVE_AGE -type f -delete 2>/dev/null || true

exit 0
