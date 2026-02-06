#!/usr/bin/env bash
# Script: rename-to-kebab.sh
# Purpose: Autonomous remediation of non-compliant naming (Bauer/Whitaker)
# Guardian: Whitaker (Offensive Validator)
# Maturity: Level 5 (Autonomous)
# Compliance: Hellodeolu v7, Seven Pillars

set -euo pipefail

MODE="DRY-RUN"
MAPPING_FILE=".audit/kebab-mapping.json"
BRANCH_NAME="fix/kebab-migration-$(date +%Y%m%d)"
COMMIT_MSG="bauer: automated naming remediation (kebab-case discipline)"

log_info() { echo -e "\033[1;36m[INFO]\033[0m $*"; }
log_error() { echo -e "\033[1;31m[FAIL]\033[0m $*"; }

usage() {
    echo "Usage: $0 [--dry-run | --apply | --rollback]"
    exit 1
}

# --- TTY Guard (Raptor/Grok Requirement) ---
check_tty() {
    if [[ ! -t 0 ]] && [[ "${RENAME_ASSUME_YES:-}" != "true" ]]; then
        log_error "Interactive mode requires a TTY or RENAME_ASSUME_YES=true."
        exit 1
    fi
}

[[ $# -eq 0 ]] && usage

case "$1" in
    --dry-run) MODE="DRY-RUN" ;;
    --apply)   MODE="APPLY"; check_tty ;;
    --rollback) MODE="ROLLBACK" ;;
    *) usage ;;
esac

# --- Initialization ---
mkdir -p .audit
if [[ ! -f "$MAPPING_FILE" ]]; then echo "{}" > "$MAPPING_FILE"; fi

# --- 1. Map Violations (Dry-Run) ---
map_violations() {
    log_info "Discovering non-compliant files..."
    VIOLATIONS=$(bash scripts/validate-naming-convention.sh 2>&1 | grep "Non-compliant naming:\|Insecure characters detected:" | awk '{print $NF}' || true)
    
    if [[ -z "$VIOLATIONS" ]]; then
        log_info "✅ No violations found. Mesh is in sync."
        return 0
    fi

    for old_path in $VIOLATIONS; do
        dir=$(dirname "$old_path")
        base=$(basename "$old_path")
        
        # Kebab transformation logic (Strict Hellodeolu v7/Raptor/Grok compliant)
        # 1. NFKC/Translit to clean chars
        # 2. Convert CamelCase to kebab
        # 3. Lowercase everything
        # 4. Replace ALL non-alphanumeric (except last dot) with hyphens
        # 5. Collapse multiple hyphens
        
        core_name="${base%.md}"
        new_core=$(echo "$core_name" | iconv -f UTF-8 -t UTF-8//TRANSLIT 2>/dev/null | \
                   sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | \
                   tr '[:upper:]' '[:lower:]' | \
                   sed -e 's/[^a-z0-9]/-/g' -e 's/-\+/-/g' -e 's/^-//g' -e 's/-$//g')
        
        new_base="${new_core}.md"
        new_path="${dir}/${new_base}"
        
        if [[ "$old_path" == "$new_path" ]]; then continue; fi
        
        # Collision check
        if [[ -f "$new_path" ]]; then
            log_error "COLLISION DETECTED: $new_path already exists. Skipping $old_path."
            continue
        fi

        log_info "Mapping: $old_path -> $new_path"
        jq --arg old "$old_path" --arg new "$new_path" \
           '. + {($old): $new}' "$MAPPING_FILE" > "${MAPPING_FILE}.tmp" && mv "${MAPPING_FILE}.tmp" "$MAPPING_FILE"
    done
}

# --- 2. Apply Changes ---
apply_changes() {
    MAPPING_COUNT=$(jq 'length' "$MAPPING_FILE")
    if [[ "$MAPPING_COUNT" -eq 0 ]]; then
        log_info "Nothing to apply."
        return 0
    fi

    log_info "Ensuring migration branch: $BRANCH_NAME"
    if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
        log_info "Branch $BRANCH_NAME already exists, continuing..."
    else
        git checkout -b "$BRANCH_NAME"
    fi

    while IFS= read -r old_path; do
        new_path=$(jq -r --arg old "$old_path" '.[$old]' "$MAPPING_FILE")
        
        log_info "Moving: $old_path -> $new_path"
        if ! git mv "$old_path" "$new_path" 2>/dev/null; then
            log_info "Fallback to standard mv for $old_path"
            mv "$old_path" "$new_path"
        fi
        
        # Reference fixer (Simple sed for markdown files)
        log_info "Updating internal references..."
        old_base=$(basename "$old_path")
        new_base=$(basename "$new_path")
        
        # Search and replace in all .md, .yaml, and .yml files
        find . -maxdepth 3 \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) \
            -not -path "./.rylan/*" \
            -not -path "./rylan-labs-common/*" \
            -exec sed -i "s/$old_base/$new_base/g" {} +
        
    done < <(jq -r 'keys[]' "$MAPPING_FILE")

    log_info "Finalizing migration..."
    git add .
    git commit -S -m "$COMMIT_MSG" || git commit -m "$COMMIT_MSG"
    
    log_info "✅ Migration applied. Run 'make tests' to verify links."
    echo "Next steps: gh pr create --title \"$COMMIT_MSG\" --body \"Automated naming fix.\""
}

# --- 3. Rollback ---
rollback_changes() {
    log_info "Rolling back changes based on $MAPPING_FILE..."
    while IFS= read -r old_path; do
        new_path=$(jq -r --arg old "$old_path" '.[$old]' "$MAPPING_FILE")
        if [[ -f "$new_path" ]]; then
            git mv "$new_path" "$old_path"
        fi
    done < <(jq -r 'keys[]' "$MAPPING_FILE")
    git commit -m "lazarus: rollback naming migration"
    log_info "✅ Rollback complete."
}

# --- Execution ---
if [[ "$MODE" == "DRY-RUN" ]]; then
    map_violations
elif [[ "$MODE" == "APPLY" ]]; then
    map_violations
    apply_changes
elif [[ "$MODE" == "ROLLBACK" ]]; then
    rollback_changes
fi
