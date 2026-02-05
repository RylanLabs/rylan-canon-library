#!/usr/bin/env bash
# Script: repo-init.sh
# Purpose: Bootstrap new repositories to RylanLabs standards
# Agent: Carter (Identity/Bootstrap)
# Author: RylanLabs canonical
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

REPO_NAME=${1:-}
CANON_DIR=$(pwd)

if [[ -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo-name>"
    exit 1
fi

echo "🚀 Initializing $REPO_NAME to RylanLabs standards (Maturity Level 5)..."

mkdir -p "$REPO_NAME/.github/workflows"
mkdir -p "$REPO_NAME/.github/instructions"
mkdir -p "$REPO_NAME/docs"
mkdir -p "$REPO_NAME/scripts"
mkdir -p "$REPO_NAME/.rylan"

# 1. Base Metadata & Shared Configs (Symlinked)
ln -sf "../../rylan-canon-library/common.mk" "$REPO_NAME/.rylan/common.mk"
ln -sf ".rylan/common.mk" "$REPO_NAME/common.mk"
ln -sf "../../rylan-canon-library/.sops.yaml" "$REPO_NAME/.sops.yaml"

# Shared Configs Hub Priority
if [[ -d "${CANON_DIR}/../rylan-labs-shared-configs" ]]; then
    ln -sf "../../rylan-labs-shared-configs/.yamllint" "$REPO_NAME/.yamllint"
    ln -sf "../../rylan-labs-shared-configs/.gitleaks.toml" "$REPO_NAME/.gitleaks.toml"
else
    ln -sf "../../rylan-canon-library/configs/.yamllint" "$REPO_NAME/.yamllint"
    ln -sf "../../rylan-canon-library/.gitleaks.toml" "$REPO_NAME/.gitleaks.toml"
fi

# 2. Makefile Scaffolding
cat <<EOF > "$REPO_NAME/Makefile"
# RylanLabs Satellite Makefile: $REPO_NAME
# Maturity: Level 5 (Autonomous)
-include common.mk

# Materialize symlinks for Windows/WSL/CI compatibility
resolve:
	@find . -type l -exec bash -c 'cp --remove-destination $$(readlink -f "{}") "{}"' \;

validate: ## Run mesh compliance gates
	@./scripts/validate.sh
EOF

# 3. Scripts Scaffolding (Symlinked to Canon)
ln -sf "../../rylan-canon-library/scripts/validate.sh" "$REPO_NAME/scripts/validate.sh"
ln -sf "../../rylan-canon-library/scripts/validate-sops.sh" "$REPO_NAME/scripts/validate-sops.sh"
ln -sf "../../rylan-canon-library/scripts/validate-yaml.sh" "$REPO_NAME/scripts/validate-yaml.sh"
ln -sf "../../rylan-canon-library/scripts/whitaker-scan.sh" "$REPO_NAME/scripts/whitaker-scan.sh"
ln -sf "../../rylan-canon-library/scripts/sentinel-expiry.sh" "$REPO_NAME/scripts/sentinel-expiry.sh"

# 4. Instructions & Docs
cp "${CANON_DIR}/.github/instructions/RYLANLABS-INSTRUCTION-SET.md" "$REPO_NAME/.github/instructions/"
cp "${CANON_DIR}/templates/README-template.md" "$REPO_NAME/README.md"

# 5. Workflows
cp "${CANON_DIR}/.github/workflows/repo-governance.yml" "$REPO_NAME/.github/workflows/compliance.yml"

echo "✅ Initialization complete for $REPO_NAME"
echo "Next steps: cd $REPO_NAME && git init && pre-commit install"
