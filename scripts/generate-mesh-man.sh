#!/bin/bash
# RylanLabs Mesh-Man Generation Script
# v2.2.0-mesh
# Transforms Makefile/common.mk comments into production-grade documentation.

set -e

OUTPUT="MESH-MAN.md"
TEMP_FILE=".audit/mesh-man.tmp"
mkdir -p .audit

# Helper for logging
log_info() { printf "\033[36m[INFO]\033[0m %s\n" "$1"; }

{
    echo "# RylanLabs Mesh-Man: Operational Manual"
    echo ""
    echo "---"
    echo "title: Mesh-Man Operational Manual"
    echo "version: v2.2.0-mesh"
    echo "guardian: Bauer"
    echo "date: $(date -I)"
    echo "compliance: Hellodeolu v7, Seven Pillars"
    echo "---"
    echo ""
    echo "> [!IMPORTANT]"
    echo "> This manual is auto-generated from common.mk and the root Makefile. It represents the SINGLE SOURCE OF TRUTH for mesh orchestration."
    echo ""
    echo "## 🛡️ Core Infrastructure (Canon Library)"
    echo "These targets are the 'Eternal Glue' used across the mesh."
    echo ""
    echo "| Target | Purpose | Guardian | Timing Estimate |"
    echo "|:-------|:--------|:---------|:----------------|"

    # Parse common.mk and Makefile for targets with ## descriptions
    # Format: target: ## description | guardian: Name | timing: 30s
    grep -rhE '^[a-zA-Z_-]+:.*?## .*$' Makefile common.mk | sort -u | while read -r line; do
        target=${line%%:*}
        
        # Extract the info after '##' using parameter expansion (avoid sed)
        info=${line#*## }
        purpose=$(echo "$info" | cut -d'|' -f1 | sed 's/^[ \t]*//;s/[ \t]*$//')
        
        # Extract metadata
        guardian=$(echo "$info" | grep -o 'guardian: [^|]*' | cut -d: -f2- | sed 's/^[ \t]*//;s/[ \t]*$//')
        timing=$(echo "$info" | grep -o 'timing: [^|]*' | cut -d: -f2- | sed 's/^[ \t]*//;s/[ \t]*$//')
        
        [ -z "$guardian" ] && guardian="N/A"
        [ -z "$timing" ] && timing="Unknown"
        
        printf "| \`%s\` | %s | %s | %s |\n" "$target" "$purpose" "$guardian" "$timing"
    done
    
    echo ""
    echo "## 🔄 High-Fidelity Workflows"
    echo ""
    echo "### 1. The Daily Pivot (Routine Maintenance)"
    echo "\`\`\`bash"
    echo "make resolve  # Materialize agnosticism"
    echo "make validate # Run Whitaker gates"
    echo "make publish  # Sync to mesh"
    echo "\`\`\`"
    echo ""
    echo "### 2. Mesh-Wide Synchronization"
    echo "\`\`\`bash"
    echo "make cascade  # Push state to all satellites"
    echo "make org-audit # Multi-repo scan"
    echo "\`\`\`"
    echo ""
    echo "## ⚖️ Compliance Standards"
    echo "- **Idempotency**: All targets must be safe to run repeatedly."
    echo "- **Observability**: Every run produces an entry in \`.audit/audit-trail.jsonl\`."
    echo "- **Junior-Deployable**: Descriptions must be clear enough for a Level 1 engineer."

} > "$OUTPUT"

log_info "MESH-MAN.md regenerated successfully."
