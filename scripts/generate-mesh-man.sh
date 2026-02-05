#!/usr/bin/env bash
# Script: generate-mesh-man.sh
# Purpose: Aggregate all repo targets into a single searchable document (MESH-MAN.md)
# Agent: Bauer (Auditor)
# Author: RylanLabs canonical
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

OUTPUT="MESH-MAN.md"

echo "📖 Generating ${OUTPUT} (Mesh-Man)..."

{
    echo "# RylanLabs Mesh-Man: Operational manual"
    echo ""
    echo "---"
    echo "title: Mesh-Man Operational Manual"
    echo "version: v2.1.0-mesh"
    echo "guardian: Bauer"
    echo "date: $(date -I)"
    echo "---"
    echo ""
    echo "> [!IMPORTANT]"
    echo "> This manual is auto-generated. It represents the SINGLE SOURCE OF TRUTH for all mesh operations."
    echo ""
    echo "## 🛡️ Core Infrastructure (Canon Library)"
    echo "These targets are executed from the \`rylan-canon-library\` anchor."
    echo ""
    echo "\`\`\`bash"
    make help | sed 's/^[ \t]*//'
    echo "\`\`\`"
    echo ""
    echo "## 🌊 Satellite Standard Targets"
    echo "All satellites inheriting \`common.mk\` support these standard targets:"
    echo ""
    echo "| Target | Purpose | Guardian |"
    echo "|--------|---------|----------|"
    echo "| \`validate\` | Run Whitaker/Sentinel compliance gates | Bauer |"
    echo "| \`warm-session\` | Establish GPG session for SOPS | Carter |"
    echo "| \`cascade\` | Sync with Tier 0 Canon | Beale |"
    echo "| \`clean\` | Purge local artifacts | - |"
    echo ""
    echo "## 🧠 Architecture Reference"
    echo "- [Seven Pillars](docs/seven-pillars.md): Core IaC principles"
    echo "- [Trinity Execution](docs/trinity-execution.md): 5-Agent operational model"
    echo "- [Hellodeolu v7](docs/hellodeolu-v7.md): Autonomous Governance Architecture"
    echo "- [Mesh Paradigm](docs/eternal-glue.md): Multi-repo orchestration"
} > "$OUTPUT"

echo "✅ $OUTPUT generated successfully."
