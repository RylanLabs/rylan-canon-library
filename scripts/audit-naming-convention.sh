#!/usr/bin/env bash
# Script: audit-naming-convention.sh
# Purpose: Generate structured audit reports for Kebab-Case Discipline
# Guardian: Bauer (Auditor)
# Maturity: Level 5 (Autonomous)

set -euo pipefail

log_info() { echo -e "\033[1;36m[INFO]\033[0m $*"; }

echo "🛡️ Starting Organizational Naming Audit..."

# Run the validator in non-failing mode to collect metrics
bash scripts/validate-naming-convention.sh > /dev/null 2>&1 || true

VIOLATIONS_FILE=".audit/naming-violations.json"
METRICS_FILE=".audit/metrics.json"

if [[ ! -f "$VIOLATIONS_FILE" ]]; then
    echo "✅ No violations found."
    exit 0
fi

VIOLATION_COUNT=$(jq '. | length' "$VIOLATIONS_FILE")

if [[ "$VIOLATION_COUNT" -eq 0 ]]; then
    echo "✅ No naming violations detected across surveyed files."
else
    echo "❌ AUDIT SUMMARY: $VIOLATION_COUNT naming violations found."
    echo "------------------------------------------------------------"
    jq -r '.[] | "  - \(.path) [Reason: \(.reason)]"' "$VIOLATIONS_FILE" | head -n 20
    if [[ "$VIOLATION_COUNT" -gt 20 ]]; then
        echo "  ... and $((VIOLATION_COUNT - 20)) more (See $VIOLATIONS_FILE)"
    fi
    echo "------------------------------------------------------------"
    echo "Remediation: Run 'make naming-fix-interactive' or 'scripts/rename-to-kebab.sh --apply'"
fi

# Update MESH-MAN.md (Pillar 7: Observability)
if [[ -f "MESH-MAN.md" ]]; then
    log_info "Updating MESH-MAN.md with latest audit state..."
    DATE=$(date -u +%Y-%m-%d)
    sed -i "s/Naming Discipline Status: .*/Naming Discipline Status: $VIOLATION_COUNT violations as of $DATE/" MESH-MAN.md || true
fi
