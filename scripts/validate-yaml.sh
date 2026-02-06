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
    
    local violations="[]"
    local crit_count=0
    local warn_count=0

    if [ -f "$RAW_AUDIT" ]; then
        crit_count=$(grep -c " \[error\] " "$RAW_AUDIT" || true)
        warn_count=$(grep -c " \[warning\] " "$RAW_AUDIT" || true)
        
        # Ensure they are integers (handle empty strings if any)
        crit_count=${crit_count:-0}
        warn_count=${warn_count:-0}
        
        if [ "$crit_count" -gt 0 ]; then
             violations="[{\"severity\": \"critical\", \"type\": \"yaml_lint\", \"message\": \"$crit_count YAML errors detected\"}]"
        elif [ "$warn_count" -gt 0 ]; then
             violations="[{\"severity\": \"warning\", \"type\": \"yaml_lint\", \"message\": \"$warn_count YAML warnings detected\"}]"
        fi
        FAILED_COUNT=$((crit_count + warn_count))
    elif [ "$EXIT_CODE" -ne 0 ]; then
        violations="[{\"severity\": \"critical\", \"type\": \"yaml_error\", \"message\": \"YAML validator failed with exit code $EXIT_CODE\"}]"
        crit_count=1
    fi

    # Bauer Compliance: If there are critical errors, status is fail. 
    # If only warnings, status can be pass (for now).
    local bauer_status="pass"
    if [ "$crit_count" -gt 0 ]; then
        bauer_status="fail"
    fi

    cat <<JSON > "$AUDIT_FILE"
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent": "Bauer",
  "scanned_files": $SCANNED_COUNT,
  "critical_count": $crit_count,
  "warning_count": $warn_count,
  "exit_code": $EXIT_CODE,
  "status": "$bauer_status",
  "mode": "$([ "$FIX_MODE" = true ] && echo "remediate" || echo "validate")",
  "violations": $violations
}
JSON
    
    if [ "$bauer_status" = "fail" ]; then
        echo -e "${RED}❌ Bauer: YAML Validation Failed ($crit_count errors). See $AUDIT_FILE${NC}"
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
