# Patterns

> Part of rylan-patterns-library  
> Extracted from: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)  
> Version: v5.2.0-production-archive  
> Date: December 19, 2025

**Status**: 🚧 Content extraction in progress

---

## Overview

This directory contains reusable bash patterns demonstrating Seven Pillars principles in practice. These are **reference implementations** you can study, copy, or source directly in your scripts.

## Philosophy

**Learn by example, implement with understanding.**

These patterns show *how* to implement Seven Pillars principles:
- Study the implementation to understand the pattern
- Copy functions or source files directly
- Adapt patterns to your specific use case
- Combine patterns for comprehensive solutions

**Not a library**: These are educational examples, not a framework. Copy and own the code.

## Available Patterns

### error-handling.sh

**Demonstrates**: Pillar 2 (Error Handling), Pillar 7 (Observability)

**Includes**:
- Strict mode setup (`set -euo pipefail`)
- Error trap handlers
- Exit code conventions
- Error message formatting
- Cleanup on failure
- Graceful degradation patterns

**Usage**:
```bash
# Source the pattern
source patterns/error-handling.sh

# Or copy functions into your script
# Study the implementation for best practices
```

**Key functions**:
- `error_handler()` - Trap handler for errors
- `cleanup_on_exit()` - Cleanup logic
- `fail_with_message()` - Structured error exit

**Status**: 🚧 TODO - Extract from source repository

---

### audit-logging.sh

**Demonstrates**: Pillar 3 (Audit Logging), Pillar 7 (Observability)

**Includes**:
- Structured logging functions
- Timestamp formatting
- Log levels (INFO, WARN, ERROR, DEBUG)
- Colored output for terminals
- Log file rotation patterns
- Audit trail formatting

**Usage**:
```bash
# Source the pattern
source patterns/audit-logging.sh

# Use logging functions
log_info "Starting operation"
log_error "Operation failed"
log_debug "Debug information"
```

**Key functions**:
- `log_info()` - Info level logging
- `log_warn()` - Warning logging
- `log_error()` - Error logging
- `log_debug()` - Debug logging
- `audit_log()` - Audit trail entry

**Status**: 🚧 TODO - Extract from source repository

---

### idempotency.sh

**Demonstrates**: Pillar 1 (Idempotency), Pillar 6 (Reversibility)

**Includes**:
- State checking patterns
- Lock file management
- Conditional execution
- State validation
- Safe re-execution patterns
- Rollback mechanisms

**Usage**:
```bash
# Source the pattern
source patterns/idempotency.sh

# Check if action needed
if needs_action; then
    perform_action
fi
```

**Key functions**:
- `check_state()` - Current state validation
- `acquire_lock()` - Prevent concurrent execution
- `release_lock()` - Clean up lock
- `is_idempotent()` - Check if safe to re-run
- `rollback()` - Undo changes

**Status**: 🚧 TODO - Extract from source repository

---

## Using Patterns

### Direct Sourcing

**Source patterns in your scripts**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Source patterns
source "$(dirname "$0")/patterns/error-handling.sh"
source "$(dirname "$0")/patterns/audit-logging.sh"
source "$(dirname "$0")/patterns/idempotency.sh"

# Use pattern functions
log_info "Starting script"

if ! check_state; then
    log_error "Invalid state"
    exit 1
fi

# Your logic here
```

### Copying Functions

**Copy individual functions into your script**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Copied from patterns/audit-logging.sh
log_info() {
    local message="$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] ${message}"
}

# Your script logic
log_info "Script started"
```

### Studying Patterns

**Use patterns as learning tools**:
1. Read the pattern implementation
2. Understand *why* each element exists
3. See how Seven Pillars principles manifest in code
4. Apply lessons to your own scripts

## Combining Patterns

**Most scripts need multiple patterns**:

```bash
#!/usr/bin/env bash
# Production script combining patterns
set -euo pipefail

# Source all needed patterns
source patterns/error-handling.sh
source patterns/audit-logging.sh
source patterns/idempotency.sh

# Setup error handling (Pattern 1)
trap error_handler ERR
trap cleanup_on_exit EXIT

# Check idempotency (Pattern 3)
if ! acquire_lock; then
    log_error "Another instance running"
    exit 1
fi

# Main logic with logging (Pattern 2)
log_info "Starting operation"

if needs_action; then
    perform_action
    log_info "Action completed"
else
    log_info "No action needed (idempotent)"
fi

# Cleanup handled by trap
```

## Pattern Structure

Each pattern file includes:

1. **Header**: Description, usage, Seven Pillars mapping
2. **Configuration**: Constants and defaults
3. **Core Functions**: Main pattern implementation
4. **Helper Functions**: Supporting utilities
5. **Examples**: Usage demonstrations (in comments)
6. **Tests**: Manual test cases (in comments)

## Seven Pillars Mapping

| Pattern | Primary Pillars | Secondary Pillars |
|---------|----------------|-------------------|
| error-handling.sh | 2 (Error Handling) | 7 (Observability) |
| audit-logging.sh | 3 (Audit Logging) | 7 (Observability), 4 (Documentation) |
| idempotency.sh | 1 (Idempotency) | 6 (Reversibility), 5 (Validation) |

## Extending Patterns

**Add your own patterns**:

1. Copy pattern structure
2. Implement your pattern functions
3. Document Seven Pillars mapping
4. Add usage examples
5. Test manually
6. Share back to community

## Testing Patterns

**Manual testing approach**:

```bash
# Test individual pattern
bash patterns/error-handling.sh

# Test in isolation
bash -c 'source patterns/idempotency.sh; check_state'

# Test in your script
./your-script.sh --debug
```

## Related Documentation

- [Seven Pillars](../docs/seven-pillars.md) - Principles patterns implement
- [Bash Discipline](../docs/bash-discipline.md) - Standards patterns follow
- [Templates](../templates/) - Use patterns with templates
- [Validators](../validators/) - Verify pattern compliance

## Contributing Patterns

See [CONTRIBUTING-template.md](../templates/CONTRIBUTING-template.md) for guidelines on contributing new patterns.

New patterns should:
- Map to one or more Seven Pillars
- Include complete documentation
- Provide usage examples
- Pass all validators
- Be tested manually

---

**Next steps**: Extract pattern implementations from rylan-unifi-case-study v5.2.0-production-archive
