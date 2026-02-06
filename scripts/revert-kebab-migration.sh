#!/usr/bin/env bash
# Script: revert-kebab-migration.sh
# Purpose: Emergency rollback of Naming Migration (Lazarus)
# Maturity: Level 5 (Autonomous)

set -euo pipefail

log_info() { echo -e "\033[1;36m[INFO]\033[0m $*"; }

if [[ ! -f "scripts/rename-to-kebab.sh" ]]; then
    echo "❌ Error: scripts/rename-to-kebab.sh missing."
    exit 1
fi

log_info "🛡️ Initiating Emergency Rollback (Lazarus Drill)..."
./scripts/rename-to-kebab.sh --rollback
