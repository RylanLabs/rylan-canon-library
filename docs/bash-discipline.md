# Bash Discipline: Production-Grade Shell Scripting

> Part of rylan-patterns-library
> Extracted from: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)
> Version: v5.2.0-production-archive
> Date: December 19, 2025

## Overview

Bash Discipline defines the standards for production-grade shell scripting. These guidelines balance safety, readability, and maintainability for infrastructure automation. All scripts must follow these standards to ensure consistent, reliable, and maintainable code.

---

## Script Headers

### Required Components

Every bash script must include:

1. **Shebang**: `#!/usr/bin/env bash` - Specifies the interpreter
2. **Purpose**: One-line description of what the script does
3. **Usage**: How to invoke the script with arguments
4. **Strict Mode**: `set -euo pipefail` - Enables safe execution
5. **Author/Date**: Attribution and creation date
6. **Domain**: Functional area (e.g., networking, security, deployment)

### Example Template

```bash
#!/usr/bin/env bash
# Script: deploy-service.sh
# Purpose: Deploy application service to production environment
# Usage: ./deploy-service.sh [--dry-run] <service-name>
# Author: RylanLabs
# Date: 2025-12-19
# Domain: Deployment

set -euo pipefail
IFS=$'\n\t'

# Script implementation...
```

---

## Error Handling

### Strict Mode: `set -euo pipefail`

**Required in all scripts.** Each flag serves a specific purpose:

- **`-e`**: Exit immediately if any command fails
  - Prevents cascading failures
  - Makes errors visible immediately

- **`-u`**: Treat unset variables as errors
  - Catches typos in variable names
  - Prevents silent failures from undefined variables

- **`-o pipefail`**: Pipeline fails if any command in it fails
  - Default bash only checks the last command's exit code
  - This ensures all commands in a pipeline are checked

**Example**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# This will fail if backup.tar.gz doesn't exist (due to -e)
tar -xzf backup.tar.gz

# This will fail if $CONFIG is not set (due to -u)
echo "Config: $CONFIG"

# This will fail if grep finds nothing (due to -o pipefail)
cat logfile.txt | grep "ERROR" | wc -l
```

### Exit Codes

Use standard exit codes for consistency:

| Code | Meaning | Usage |
|------|---------|-------|
| 0 | Success | Command completed successfully |
| 1 | General failure | Generic error condition |
| 2 | Misuse | Invalid arguments or usage |
| 3 | Configuration | Configuration file error |
| 4 | Network | Network-related failure |
| 5 | Permission | Permission denied |
| 126 | Not executable | Command cannot be executed |
| 127 | Not found | Command not found |
| 130 | Terminated | Script terminated by Ctrl+C |

**Example**:
```bash
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE" >&2
  exit 3
fi

if ! ping -c 1 "$HOST" &>/dev/null; then
  echo "Error: Cannot reach host: $HOST" >&2
  exit 4
fi
```

### Error Messages

**Requirements**:
- Output errors to stderr (`>&2`)
- Include context (what failed, why it matters)
- Provide remediation steps when possible
- Use consistent formatting

**Example**:
```bash
error_exit() {
  local message="$1"
  local exit_code="${2:-1}"

  echo "❌ ERROR: $message" >&2

  if [[ -n "${3:-}" ]]; then
    echo "   Fix: $3" >&2
  fi

  exit "$exit_code"
}

# Usage
[[ -r "$CONFIG" ]] || error_exit "Cannot read config" 3 "Check file permissions: chmod 644 $CONFIG"
```

### Cleanup on Exit

Use `trap` to ensure cleanup happens even on error:

```bash
#!/usr/bin/env bash
set -euo pipefail

TEMP_FILE=""

cleanup() {
  if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
    rm -f "$TEMP_FILE"
    echo "Cleaned up temporary file" >&2
  fi
}

trap cleanup EXIT

# Create temp file
TEMP_FILE=$(mktemp)
echo "Working with $TEMP_FILE"

# Cleanup happens automatically on exit, even on error
```

---

## Function Design

### Naming Conventions

**Rules**:
- Use lowercase with underscores (snake_case)
- Descriptive names that indicate action
- Avoid reserved words and special characters
- Prefix private functions with underscore

**Examples**:
```bash
# Good
validate_input() { ... }
deploy_service() { ... }
_internal_helper() { ... }

