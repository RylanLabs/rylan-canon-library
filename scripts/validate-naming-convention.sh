#!/usr/bin/env bash
# Script: validate-naming-convention.sh
# Purpose: Enforce Tier-based naming conventions (rylan-labs- vs rylanlabs-)
# Guardian: Carter (Identity)
# Ministry: Standards Enforcement
# Maturity: Level 5 (Autonomous)
# Date: 2026-02-05

set -euo pipefail

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

echo "=== Naming Convention Validation ==="
echo "Repository: $REPO_NAME"

# Determine expected prefix based on tier declaration in README.md
if [ -f "README.md" ]; then
    TIER=$(grep -oP '(?<=\*\*Tier\*\*: )\d+' README.md || echo "UNKNOWN")
    
    case "$TIER" in
        0)
            EXPECTED_PATTERN="^rylan-canon-library$"
            ;;
        0.5)
            EXPECTED_PATTERN="^rylanlabs-.*-vault$"
            ;;
        1)
            EXPECTED_PATTERN="^rylan-inventory$"
            ;;
        2)
            EXPECTED_PATTERN="^rylan-labs-.*-configs$"
            ;;
        3)
            EXPECTED_PATTERN="^rylan-labs-common$"
            ;;
        4)
            # Tier 4 can be rylan-labs- (infra) or rylanlabs- (service)
            if [[ "$REPO_NAME" =~ ^rylan-labs- ]] || [[ "$REPO_NAME" =~ ^rylanlabs- ]]; then
                echo "✓ PASS: Tier 4 naming convention valid."
                exit 0
            else
                echo "✗ FAIL: Tier 4 repos must use 'rylan-labs-' (infra) or 'rylanlabs-' (service)."
                exit 1
            fi
            ;;
        *)
            echo "⚠ WARNING: Unknown or missing Tier in README.md. Using broad match."
            EXPECTED_PATTERN="^rylan-.*|^rylanlabs-.*"
            ;;
    esac
    
    if [[ "$REPO_NAME" =~ $EXPECTED_PATTERN ]]; then
        echo "✓ PASS: Repository name matches Tier $TIER convention."
        exit 0
    else
        echo "✗ FAIL: Repository name '$REPO_NAME' does not match expected pattern '$EXPECTED_PATTERN'."
        exit 1
    fi
else
    echo "⚠ WARNING: No README.md found, cannot validate tier."
    exit 0
fi
