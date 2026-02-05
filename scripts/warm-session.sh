#!/usr/bin/env bash
# Script: warm-session.sh
# Purpose: Establish 8-hour password-less GPG session for mesh operations
# Agent: Carter
# Author: rylanlab canonical
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

GPG_KEY_ID="F5FFF5CB35A8B1F38304FC28AC4A4D261FD62D75"

echo "Warming GPG session for $GPG_KEY_ID..."

# Check if key exists
if ! gpg --list-keys "$GPG_KEY_ID" &>/dev/null; then
    echo "❌ GPG Key not found: $GPG_KEY_ID"
    exit 1
fi

# Preset passphrase (this requires gpg-agent to be running and allow-preset-passphrase enabled)
# For local dev, this typically prompts for a password via pinentry once
# Then preserves it in the agent for the duration of the TTL.

echo "Sign a test blob to warm the agent..."
echo "test" | gpg --local-user "$GPG_KEY_ID" --clear-sign > /dev/null

echo "✅ GPG session warmed (8-hour TTL suggested)"
