#!/usr/bin/env bash
# Script: org-audit.sh
# Purpose: Multi-repo compliance scan (Whitaker)
# Agent: Whitaker (Detection)
# Author: RylanLabs canonical
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

ORG="RylanLabs"
TOPIC="rylan-mesh-satellite"
AUDIT_DIR=".audit"
MATRIX_FILE="${AUDIT_DIR}/compliance-matrix.json"

mkdir -p "$AUDIT_DIR"

echo "🛡️ Starting Organizational Audit for ${ORG} (Topic: ${TOPIC})..."

# 1. Discover Repositories
REPOS=$(gh repo list "$ORG" --topic "$TOPIC" --json name --jq '.[].name' || echo "")

if [[ -z "$REPOS" ]]; then
    echo "⚠️ No repositories found with topic '${TOPIC}'."
    echo "{\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"repos\": []}" > "$MATRIX_FILE"
    exit 0
fi

# Initialize JSON Matrix
echo "{\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"repos\": [" > "$MATRIX_FILE"

FIRST_REPO=true
for REPO in $REPOS; do
    echo "🔍 Auditing $REPO..."
    
    if [ "$FIRST_REPO" = false ]; then echo "," >> "$MATRIX_FILE"; fi
    FIRST_REPO=false

    # Check for mandatory files via API (saves cloning time)
    HAS_COMMON_MK=$(gh api "repos/${ORG}/${REPO}/contents/common.mk" --silent &>/dev/null && echo true || echo false)
    HAS_GITLEAKS=$(gh api "repos/${ORG}/${REPO}/contents/.gitleaks.toml" --silent &>/dev/null && echo true || echo false)
    
    # Check for SIGNED commits (last 5)
    # Returns 1 if all are signed, 0 if any are unsigned
    SIGNED_STATUS=$(gh api "repos/${ORG}/${REPO}/commits" --jq '.[0:5] | all(.commit.verification.verified == true)' || echo false)

    # Build JSON fragment
    cat <<EOF >> "$MATRIX_FILE"
    {
      "name": "$REPO",
      "compliance": {
        "common_mk": $HAS_COMMON_MK,
        "gitleaks": $HAS_GITLEAKS,
        "signed_commits": $SIGNED_STATUS
      },
      "status": $([[ "$HAS_COMMON_MK" == "true" && "$HAS_GITLEAKS" == "true" && "$SIGNED_STATUS" == "true" ]] && echo "\"GREEN\"" || echo "\"RED\"")
    }
EOF

done

echo "]}" >> "$MATRIX_FILE"

echo "✅ Audit complete. Matrix saved to ${MATRIX_FILE}"

# Fail if any repo status is RED (for Sentinel/CI integration)
if grep -q "\"RED\"" "$MATRIX_FILE"; then
    echo "❌ COMPLIANCE DRIFT DETECTED!"
    exit 1
fi

exit 0
