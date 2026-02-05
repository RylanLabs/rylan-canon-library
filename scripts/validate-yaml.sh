#!/usr/bin/env bash
# Script: validate-yaml.sh
# Purpose: ML5 Autonomous YAML Validator (Lint, Audit, Remediate)
# Guardian: Bauer (Auditor)
# Ministry: Configuration Management
# Maturity: Level 5 (Autonomous)
# Author: RylanLabs canonical
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION & AUDIT SETUP
# ============================================================================
AUDIT_DIR=".audit"
AUDIT_FILE="${AUDIT_DIR}/validate-yaml.json"
RAW_AUDIT="${AUDIT_DIR}/yamllint-results.txt"
CANON_LIB_PATH="${CANON_LIB_PATH:-$(pwd)/../rylan-canon-library}"
YAMLLINT_CONFIG="${YAMLLINT_CONFIG:-configs/.yamllint}"
FIX_MODE=false
EXIT_CODE=0
SCANNED_COUNT=0
FAILED_COUNT=0
TARGET_FILES=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

mkdir -p "$AUDIT_DIR"

# shellcheck disable=SC2317
error_handler() {
    local line_no=$1
    local exit_code=$2
    if [ "$exit_code" -ne 0 ] && [ "$exit_code" -ne 123 ]; then
        echo -e "${RED}[FAIL]${NC} Command failed at line ${line_no} with exit code ${exit_code}"
    fi
}
trap 'error_handler $LINENO $?' ERR

# shellcheck disable=SC2317
cleanup() {
    local status=$?
    if [ "$status" -ne 0 ] && [ "$EXIT_CODE" -eq 0 ]; then EXIT_CODE=$status; fi
    
    if [ -f "$RAW_AUDIT" ]; then
        FAILED_COUNT=$(grep -c "^.*:[0-9]\+:[0-9]\+:" "$RAW_AUDIT" || echo "0")
    fi

    cat <<JSON > "$AUDIT_FILE"
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent": "Bauer",
  "scanned_files": "$SCANNED_COUNT",
  "issue_count": "$FAILED_COUNT",
  "exit_code": "$EXIT_CODE",
  "status": "$([ "$EXIT_CODE" -eq 0 ] && echo "PASS" || echo "FAIL")",
  "mode": "$([ "$FIX_MODE" = true ] && echo "remediate" || echo "validate")"
}
JSON
    
    if [ "$EXIT_CODE" -ne 0 ]; then
        echo -e "${RED}❌ Bauer: YAML Validation Failed ($FAILED_COUNT issues). See $AUDIT_FILE${NC}"
    else
        echo -e "${GREEN}✅ Bauer: YAML Validation Passed ($SCANNED_COUNT files checked).${NC}"
    fi
    rm -f "$RAW_AUDIT"
    exit "$EXIT_CODE"
}
trap cleanup EXIT

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
# shellcheck disable=SC2317
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; }
# shellcheck disable=SC2317
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ============================================================================
# PHASE 1: PRE-FLIGHT GATES
# ============================================================================
if [ -f "scripts/whitaker-scan.sh" ]; then bash scripts/whitaker-scan.sh; fi
if [ -f "scripts/sentinel-expiry.sh" ]; then bash scripts/sentinel-expiry.sh; fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix) FIX_MODE=true; shift ;;
        *) TARGET_FILES+=("$1"); shift ;;
    esac
done

if ! command -v yamllint > /dev/null 2>&1; then echo "yamllint missing"; exit 1; fi

# ============================================================================
# PHASE 2: DISCOVERY & CONFIG
# ============================================================================
if [[ ! -f "$YAMLLINT_CONFIG" ]]; then
    if [[ -f "$CANON_LIB_PATH/configs/.yamllint" ]]; then
        YAMLLINT_CONFIG="$CANON_LIB_PATH/configs/.yamllint"
    elif [[ -f "../rylan-canon-library/configs/.yamllint" ]]; then
        YAMLLINT_CONFIG="../rylan-canon-library/configs/.yamllint"
    else
        YAMLLINT_CONFIG="default"
    fi
fi

if [ ${#TARGET_FILES[@]} -eq 0 ]; then
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        readarray -t STAGED < <(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.ya?ml$' || true)
        if [ ${#STAGED[@]} -gt 0 ]; then
            TARGET_FILES=("${STAGED[@]}")
        else
            readarray -t TRACKED < <(git ls-files | grep -E '\.ya?ml$' || true)
            CLEAN_TRACKED=()
            for f in "${TRACKED[@]}"; do [[ -f "$f" ]] && CLEAN_TRACKED+=("$f"); done
            TARGET_FILES=("${CLEAN_TRACKED[@]}")
        fi
    fi
    if [ ${#TARGET_FILES[@]} -eq 0 ]; then
        readarray -t ALL < <(find . -maxdepth 5 -regextype posix-extended -regex ".*\.ya?ml" -not -path "*/.git/*" || true)
        TARGET_FILES=("${ALL[@]}")
    fi
fi

SCANNED_COUNT=${#TARGET_FILES[@]}
if [ "$SCANNED_COUNT" -eq 0 ]; then exit 0; fi

# ============================================================================
# PHASE 3: VALIDATION & REMEDIATION
# ============================================================================
if [ "$FIX_MODE" = true ]; then
    log_info "🩹 Lazarus: Pre-processing files..."
    for FILE in "${TARGET_FILES[@]}"; do
        if [ -f "$FILE" ]; then
            sed -i 's/[[:space:]]*$//' "$FILE"
            if [ -n "$(tail -c 1 "$FILE" 2>/dev/null)" ]; then echo "" >> "$FILE"; fi
        fi
    done
fi

YAMLLINT_ARGS=(-c "$YAMLLINT_CONFIG" -f parsable)
if [[ "$YAMLLINT_CONFIG" == "default" ]]; then YAMLLINT_ARGS=(-f parsable); fi

printf "%s\n" "${TARGET_FILES[@]}" | xargs -r yamllint "${YAMLLINT_ARGS[@]}" > "$RAW_AUDIT" || EXIT_CODE=$?

if [ "$EXIT_CODE" -ne 0 ]; then
    cat "$RAW_AUDIT"
fi

if [ $EXIT_CODE -ne 0 ] && [ "$FIX_MODE" = true ]; then
    log_info "🩹 Lazarus: Attempting second pass..."
    if printf "%s\n" "${TARGET_FILES[@]}" | xargs -r yamllint "${YAMLLINT_ARGS[@]}" &>/dev/null; then
        EXIT_CODE=0
    fi
fi

exit "$EXIT_CODE"
