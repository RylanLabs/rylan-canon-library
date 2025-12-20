# Validators

> Part of rylan-patterns-library  
> Extracted from: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)  
> Version: v∞.5.2-production-archive  
> Date: December 19, 2025

**Status**: 🚧 Content extraction in progress

---

## Overview

This directory contains manual validation scripts for code quality checks. These validators embody the **IRL-First philosophy**: they are meant to be run manually by developers who understand them, not as automated gates (yet).

## Philosophy

**Manual validation before automated enforcement.**

These scripts are tools *for you*, not gates blocking *you*. Run them when they're helpful:
- Before committing significant changes
- When learning new patterns
- Before pull requests
- As part of code review

**Not intended** (initially) as:
- Pre-commit hooks
- CI/CD gates
- Blocking automation

## Available Validators

### validate-bash-headers.sh

**Purpose**: Check bash scripts for complete, standardized headers.

**Validates**:
- Shebang presence (`#!/usr/bin/env bash`)
- Script description
- Usage information
- Set flags (`set -euo pipefail`)

**Usage**:
```bash
./validators/validate-bash-headers.sh path/to/script.sh
./validators/validate-bash-headers.sh scripts/*.sh
```

**Example output**:
```
✓ script1.sh: Header valid
✗ script2.sh: Missing usage information
✗ script3.sh: Missing set -euo pipefail
```

**Status**: 🚧 TODO - Extract from source repository

---

### validate-seven-pillars.sh

**Purpose**: Verify scripts demonstrate Seven Pillars compliance.

**Checks for**:
1. **Idempotency**: State checking before actions
2. **Error Handling**: Explicit exit codes and error messages
3. **Audit Logging**: Execution logging with timestamps
4. **Documentation**: Headers and inline comments
5. **Validation**: Input validation logic
6. **Reversibility**: Backup or rollback capability
7. **Observability**: Progress reporting

**Usage**:
```bash
./validators/validate-seven-pillars.sh path/to/script.sh
./validators/validate-seven-pillars.sh --strict scripts/*.sh
```

**Modes**:
- Default: Warnings for missing pillars
- `--strict`: Errors for missing pillars
- `--explain`: Show why each check passed/failed

**Status**: 🚧 TODO - Extract from source repository

---

### shellcheck-wrapper.sh

**Purpose**: Run ShellCheck with custom rules and rylan-patterns-library conventions.

**Features**:
- Runs standard ShellCheck validation
- Applies custom exclusions for known patterns
- Formats output for readability
- Provides fix suggestions

**Usage**:
```bash
./validators/shellcheck-wrapper.sh script.sh
./validators/shellcheck-wrapper.sh --fix scripts/*.sh
```

**Configuration**:
- Embedded exclusions for legitimate patterns
- Severity filtering
- Integration with editors (via LSP)

**Status**: 🚧 TODO - Extract from source repository

---

## Running Validators

### Manual Workflow

**Before committing**:
```bash
# Validate headers
./validators/validate-bash-headers.sh scripts/*.sh

# Check Seven Pillars compliance
./validators/validate-seven-pillars.sh scripts/*.sh

# Run ShellCheck
./validators/shellcheck-wrapper.sh scripts/*.sh
```

**Review output, fix issues, iterate.**

### Integration with Development

**Editor integration** (optional):
- Configure ShellCheck in VS Code, vim, etc.
- Use shellcheck-wrapper.sh as the checker command
- Get real-time feedback while coding

**Pre-commit checklist** (manual):
- [ ] All scripts have valid headers
- [ ] Seven Pillars checks pass
- [ ] ShellCheck reports no errors
- [ ] Manual testing complete

## Understanding Validator Output

### Exit Codes

All validators follow standard exit code conventions:
- `0`: All checks passed
- `1`: Validation warnings (review recommended)
- `2`: Validation errors (fixes required)
- `3+`: Internal validator error

### Output Format

```
[✓|✗] filename.sh: Check description
  └─ Details or suggestions if check failed
```

### Common Issues

<!-- TODO: Document frequent validation failures and fixes -->

## Customizing Validators

All validators are bash scripts you can read and modify:
- Adjust strictness levels
- Add project-specific checks
- Customize output formatting
- Integrate with your workflow

**Remember**: These are reference implementations. Adapt them to your needs.

## Future: Automation

**Current state**: Manual execution  
**Future state**: Gradual automation

Once manual validation becomes habit:
1. Add as optional pre-commit hooks
2. Integrate into CI (non-blocking initially)
3. Gather data on compliance trends
4. Make enforcement decisions based on team understanding

**Philosophy**: Automate only after manual discipline is established.

## Related Documentation

- [Seven Pillars](../docs/seven-pillars.md) - Principles being validated
- [Bash Discipline](../docs/bash-discipline.md) - Standards being checked
- [IRL-First Approach](../docs/irl-first-approach.md) - Why manual validation first
- [Templates](../templates/) - Starting points that pass validation

---

**Next steps**: Extract validator implementations from rylan-unifi-case-study v∞.5.2-production-archive
