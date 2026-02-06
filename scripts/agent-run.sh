#!/usr/bin/env bash
# Script: agent-run.sh
# Purpose: Non-interactive wrapper for Makefile targets (Fortress-Velocity)
# Agent: Bauer (Audit)
# Date: 2026-02-06
# Version: 1.0.0

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================
TARGET="${1:-}"
OUTPUT_FILE="${2:-.audit/agent-run-last.json}"
FORMAT="${FORMAT:-json}"

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Fail fast if no target provided
if [[ -z "$TARGET" ]]; then
    echo "❌ Error: No make target provided." >&2
    echo "Usage: ./scripts/agent-run.sh <target> [output_file]" >&2
    exit 3
fi

# TTY / Interactivity Guard
if [[ -t 0 ]]; then
    echo "⚠️  Warning: Running in interactive TTY mode." >&2
else
    # Force non-interactive for automation
    export MAKEFLAGS="--no-print-directory"
fi

# ============================================================================
# EXECUTION
# ============================================================================
START_TIME=$(date +%s%3N)

log_result() {
    local exit_code=$1
    local end_time
    end_time=$(date +%s%3N)
    local duration=$((end_time - START_TIME))
    local status="pass"
    
    if [[ $exit_code -ne 0 ]]; then
        status="fail"
    fi

    # Construct Bauer-standard JSON
    cat <<JSON > "$OUTPUT_FILE"
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "guardian": "Bauer",
  "ministry": "Audit & Automation",
  "target": "$TARGET",
  "status": "$status",
  "exit_code": $exit_code,
  "duration_ms": $duration,
  "format": "$FORMAT"
}
JSON
}

# Run the make target
# Passing FORMAT and non-interactive flags
set +e
make "$TARGET" FORMAT="$FORMAT" CI=true < /dev/null
EXIT_CODE=$?
set -e

log_result "$EXIT_CODE"

# Canonical Exit Code Handling
# 0: Pass, 1: Fail, 2: Warning/Baseline, 3: Tool/Usage Error
exit "$EXIT_CODE"