# Bad
ValidateInput() { ... }  # CamelCase not used in bash
vi() { ... }  # Conflicts with editor
deploy-service() { ... }  # Dashes problematic
```

### Parameter Handling

**Best practices**:
- Validate all parameters
- Use local variables for function scope
- Document expected parameters
- Provide clear error messages for invalid input

**Example**:
```bash
deploy_service() {
  local service_name="${1:-}"
  local environment="${2:-production}"

  # Validate required parameters
  if [[ -z "$service_name" ]]; then
    echo "Error: service_name required" >&2
    return 2
  fi

  # Validate parameter values
  if [[ ! "$environment" =~ ^(dev|staging|production)$ ]]; then
    echo "Error: Invalid environment: $environment" >&2
    return 2
  fi

  # Implementation...
  echo "Deploying $service_name to $environment"
}
```

### Return Values

**Convention**:
- Return 0 for success
- Return non-zero for failure
- Use specific codes for different failure types
- Echo output for values, use return for status

**Example**:
```bash
get_service_status() {
  local service="$1"

  if systemctl is-active "$service" &>/dev/null; then
    echo "running"
    return 0
  else
    echo "stopped"
    return 1
  fi
}

# Usage
status=$(get_service_status "nginx")
if [[ $? -eq 0 ]]; then
  echo "Service is $status"
fi
```

### Function Documentation

Use inline comments to document:
- Purpose of the function
- Expected parameters
- Return values and exit codes
- Side effects or requirements

**Example**:
```bash
#######################################
# Deploy service to specified environment
# Globals:
#   DEPLOY_ROOT - Base deployment directory
# Arguments:
#   $1 - Service name (required)
#   $2 - Environment (default: production)
# Returns:
#   0 on success, 1 on failure
# Outputs:
#   Deployment status to stdout
#######################################
deploy_service() {
  local service_name="${1:-}"
  local environment="${2:-production}"

  # Implementation...
}
```

---

## Variable Naming

### Conventions

**Rules**:
- Lowercase with underscores for local variables
- UPPERCASE for constants and environment variables
- Descriptive names, avoid abbreviations
- Use `readonly` for constants

**Examples**:
```bash
# Local variables
local service_name="nginx"
local retry_count=3

# Constants
readonly MAX_RETRIES=5
readonly CONFIG_DIR="/etc/myapp"

# Environment variables
export DATABASE_URL="postgres://localhost/db"
```

### Scope Management

**Best practices**:
- Use `local` for function variables
- Minimize global variables
- Declare variables at the top of functions
- Use `readonly` to prevent modification

**Example**:
```bash
# Global (avoid when possible)
GLOBAL_CONFIG="/etc/app.conf"

process_data() {
  # Local variables
  local input_file="$1"
  local output_file="/tmp/output.txt"
  local -i line_count=0

  # Process with local scope
  while IFS= read -r line; do
    ((line_count++))
    echo "$line" >> "$output_file"
  done < "$input_file"

  echo "Processed $line_count lines"
}
```

### Constants

Declare constants with `readonly`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"
readonly CONFIG_FILE="/etc/myapp/config.yaml"

# Attempting to modify will cause error
# CONFIG_FILE="/tmp/other.yaml"  # Error: CONFIG_FILE: readonly variable
```

---

## ShellCheck Compliance

### Enabled Rules

**All scripts must pass ShellCheck with no warnings.**

Run ShellCheck:
```bash
shellcheck -x script.sh
```

Common checks:
- Quote variables to prevent word splitting
- Use `[[ ]]` instead of `[ ]` for tests
- Check command existence before use
- Validate array access
- Proper error handling

### Exceptions

**Rarely needed**, but when necessary:

```bash
# Disable specific warning with justification
# shellcheck disable=SC2034  # Variable used in sourced file
SHARED_CONFIG="value"

# Disable for one line
export PATH="$PATH:$HOME/bin"  # shellcheck disable=SC2086

# Disable multiple rules
# shellcheck disable=SC2034,SC2154
LEGACY_VAR="compatibility"
```

**Document why** you're disabling a check.

### Running ShellCheck

**Integration with validators**:
```bash
# Run on single file
./validators/shellcheck-wrapper.sh script.sh

# Run on all scripts
./validators/shellcheck-wrapper.sh scripts/*.sh

# CI/CD integration
shellcheck -x -f gcc **/*.sh
```

---

## Documentation Standards

### Script Documentation

**Header template** (required):
```bash
#!/usr/bin/env bash
# Script: backup-database.sh
# Purpose: Create encrypted backup of production database
# Usage: ./backup-database.sh [--compress] <database-name>
#
# Creates timestamped backup in /var/backups/db/
# Encrypts using GPG key from BACKUP_GPG_KEY env var
# Retains last 7 days of backups automatically
#
# Options:
#   --compress    Compress backup with gzip
#   -h, --help    Show this help
#
# Examples:
#   ./backup-database.sh production_db
#   ./backup-database.sh --compress staging_db
#
# Author: RylanLabs
# Date: 2025-12-19
```

### Inline Comments

**Guidelines**:
- Explain *why*, not *what*
- Comment complex logic
- Avoid obvious comments
- Keep comments up-to-date with code

