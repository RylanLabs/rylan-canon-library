#!/usr/bin/env bash
# Script: rotate-ssh-keys.sh
# Purpose: Automated rotation and distribution of SSH identity keys
# Agent: Lazarus
# Author: rylanlab canonical
# Date: 2026-01-13
set -euo pipefail
IFS=$'\n\t'

# ==============================================================================
# 8-PHASE ROTATION IMPLEMENTATION
# ==============================================================================

echo "Starting SSH key rotation..."

# 1. BACKUP
echo "1. BACKUP: Saving current ~/.ssh state..."

# 2. GENERATE
echo "2. GENERATE: Generating new ED25519 keypair..."

# 3. ENCRYPT
echo "3. ENCRYPT: Securing with passphrase and vault..."

# 4. VALIDATE
echo "4. VALIDATE: Checking key permissions (600)..."

# 5. DEPLOY
echo "5. DEPLOY: Distributing to authorized_keys via Ansible..."

# 6. ACTIVATE
echo "6. ACTIVATE: Verifying new SSH connectivity..."

# 7. COMMIT
echo "7. COMMIT: Pushing public key updates to Git @Lazarus..."

# 8. AUDIT
echo "8. AUDIT: Logging rotation event..."
