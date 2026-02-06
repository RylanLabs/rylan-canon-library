#!/bin/bash
set -e

# Lazarus Recovery Drill
# Purpose: Simulate mesh corruption (Detached HEADs, Drift) and trigger auto-remediation.

RED='\033[0-31m'
GREEN='\033[0-32m'
NC='\033[0m'

echo -e "${GREEN}[LAZARUS DRILL] Initializing Chaos Scenario...${NC}"

# 1. Break a dependency (Detached HEAD)
if [ -d ".rylan/common" ]; then
    echo "Sowing chaos in .rylan/common..."
    pushd .rylan/common > /dev/null
    git checkout --detach HEAD~1
    popd > /dev/null
else
    echo "Warning: .rylan/common not found. Skipping detached HEAD chaos."
fi

# 2. Introduce Drift (Local changes in Sacred Files)
echo "Introducing drift in README.md..."
echo -e "\n# CORRUPTION DETECTED $(date)" >> README.md

# 3. Simulate unauthorized Submodule URL
echo "Injecting unauthorized Gitmodule URL..."
cat <<EOF >> .gitmodules
[submodule "malware-repo"]
	path = .rylan/malware
	url = https://github.com/hacker/malware.git
EOF

echo -e "${RED}[LAZARUS DRILL] Chaos Injection Complete.${NC}"
git status -s

echo -e "\n${GREEN}[LAZARUS DRILL] Triggering Recovery (Sentinel/Whitaker)...${NC}"

# Run Whitaker Gate with Remediation
./scripts/whitaker-detached-head.sh --remediate

# Run Beale Gate (Validate Submodules)
./scripts/validate-gitmodules.sh || {
    echo -e "${RED}[LAZARUS DRILL] Beale Gate correctly caught the unauthorized URL.${NC}"
    echo "Purging corruption from .gitmodules..."
    # Simple cleanup for the drill
    sed -i '/malware-repo/,+2d' .gitmodules
}

# Run Sync (Revert Files)
echo "Reverting drift via Sync..."
git checkout README.md

echo -e "${GREEN}[LAZARUS DRILL] Recovery Sequence Finished.${NC}"
git status -s
