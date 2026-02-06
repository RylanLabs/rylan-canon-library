#!/usr/bin/env bash
# Script: rename-to-standard.sh
# Purpose: Interactive/Autonomous remediation of naming violations (Whitaker-class)
# Maturity: Level 5 (Autonomous)
# Compliance: Hellodeolu v7, Seven Pillars

set -euo pipefail

# --- Configuration ---
MODE="DRY-RUN"
SPECIFIC_EXT=""
AUTO_APPLY=false
MAPPING_FILE=".audit/naming-remediation-map.json"
LATEST_VIOLATIONS=".audit/naming-violations.json"

log_info() { echo -e "\033[1;36m[INFO]\033[0m $*"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_error() { echo -e "\033[1;31m[FAIL]\033[0m $*"; }

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply) MODE="APPLY" ;;
        --dry-run) MODE="DRY-RUN" ;;
        --rollback) MODE="ROLLBACK" ;;
        --ext=*) SPECIFIC_EXT="${1#*=}" ;;
        --auto) AUTO_APPLY=true ;;
        --help)
            echo "Usage: $0 [--apply|--dry-run|--rollback] [--ext=md|py|sh] [--auto]"
            exit 0
            ;;
        *) log_error "Unknown argument: $1"; exit 1 ;;
    esac
    shift
done

# --- 1. Map Generation (Bauer -> Whitaker Bridge) ---
map_violations() {
    log_info "Analyzing naming violations for remediation..."
    
    if [[ ! -f "$LATEST_VIOLATIONS" ]]; then
        log_error "No violations found. Run 'make naming-audit' first."
        exit 1
    fi

    echo "{}" > "$MAPPING_FILE"

    # Use JQ to process the violations and calculate the target name
    jq -c '.[]' "$LATEST_VIOLATIONS" | while read -r violation; do
        old_path=$(echo "$violation" | jq -r '.path')
        filename=$(basename "$old_path")
        ext="${old_path##*.}"
        
        # Skip if extension filter is active
        if [[ -n "$SPECIFIC_EXT" && "$ext" != "$SPECIFIC_EXT" ]]; then continue; fi

        new_name=""
        case "$ext" in
            md|sh)
                # Kebab-case: lowercase, replace _ and spaces with -
                new_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g' | sed 's/--*/-/g')
                ;;
            py)
                # Snake_case: lowercase, replace - and spaces with _
                # Special handling for __init__.py and test_*.py is usually handled by validator skipping them,
                # but we'll ensure underscores here.
                new_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/[- ]/_/g' | sed 's/__*/_/g')
                ;;
        esac

        if [[ -n "$new_name" && "$filename" != "$new_name" ]]; then
            new_path=$(dirname "$old_path")/"$new_name"
            # Update mapping file
            jq --arg old "$old_path" --arg new "$new_path" \
               '. + {($old): $new}' "$MAPPING_FILE" > "${MAPPING_FILE}.tmp" && mv "${MAPPING_FILE}.tmp" "$MAPPING_FILE"
            
            echo "  [MAP] $old_path -> $new_path"
        fi
    done

    VIOLATION_COUNT=$(jq 'length' "$MAPPING_FILE")
    if [[ "$VIOLATION_COUNT" -eq 0 ]]; then
        log_info "No remediable violations found."
        exit 0
    fi
    log_info "Found $VIOLATION_COUNT naming violations to fix."
}

# --- 2. Link/Reference Fixer ---
fix_references() {
    local old_path=$1
    local new_path=$2
    local old_base
    old_base=$(basename "$old_path")
    local new_base
    new_base=$(basename "$new_path")

    log_info "Updating references: $old_base -> $new_base"

    # Search and replace in relevant files (.md, .py, .sh, .yml, .yaml, Makefile)
    # We exclude .git and binary files implicitly via find
    find . -maxdepth 4 \( -name "*.md" -o -name "*.py" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "Makefile" -o -name "*.mk" \) \
        -not -path "*/.*" \
        -not -path "./builds/*" \
        -type f -exec sed -i "s/$old_base/$new_base/g" {} +
}

# --- 3. Apply Changes ---
apply_changes() {
    local COMMIT_MSG="discipline: automated naming remediation (Whitaker-class)"
    local BRANCH_NAME
    BRANCH_NAME="fix/naming-standard-remediation-$(date +%Y%m%d-%H%M)"

    if [[ "$AUTO_APPLY" == "false" ]]; then
        read -p "Proceed with applying changes in branch $BRANCH_NAME? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warn "Remediation aborted by user."
            exit 1
        fi
    fi

    log_info "Creating remediation branch: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"

    while IFS= read -r old_path; do
        new_path=$(jq -r --arg old "$old_path" '.[$old]' "$MAPPING_FILE")
        
        log_info "Moving: $old_path -> $new_path"
        if ! git mv "$old_path" "$new_path" 2>/dev/null; then
            log_warn "Fallback to standard mv for $old_path"
            mv "$old_path" "$new_path"
        fi
        
        fix_references "$old_path" "$new_path"
        
    done < <(jq -r 'keys[]' "$MAPPING_FILE")

    log_info "Finalizing remediation..."
    git add .
    git commit -S -m "$COMMIT_MSG" || git commit -m "$COMMIT_MSG"
    
    log_info "✅ Remediation applied. Validating..."
    if ./scripts/validate-naming-convention.sh; then
        log_info "🚀 Clean build! Naming discipline restored."
        echo "Next steps: gh pr create --title \"$COMMIT_MSG\" --body \"Detailed naming remediation across mesh.\""
    else
        log_error "Validation still failing after remediation. Manual intervention required."
        exit 1
    fi
}

# --- 4. Rollback ---
rollback_changes() {
    if [[ ! -f "$MAPPING_FILE" ]]; then
        log_error "Remediation map $MAPPING_FILE missing. Cannot rollback."
        exit 1
    fi

    log_info "Rolling back changes based on $MAPPING_FILE..."
    while IFS= read -r old_path; do
        new_path=$(jq -r --arg old "$old_path" '.[$old]' "$MAPPING_FILE")
        if [[ -f "$new_path" ]]; then
            log_info "Moving back: $new_path -> $old_path"
            git mv "$new_path" "$old_path" 2>/dev/null || mv "$new_path" "$old_path"
        fi
    done < <(jq -r 'keys[]' "$MAPPING_FILE")
    
    git commit -m "lazarus: rollback naming remediation"
    log_info "✅ Rollback complete."
}

# --- Execution ---
if [[ "$MODE" == "DRY-RUN" ]]; then
    map_violations
    echo "Tip: Run with --apply to perform renaming and reference updates."
elif [[ "$MODE" == "APPLY" ]]; then
    map_violations
    apply_changes
elif [[ "$MODE" == "ROLLBACK" ]]; then
    rollback_changes
fi
