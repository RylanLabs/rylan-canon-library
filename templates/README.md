# Templates

> Part of rylan-patterns-library  
> Extracted from: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)  
> Version: v5.2.0-production-archive  
> Date: December 19, 2025

**Status**: 🚧 Content extraction in progress

---

## Overview

This directory contains starting templates for new repositories, scripts, and documentation. These templates embody Seven Pillars principles and provide a solid foundation for production-grade code.

## Philosophy

**Start right, not perfect.**

These templates provide:
- **Proper structure** from the beginning
- **Seven Pillars compliance** built-in
- **Customization points** clearly marked
- **Documentation standards** demonstrated

Use them as starting points, then adapt to your specific needs.

## Available Templates

### script-template.sh

**Purpose**: Production bash script with complete structure.

**Includes**:
- Standardized header with metadata
- Strict mode (`set -euo pipefail`)
- Error handling framework
- Usage function and help text
- Input validation structure
- Audit logging placeholders
- Main function pattern

**Usage**:
```bash
cp templates/script-template.sh my-new-script.sh
# Customize placeholders:
# - <SCRIPT_NAME>
# - <DESCRIPTION>
# - <USAGE_PATTERN>
# Add your implementation logic
```

**Passes validators**:
- ✓ validate-bash-headers.sh
- ✓ shellcheck-wrapper.sh
- ⚠ validate-seven-pillars.sh (add your logic to complete)

**Status**: 🚧 TODO - Extract from source repository

---

### README-template.md

**Purpose**: Repository README with proper attribution and structure.

**Includes**:
- Clear purpose statement
- Installation/setup instructions
- Usage examples
- Project structure overview
- Attribution to rylan-patterns-library
- Contributing guidelines reference
- License information

**Usage**:
```bash
cp templates/README-template.md ../your-new-repo/README.md
# Customize:
# - Project name and purpose
# - Installation steps
# - Usage examples
# - Repository-specific sections
```

**Demonstrates**:
- Clear documentation (Pillar 4)
- Proper attribution
- User-friendly structure

**Status**: 🚧 TODO - Extract from source repository

---

### CONTRIBUTING-template.md

**Purpose**: Contribution guidelines for repositories using rylan-patterns.

**Includes**:
- Code style requirements
- Seven Pillars compliance expectations
- Validation workflow (running validators)
- Pull request process
- Review criteria
- Attribution requirements

**Usage**:
```bash
cp templates/CONTRIBUTING-template.md ../your-new-repo/CONTRIBUTING.md
# Customize:
# - Project-specific requirements
# - Review process details
# - Contact information
```

**Demonstrates**:
- Clear expectations
- Validation workflow
- No Bypass Culture principles

**Status**: 🚧 TODO - Extract from source repository

---

## Using Templates

### Quick Start

**1. Copy template**:
```bash
cp templates/script-template.sh my-script.sh
```

**2. Replace placeholders**:
```bash
# Search for: <SCRIPT_NAME>, <DESCRIPTION>, <USAGE_PATTERN>
# Replace with your actual values
```

**3. Add implementation**:
```bash
# Fill in main() function
# Add helper functions as needed
# Implement validation logic
```

**4. Validate**:
```bash
./validators/validate-bash-headers.sh my-script.sh
./validators/shellcheck-wrapper.sh my-script.sh
./validators/validate-seven-pillars.sh my-script.sh
```

**5. Iterate** until validators pass.

### Customization Points

Templates include marked customization points:

**In bash scripts**:
```bash
# TODO: Add your validation logic here
# TODO: Implement main functionality
# TODO: Add cleanup logic
```

**In markdown**:
```markdown
<!-- TODO: Describe your project -->
<!-- TODO: Add installation steps -->
<!-- TODO: Provide usage examples -->
```

### Adding Your Logic

Templates provide **structure**, you provide **implementation**:

1. **Keep the structure**: Headers, error handling, validation patterns
2. **Add your logic**: Within the provided functions and sections
3. **Maintain compliance**: Don't remove Seven Pillars elements
4. **Document changes**: Update comments and usage information

## Template Philosophy

### What Templates Are

- **Starting points** for production-grade code
- **Examples** of Seven Pillars implementation
- **Customizable** foundations you own
- **Teaching tools** for best practices

### What Templates Are NOT

- **Rigid frameworks** you must follow exactly
- **Complete solutions** without your input
- **Automated generators** that write code for you
- **Restrictive** barriers to creativity

## Validation

All templates are designed to pass validators:

**Script templates pass**:
- validate-bash-headers.sh (immediately)
- shellcheck-wrapper.sh (immediately)
- validate-seven-pillars.sh (after you add logic)

**Document templates demonstrate**:
- Clear documentation standards
- Proper attribution
- User-friendly structure

## Integration with Patterns

**Combine templates with patterns**:

```bash
# Copy template
cp templates/script-template.sh my-script.sh

# Source patterns for implementation
# (See patterns/README.md)
# - error-handling.sh for error patterns
# - audit-logging.sh for logging
# - idempotency.sh for state checking
```

Templates provide structure, patterns provide implementation examples.

## Related Documentation

- [Bash Discipline](../docs/bash-discipline.md) - Standards templates follow
- [Seven Pillars](../docs/seven-pillars.md) - Principles templates embody
- [Patterns](../patterns/) - Implementation examples to combine with templates
- [Validators](../validators/) - Tools to verify your customized templates

---

**Next steps**: Extract template implementations from rylan-unifi-case-study v5.2.0-production-archive
