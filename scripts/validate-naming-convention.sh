#!/usr/bin/env bash
# Script: validate-naming-convention.sh
# Purpose: Enforce Kebab-Case Discipline and Tier-based naming conventions
# Guardian: Bauer (Verification) | Ministry: Standards Enforcement
# Maturity: Level 5 (Autonomous)
# Compliance: Hellodeolu v7, Seven Pillars

set -euo pipefail

# --- Configuration ---
MD_REGEX='^[a-z0-9]+(-[a-z0-9]+)*\.md$'
SH_REGEX='^[a-z0-9]+(-[a-z0-9]+)*\.sh$'
PY_REGEX='^[a-z0-9]+(_[a-z0-9]+)*\.py$'

METRICS_FILE=".audit/metrics.json"
ISO_DATE=$(date +%Y%m%d)
VIOLATIONS_JSON=".audit/naming-violations-${ISO_DATE}.json"
# Symlink current violations for audit script
LATEST_VIOLATIONS=".audit/naming-violations.json"

# --- Initialization ---
mkdir -p .audit
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
VIOLATION_COUNT=0
declare -A SEEN_LOWERCASE

log_info() { echo -e "\033[1;36m[INFO]\033[0m $*"; }
log_error() { echo -e "\033[1;31m[FAIL]\033[0m $*"; }

echo "=== Naming Convention Validation (Canonical Discipline) ==="
echo "Repository: $REPO_NAME"

# --- 1. Repository Tier Validation ---
validate_repo_tier() {
    if [ -f "README.md" ]; then
        TIER=$(grep -oP '(?<=\*\*Tier\*\*: )\d+(\.\d+)?' README.md || echo "UNKNOWN")
        case "$TIER" in
            0) EXPECTED="^rylan-canon-library$" ;;
            0.5) EXPECTED="^rylanlabs-.*-vault$" ;;
            1) EXPECTED="^rylan-inventory$" ;;
            2) EXPECTED="^rylan-labs-.*-configs$" ;;
            3) EXPECTED="^rylan-labs-common$" ;;
            4) 
                if [[ "$REPO_NAME" =~ ^rylan-labs- ]] || [[ "$REPO_NAME" =~ ^rylanlabs- ]]; then
                    log_info "✓ Repo naming valid for Tier 4."
                    return 0
                fi
                EXPECTED="^rylan-labs-.*|^rylanlabs-.*"
                ;;
            *) EXPECTED="^rylan-.*|^rylanlabs-.*" ;;
        esac

        if [[ ! "$REPO_NAME" =~ $EXPECTED ]]; then
            log_error "Repo '$REPO_NAME' does not match Tier $TIER pattern '$EXPECTED'."
            ((VIOLATION_COUNT+=1))
        else
            log_info "✓ Repo naming valid for Tier $TIER."
        fi
    fi
}

# --- 2. Advanced Discipline Validation (.md, .sh, .py) ---
validate_file_naming() {
    log_info "Validating mesh-wide filenames..."
    
    # Discovery: .md, .sh, .py excluding hidden dirs and transient artifacts
    FILES=$(find . -maxdepth 4 \( -name "*.md" -o -name "*.sh" -o -name "*.py" \) \
        -not -path "*/.*" \
        -not -path "./.rylan/*" \
        -not -path "./test-satellite/*" \
        -not -path "./.tmp/*" \
        -not -path "./.pytest_cache/*" \
        -not -path "./builds/*" \
        -not -path "*/node_modules/*" \
        -not -path "*/venv/*" \
        -not -path "*/.venv/*")
    
    echo "[]" > "$VIOLATIONS_JSON"

    for file in $FILES; do
        filename=$(basename "$file")
        ext="${filename##*.}"
        
        # NFKC Normalization Check (Python helper for reliability)
        if ! python3 -c "import sys, unicodedata; f='$filename'; sys.exit(0 if unicodedata.is_normalized('NFKC', f) else 1)" 2>/dev/null; then
             log_error "Unicode normalization (NFKC) violation: $file"
             ((VIOLATION_COUNT+=1))
             continue
        fi

        # Case-insensitive collision detection
        lower_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
        if [[ -n "${SEEN_LOWERCASE[$lower_name]:-}" && "${SEEN_LOWERCASE[$lower_name]}" != "$filename" ]]; then
            log_error "Case-insensitive collision detected: $file conflicts with ${SEEN_LOWERCASE[$lower_name]}"
            ((VIOLATION_COUNT+=1))
            continue
        fi
        SEEN_LOWERCASE[$lower_name]="$filename"

        # Regex Validation
        valid=true
        case "$ext" in
            md) 
                if [[ ! "$filename" =~ $MD_REGEX ]]; then
                    if [[ ! "$filename" =~ ^(README|CHANGELOG|MESH-MAN)\.md$ ]]; then
                        valid=false
                        reason="Not kebab-case (MD)"
                    fi
                fi
                ;;
            sh)
                if [[ ! "$filename" =~ $SH_REGEX ]]; then
                    valid=false
                    reason="Not kebab-case (SH)"
                fi
                ;;
            py)
                if [[ ! "$filename" =~ $PY_REGEX ]]; then
                    if [[ ! "$filename" =~ ^(__init__|test_.*)\.py$ ]]; then
                        valid=false
                        reason="Not snake_case (PY)"
                    fi
                fi
                ;;
        esac

        if [ "$valid" = false ]; then
            log_error "Non-compliant naming: $file [Reason: $reason]"
            ((VIOLATION_COUNT+=1))
            
            # Record violation in JSON
            if command -v jq >/dev/null 2>&1; then
                jq --arg path "$file" --arg name "$filename" --arg r "$reason" \
                   '. += [{"path": $path, "filename": $name, "reason": $r}]' \
                   "$VIOLATIONS_JSON" > "${VIOLATIONS_JSON}.tmp" && mv "${VIOLATIONS_JSON}.tmp" "$VIOLATIONS_JSON"
            fi
        fi
    done
    ln -sf "$(basename "$VIOLATIONS_JSON")" "$LATEST_VIOLATIONS"
}
            
# --- 3. Metrics Export ---
export_metrics() {
    if command -v jq >/dev/null 2>&1; then
        jq -n --arg count "$VIOLATION_COUNT" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '{"timestamp": $ts, "naming_violations": ($count | tonumber)}' > "$METRICS_FILE"
    fi
}

validate_repo_tier
validate_file_naming
export_metrics

if [ "$VIOLATION_COUNT" -gt 0 ]; then
    log_info "Audit file: $VIOLATIONS_JSON"
    log_error "Validation failed with $VIOLATION_COUNT naming violations."
    exit 1
fi

log_info "✅ Naming discipline verified."
exit 0
