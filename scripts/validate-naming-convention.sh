#!/usr/bin/env bash
# Script: validate-naming-convention.sh
# Purpose: Enforce Kebab-Case Discipline and Tier-based naming conventions
# Guardian: Bauer (Verification) | Ministry: Standards Enforcement
# Maturity: Level 5 (Autonomous)
# Compliance: Hellodeolu v7, Seven Pillars

set -euo pipefail

# --- Configuration ---
# Regex for kebab-case (lowercase, numbers, hyphens only, starting/ending with alphanumeric)
MD_REGEX='^[a-z0-9]+(-[a-z0-9]+)*\.md$'
METRICS_FILE=".audit/metrics.json"
VIOLATIONS_JSON=".audit/naming-violations.json"

# --- Initialization ---
mkdir -p .audit
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
VIOLATION_COUNT=0

log_info() { echo -e "\033[1;36m[INFO]\033[0m $*"; }
log_error() { echo -e "\033[1;31m[FAIL]\033[0m $*"; }

echo "=== Naming Convention Validation (Kebab-Case Discipline) ==="
echo "Repository: $REPO_NAME"

# --- 1. Repository Tier Validation ---
validate_repo_tier() {
    if [ -f "README.md" ]; then
        TIER=$(grep -oP '(?<=\*\*Tier\*\*: )\d+' README.md || echo "UNKNOWN")
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

# --- 2. Markdown Filename Validation (The Duck/Grok Logic) ---
validate_markdown_files() {
    log_info "Validating .md filenames..."
    
    # Discovery: All .md files, excluding hidden dirs, submodules, and transient artifacts
    # We explicitly exclude rylan-labs-common (external repo) and test-satellite (test artifacts)
    FILES=$(find . -maxdepth 4 -name "*.md" \
        -not -path "*/.*" \
        -not -path "./.rylan/*" \
        -not -path "./rylan-labs-common/*" \
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
        
        # NFKC Normalization and Sanitization (PromptPwnd Mitigation)
        # We strip chars that are not alphanumeric, dot, or hyphen
        sanitized=$(echo "$filename" | iconv -f UTF-8 -t UTF-8//TRANSLIT 2>/dev/null | sed 's/[^a-zA-Z0-9.-]//g' || echo "$filename")
        
        if [[ "$filename" != "$sanitized" ]]; then
             log_error "Insecure characters detected: $file"
             ((VIOLATION_COUNT+=1))
             continue
        fi

        if [[ ! "$filename" =~ $MD_REGEX ]]; then
            # Special exceptions for root metadata
            if [[ "$filename" =~ ^(README|CHANGELOG|MESH-MAN)\.md$ ]]; then
                continue
            fi
            
            # Allow common suffixes like .v2.1.0.md for checklists if they follow the pattern
            # But the regex ^[a-z0-9]+(-[a-z0-9]+)*\.md$ is strict. 
            # We'll stick to strict kebab for now as per Raptor's rules.
            
            log_error "Non-compliant naming: $file"
            ((VIOLATION_COUNT+=1))
            
            # Record violation in JSON
            if command -v jq >/dev/null 2>&1; then
                jq --arg path "$file" --arg name "$filename" \
                   '. += [{"path": $path, "filename": $name, "reason": "Not kebab-case"}]' \
                   "$VIOLATIONS_JSON" > "${VIOLATIONS_JSON}.tmp" && mv "${VIOLATIONS_JSON}.tmp" "$VIOLATIONS_JSON"
            fi
        fi
    done
}

# --- 3. Metrics Export ---
export_metrics() {
    if command -v jq >/dev/null 2>&1; then
        jq -n --arg count "$VIOLATION_COUNT" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '{"timestamp": $ts, "naming_violations": ($count | tonumber)}' > "$METRICS_FILE"
    fi
}

validate_repo_tier
validate_markdown_files
export_metrics

if [ "$VIOLATION_COUNT" -gt 0 ]; then
    log_error "Validation failed with $VIOLATION_COUNT naming violations."
    exit 1
fi

log_info "✅ Naming discipline verified."
exit 0
