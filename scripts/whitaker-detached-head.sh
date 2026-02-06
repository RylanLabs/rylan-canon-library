#!/usr/bin/env bash
# Guardian: Whitaker (Adversarial Testing)
# Ministry: Security Enforcement
# Version: v1.0.0
# Compliance: Hellodeolu v7, No-Bypass Culture

set -euo pipefail

# Check if LAZARUS_AUTO_REMEDIATE mode is active
LAZARUS_MODE="${LAZARUS_AUTO_REMEDIATE:-false}"

if ! git symbolic-ref -q HEAD &>/dev/null; then
  COMMIT_SHA=$(git rev-parse --short HEAD)
  TIMESTAMP=$(date +%s)
  
  if [[ "$LAZARUS_MODE" == "true" ]]; then
    # Lazarus Auto-Remediation Mode
    BRANCH_NAME="lazarus/detached-${TIMESTAMP}"
    
    echo "🔧 LAZARUS AUTO-REMEDIATION ACTIVATED"
    echo "   Detached HEAD detected at: $COMMIT_SHA"
    echo "   Creating recovery branch: $BRANCH_NAME"
    
    # Create branch at current position
    git checkout -b "$BRANCH_NAME"
    
    # Ensure .audit exists
    mkdir -p .audit
    
    # Log remediation
    cat > ".audit/lazarus-detached-remediation-${TIMESTAMP}.json" <<JSON
{
  "timestamp": "$(date -Iseconds)",
  "guardian": "Lazarus",
  "event": "detached_head_auto_remediation",
  "original_commit": "$(git rev-parse HEAD)",
  "recovery_branch": "$BRANCH_NAME",
  "status": "SUCCESS"
}
JSON
    
    echo "✅ Remediation complete. Branch created: $BRANCH_NAME"
    echo "📋 Audit log: .audit/lazarus-detached-remediation-${TIMESTAMP}.json"
    exit 0
  else
    # Standard Blocking Mode
    cat <<ALERT
🚨 WHITAKER GATE VIOLATION: Detached HEAD Detected

Current State: HEAD is detached at $COMMIT_SHA
Risk Level: HIGH (orphaned commits, broken audit trail)

Remediation Options:
  1. Create feature branch:
     git checkout -b feature/emergency-\$(date +%s)
  
  2. Return to main branch:
     git checkout main
  
  3. Auto-remediation (Lazarus mode):
     export LAZARUS_AUTO_REMEDIATE=true
     git commit --no-edit

Rationale:
  - Detached commits are not reachable from any branch
  - Breaks Bauer audit trail requirements (Seven Pillars)
  - Violates no-bypass culture (Hellodeolu v7)

Bypass (EMERGENCY ONLY):
  git commit --no-verify
ALERT
    exit 1
  fi
fi

# Bauer Audit: Log successful validation
# Only echo if in verbose/manual mode or hook context
if [[ -t 1 ]]; then
    echo "✅ Whitaker Gate: HEAD attached to $(git symbolic-ref --short HEAD)"
fi