**Examples**:
```bash
# Good - explains why
# Retry on failure because network can be flaky during deployments
for i in {1..3}; do
  if curl "$URL"; then break; fi
  sleep 5
done

# Bad - obvious
# Loop from 1 to 3
for i in {1..3}; do
  ...
done

# Good - explains non-obvious behavior
# Use process substitution to avoid subshell
# (allows variable modification in while loop)
while IFS= read -r line; do
  ((count++))
done < <(find . -type f)
```

### Usage Examples

**Provide help text**:
```bash
usage() {
  cat << EOF
Usage: ${SCRIPT_NAME} [options] <service-name>

Deploy service to specified environment.

Options:
  -e, --environment ENV   Target environment (dev|staging|prod)
  -d, --dry-run          Show what would be done
  -h, --help             Show this help

Examples:
  $SCRIPT_NAME web-api
  $SCRIPT_NAME --environment staging auth-service
  $SCRIPT_NAME --dry-run frontend

EOF
}
```

---

## Code Organization

### Script Structure

**Standard layout**:
```bash
#!/usr/bin/env bash
# Header documentation (as above)

set -euo pipefail
IFS=$'\n\t'

# 1. Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="/etc/app.conf"

# 2. Global variables (minimize)
VERBOSE=false
DRY_RUN=false

# 3. Helper functions
log() { echo "[$(date -Iseconds)] $*" >&2; }
error_exit() { echo "Error: $*" >&2; exit 1; }

# 4. Core functions
validate_environment() { ... }
deploy_service() { ... }

# 5. Cleanup
cleanup() { ... }
trap cleanup EXIT

# 6. Main logic
main() {
  parse_args "$@"
  validate_environment
  deploy_service
}

# 7. Execute
main "$@"
```

### Sourcing Patterns

**Including shared code**:
```bash
# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Check if file exists before sourcing
if [[ -f "$SCRIPT_DIR/config.sh" ]]; then
  source "$SCRIPT_DIR/config.sh"
fi

# Source with error handling
source "$SCRIPT_DIR/lib/helpers.sh" || {
  echo "Error: Cannot load helpers" >&2
  exit 1
}
```

### Module Design

**Break large scripts into modules**:

```
project/
├── main.sh              # Entry point
├── lib/
│   ├── common.sh        # Shared functions
│   ├── validation.sh    # Input validation
│   └── deployment.sh    # Deployment logic
└── config/
    └── defaults.sh      # Default configuration
```

**Example lib/common.sh**:
```bash
#!/usr/bin/env bash
# Common utility functions

log_info() {
  echo "[$(date -Iseconds)] [INFO] $*"
}

log_error() {
  echo "[$(date -Iseconds)] [ERROR] $*" >&2
}

# Don't execute if sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This file should be sourced, not executed" >&2
  exit 1
fi
```

---

## Testing Patterns

### Manual Testing

**Validation checklist**:
- Test with valid inputs
- Test with invalid inputs (should fail gracefully)
- Test with missing arguments
- Test idempotency (run twice, same result)
- Test cleanup on success and failure
- Test with different user permissions

**Example test script**:
```bash
#!/usr/bin/env bash
# test_deploy.sh - Manual tests for deploy script

set -euo pipefail

echo "Test 1: Valid deployment"
./deploy.sh web-api || echo "FAIL"

echo "Test 2: Invalid service name"
./deploy.sh invalid-service && echo "FAIL" || echo "PASS"

echo "Test 3: Missing arguments"
./deploy.sh && echo "FAIL" || echo "PASS"

echo "Test 4: Dry run mode"
./deploy.sh --dry-run web-api || echo "FAIL"

echo "All tests complete"
```

### Validation Workflows

**Pre-commit validation**:
```bash
# Run validators before committing
./validators/validate-bash-headers.sh scripts/*.sh
./validators/shellcheck-wrapper.sh scripts/*.sh
./validators/validate-seven-pillars.sh scripts/*.sh
```

**Continuous validation**:
- Run ShellCheck in CI/CD
- Test scripts in clean environments
- Verify idempotency
- Check for security issues

---

## Common Patterns

See [`../patterns/`](../patterns/) directory for complete implementations:

- **[error-handling.sh](../patterns/error-handling.sh)** - Error traps, exit codes, cleanup
- **[audit-logging.sh](../patterns/audit-logging.sh)** - Structured logging, audit trails
- **[idempotency.sh](../patterns/idempotency.sh)** - State checking, safe re-execution

**Quick reference**:
```bash
# Error handling pattern
set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR
trap cleanup EXIT

# Logging pattern
log() { echo "[$(date -Iseconds)] $*" >&2; }

# Idempotency pattern
if [[ ! -f "/etc/configured" ]]; then
  perform_configuration
  touch "/etc/configured"
fi
```

---

**See also**: [`../patterns/`](../patterns/) for implementation examples
