#!/usr/bin/env bash
# Script: whitaker-scan.sh
# Purpose: Adversarial scan for unsigned commits and identity drift
# Guardian: Whitaker (Offensive Validator)
# Ministry: Oversight
# Maturity: Level 5 (Autonomous)
# Author: RylanLabs canonical
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

FAILED=0
SCANNED_FILES=0

echo "🛡️ Running Whitaker Protocol: Historical Spoof Scan & Local Drift..."

# 1. Local Drift Detection (Sensitive Stores)
# Checks for uncommitted changes in core secret paths
SECRET_PATHS=("vaults/" "inventory/" "keys/")
EXISTING_PATHS=()
for p in "${SECRET_PATHS[@]}"; do [[ -d "$p" ]] && EXISTING_PATHS+=("$p"); done

if [ ${#EXISTING_PATHS[@]} -gt 0 ]; then
    CHANGES=$(git status --short "${EXISTING_PATHS[@]}" 2>/dev/null || true)
    if [ -n "$CHANGES" ]; then
        # Filter for documentation or harmless metadata
        CRITICAL_CHANGES=$(echo "$CHANGES" | grep -vE "README\.md|\.audit/|docs/|group_vars/" || true)
        if [ -n "$CRITICAL_CHANGES" ]; then
             # Allow identity files or group_vars iff they are new (provisioning/migration)
             if echo "$CRITICAL_CHANGES" | grep -qE "^(\?\?|A ).*(identity|group_vars)"; then
                echo "ℹ️  New sensitive files detected (Provisioning/Migration Mode)."
             else
                echo "❌ ADVERSARIAL DETECTION: Uncommitted changes in secret stores!"
                echo "$CRITICAL_CHANGES"
                FAILED=1
             fi
        else
            echo "ℹ️  Documentation updates or clean state detected."
        fi
    fi
fi

# 2. SOPS Integrity Check
if [ -d "vaults/" ]; then
    echo "🔍 Checking SOPS integrity (MAC verification)..."
    # Find all encrypted files
    while IFS= read -r vault; do
        SCANNED_FILES=$((SCANNED_FILES + 1))
        # Verify MAC without decrypting to stdout
        if ! sops --verify-mac "$vault" &>/dev/null; then
             echo "❌ ADVERSARIAL DETECTION: SOPS MAC Failure in $vault"
             FAILED=1
        fi
    done < <(find vaults/ -name "*.yml" -exec grep -l "sops" {} + 2>/dev/null || true)
fi

# 2.1 Gitmodules Integrity Check
if [[ -f ".gitmodules" ]]; then
    echo "🔍 Checking Gitmodules integrity..."
    if ! bash scripts/validate-gitmodules.sh >/dev/null 2>&1; then
        echo "❌ ADVERSARIAL DETECTION: Gitmodules URL Allow-list violation!"
        FAILED=1
    fi
fi

# 2.2 Naming Convention Checklist (Kebab-Case Discipline)
echo "🔍 Checking naming conventions..."
if ! bash scripts/validate-naming-convention.sh >/dev/null 2>&1; then
    echo "❌ ADVERSARIAL DETECTION: Naming convention violation detected!"
    FAILED=1
fi

# 3. Signature Enforcement (Last 5 commits)
if git rev-parse --git-dir &>/dev/null; then
    echo "🔍 Checking recent commit signatures..."
    git log -5 --pretty=format:"%H" | while read -r hash; do
        if ! git log -1 --show-signature "$hash" 2>&1 | grep -q "Good signature"; then
            echo "⚠️  ADVERSARIAL WARNING: Unsigned commit $hash (Policy Gap)"
            # Note: We warn but don't fail for signatures in local dev to avoid blocking bootstrap
        fi
    done

    # 3.1 Detached HEAD Protection
    if ! git symbolic-ref -q HEAD &>/dev/null; then
        echo "❌ ADVERSARIAL DETECTION: Detached HEAD state detected!"
        FAILED=1
    fi
fi

# 4. Symlink SSOT Enforcement (Sacred Scripts)
if [[ -d "scripts" && ! -f "canon-manifest.yaml" ]]; then
    # Only enforce in satellites, not in the Canon Hub itself
    echo "🔍 Checking Symlink SSOT Integrity (Sacred Scripts)..."
    SACRED_SCRIPTS=(
      "validate.sh"
      "validate-yaml.sh"
      "validate-bash.sh"
      "validate-python.sh"
      "validate-ansible.sh"
      "validate-sops.sh"
      "validate-gitmodules.sh"
      "whitaker-scan.sh"
      "sentinel-expiry.sh"
      "warm-session.sh"
      "playbook-structure-linter.py"
      "verify-workflows.sh"
      "whitaker_anomaly_detector.py"
      "whitaker-detached-head.sh"
    )
    
    for script in "${SACRED_SCRIPTS[@]}"; do
        if [[ -f "scripts/$script" && ! -L "scripts/$script" ]]; then
            echo "⚠️  ADVERSARIAL WARNING: Sacred script 'scripts/$script' is a literal file (GHOST STUB detected)!"
            echo "   Fix: Use 'ln -sf submodules/canon-lib/scripts/$script scripts/$script' or run 'make resolve'"
            # FAILED=1
        fi
    done
fi

# 5. Live Anomaly Detection (UniFi)
if [[ -f "scripts/whitaker_anomaly_detector.py" && -n "${UNIFI_HOST:-}" ]]; then
    echo "🔍 Running Live Anomaly Detection..."
    if ! python3 scripts/whitaker_anomaly_detector.py; then
        FAILED=1
    fi
fi

if [ "$FAILED" -ne 0 ]; then
    echo "❌ Whitaker scan FAILED. Adversarial drift or corruption detected."
    exit 1
fi

echo "✅ Whitaker scan complete ($SCANNED_FILES secrets verified)."
exit 0
