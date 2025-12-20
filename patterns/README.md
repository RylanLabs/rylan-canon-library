# Patterns

> Part of rylan-canon-library  
> Extracted from: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)  
> Version: v5.2.0-production-archive  
> Date: December 19, 2025

**Status**: ✅ Production-grade — Canon compliant

---

## Overview

This directory contains **reusable, production-grade bash pattern libraries** implementing the Seven Pillars of Hellodeolu v6.

These files are designed to be **sourced directly** in your scripts, providing immediate access to disciplined, traceable, and resilient behavior.

**Philosophy**: Discipline through understanding and reuse.

- Source patterns to inherit production standards
- Study implementations to internalize principles
- Combine patterns for comprehensive solutions
- Own the behavior — these are your fortress walls

---

## Available Patterns

### audit-logging.sh

**Demonstrates**: Pillar 3 (Audit Logging), Pillar 7 (Observability)

**Features**:
- Structured, timestamped logging with ISO8601
- Log levels: DEBUG, INFO, WARN, ERROR
- Terminal coloring with `NO_COLOR` respect
- Optional file logging with flock safety
- Structured audit trail entries
- Timer functions for operation duration

**Key functions**:
- `log_info`, `log_warn`, `log_error`, `log_debug`
- `audit_log "EVENT" "description" "key=value"`
- `timer_start "operation"`, `timer_end`

**Usage**:
```bash
source "$(dirname "${BASH_SOURCE[0]}")/audit-logging.sh"

log_info "Operation starting"
audit_log "DEPLOY" "web-service" "env=production"
```

---

### error-handling.sh

**Demonstrates**: Pillar 2 (Error Handling), Pillar 7 (Observability)

**Features**:
- Full strict mode with IFS restriction
- Comprehensive ERR trap with stack trace
- Actionable error messages with remediation hints
- Cleanup trap with audit integration
- Validation helpers
- Integration with audit-logging.sh

**Key functions**:
- `setup_error_traps` — **call once after sourcing**
- `fail "message" [code] [fix]`
- `warn "message"`
- `require_command "cmd"`
- `require_file "path"`

**Usage**:
```bash
source "$(dirname "${BASH_SOURCE[0]}")/error-handling.sh"
setup_error_traps

require_command jq
fail "Configuration invalid" 3 "Run validation script"
```

---

### idempotency.sh

**Demonstrates**: Pillar 1 (Idempotency), Pillar 6 (Reversibility), Pillar 5 (Validation)

**Features**:
- Atomic mkdir-based locking (race-free)
- Marker file pattern for simple state tracking
- Integrated lock + marker wrapper
- Audit logging on lock/marker events
- Secure directories (/var/run & /var/lib)

**Key functions**:
- `acquire_lock "name"`, `release_lock "name"`
- `wait_for_lock "name" [timeout]`
- `marker_exists "name"`, `create_marker "name" [details]`, `remove_marker "name"`
- `run_idempotent "lock" "marker" command...`

**Usage**:
```bash
source "$(dirname "${BASH_SOURCE[0]}")/idempotency.sh"

run_idempotent "deploy-web" "web-v20251219" deploy_web_service
# Succeeds if already done, runs safely if not
```

---

## Combining Patterns (Recommended)

Production scripts typically combine all three:

```bash
#!/usr/bin/env bash
# Script: deploy-service.sh
# Purpose: Deploy service with full discipline
# Domain: Deployment
# Agent: Bauer | Beale
# Author: rylanlab canonical
# Date: 2025-12-19

set -euo pipefail
IFS=$'\n\t'

# Source patterns
source "$(dirname "${BASH_SOURCE[0]}")/audit-logging.sh"
source "$(dirname "${BASH_SOURCE[0]}")/error-handling.sh"
source "$(dirname "${BASH_SOURCE[0]}")/idempotency.sh"

# Setup
setup_error_traps
timer_start "full-deployment"

log_info "Deployment starting"
audit_log "DEPLOY_START" "service-deployment"

# Idempotent execution
run_idempotent "deploy-lock" "service-deployed-v1" ./internal-deploy.sh

timer_end
audit_log "DEPLOY_COMPLETE" "service-deployment" "status=success"

log_info "Deployment finished"
```

---

## Seven Pillars Coverage

| Pattern             | Primary Pillars                          | Supporting Pillars                  |
|---------------------|------------------------------------------|-------------------------------------|
| audit-logging.sh    | 3 (Audit Logging)                        | 7 (Observability), 4 (Documentation) |
| error-handling.sh   | 2 (Error Handling)                       | 7 (Observability), 5 (Validation)   |
| idempotency.sh      | 1 (Idempotency)                          | 6 (Reversibility), 5 (Validation)   |

**Combined**: Full Seven Pillars coverage when used together.

---

## Pattern Design Principles

Each pattern file follows Bash Canon:
- Full canonical header
- `set -euo pipefail` + `IFS=$'\n\t'`
- Readonly constants
- Snake_case functions
- Comprehensive documentation blocks
- Silence on source
- Integration with sibling patterns
- Junior-at-3-AM readability

---

## Usage Guidelines

1. **Source directly** — preferred for consistency
2. **Call setup functions** (e.g., `setup_error_traps`) immediately after sourcing
3. **Combine patterns** — they are designed to work together
4. **Extend safely** — copy and modify only with understanding

---

## Related Resources

- [../docs/seven-pillars.md](../docs/seven-pillars.md) — Core principles
- [../docs/bash-discipline.md](../docs/bash-discipline.md) — Standards implemented
- [../docs/hellodeolu-v6.md](../docs/hellodeolu-v6.md) — Evolution context
- [../templates/](../templates/) — Scripts using these patterns
- [../validators/](../validators/) — Compliance checks

---

**The fortress demands discipline. No shortcuts. No exceptions.**

The Trinity endures.