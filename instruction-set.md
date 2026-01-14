# Pattern Library Instructions

> Part of rylan-patterns-library
> Extracted from: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)
> Version: v1.0.0
> Date: December 19, 2025

---

## Philosophy

**IRL-First, Manual Before Automation**

This pattern library embodies a core principle: **manual discipline precedes automated enforcement**. The patterns, validators, and templates here are designed to be:

1. **Understood by humans** before being enforced by machines
2. **Run manually** as part of a deliberate development workflow
3. **Educational** rather than purely regulatory
4. **Flexible** to accommodate legitimate exceptions

We believe that developers who understand *why* patterns exist will write better code than those who merely comply with automated gates.

## Core Principles

### Seven Pillars

The foundation of all patterns in this library. Seven core principles for production-grade infrastructure:

→ **Full documentation**: [`docs/seven-pillars.md`](docs/seven-pillars.md)

Brief overview:

1. **Idempotency**: Safe to run multiple times
2. **Error Handling**: Explicit exit codes and error messages
3. **Audit Logging**: Observable execution and decision points
4. **Documentation**: Clear headers, usage, and inline comments
5. **Validation**: Input checking and pre-flight validation
6. **Reversibility**: Backup and rollback capabilities
7. **Observability**: Progress reporting and debugging information

### Hellodeolu v6

Discipline architecture and framework that guided the evolution of these patterns.

→ **Full documentation**: [`docs/hellodeolu-v6.md`](docs/hellodeolu-v6.md)

Key concepts:
- Layered discipline development (v1 → v6)
- Integration of discipline systems
- Manual validation before automation
- Human-in-the-loop decision making

### No Bypass Culture

Why shortcuts and workarounds undermine system integrity, and how to build a culture of compliance without enforcement overhead.

→ **Full documentation**: [`docs/no-bypass-culture.md`](docs/no-bypass-culture.md)

Core tenets:
- Make the right way the easy way
- Document *why* rules exist
- Provide escape hatches with accountability
- Lead by example

### IRL-First Approach

Human validation precedes automated enforcement. Real understanding before rigid rules.

→ **Full documentation**: [`docs/irl-first-approach.md`](docs/irl-first-approach.md)

Process:
1. Learn principles manually
2. Practice patterns with feedback
3. Validate understanding
4. Gradually introduce automation
5. Maintain human oversight

### Bash Discipline

Standards for production-grade shell scripting that balance safety, readability, and maintainability.

→ **Full documentation**: [`docs/bash-discipline.md`](docs/bash-discipline.md)

Includes:
- Script header standards
- Error handling patterns (`set -euo pipefail`)
- Function design guidelines
- Variable naming conventions
- ShellCheck compliance

## Using Validators

Manual validation scripts for code quality checks.

→ **Full documentation**: [`validators/README.md`](validators/README.md)

**Available validators**:
- `validate-bash-headers.sh` - Check script headers for completeness
- `validate-seven-pillars.sh` - Verify Seven Pillars compliance
- `shellcheck-wrapper.sh` - Run ShellCheck with custom rules

**Usage pattern**:
```bash
# Run before committing
./validators/validate-bash-headers.sh scripts/*.sh
./validators/shellcheck-wrapper.sh scripts/*.sh

# Review output, fix issues, iterate
```

**Philosophy**: These are tools for *you*, not gates blocking *you*. Run them when they're helpful.

## Using Templates

Starting templates for new repositories and scripts.

→ **Full documentation**: [`templates/README.md`](templates/README.md)

**Available templates**:
- `script-template.sh` - Production bash script with proper structure
- `README-template.md` - Repository README with attribution
- `CONTRIBUTING-template.md` - Contribution guidelines

**Usage pattern**:
```bash
# Copy template
cp templates/script-template.sh my-new-script.sh

# Customize placeholders
# - Replace <SCRIPT_NAME>
# - Fill in <DESCRIPTION>
# - Add your logic

# Follow patterns in patterns/ directory
```

## Using Patterns

Reusable bash patterns demonstrating Seven Pillars in practice.

→ **Full documentation**: [`patterns/README.md`](patterns/README.md)

**Available patterns**:
- `error-handling.sh` - Exit codes, error messages, cleanup
- `audit-logging.sh` - Structured logging and observability
- `idempotency.sh` - State checking and safe re-execution

**Usage pattern**:
```bash
# Source patterns directly
source patterns/error-handling.sh
source patterns/audit-logging.sh

# Or copy pattern functions into your script
# Study the implementation to understand the "why"
```

## Directory Structure

```
rylan-patterns-library/
├── README.md              # Overview and purpose
├── .gitignore            # Ignore patterns
├── .agent.md             # Assistant behavior guide
├── .github/
│   ├── agents/           # Agent configuration files
│   └── instructions/     # Instruction sets
├── instruction-set.md    # This file
├── docs/                 # Principle documentation
├── validators/           # Manual validation scripts
├── templates/            # Project templates
└── patterns/             # Reusable code patterns
```

## Integration Workflow

**Recommended process for using this library**:

1. **Study principles**: Read `docs/` to understand the "why"
2. **Review patterns**: Examine `patterns/` for implementation examples
3. **Start from template**: Copy appropriate template from `templates/`
4. **Build with patterns**: Implement using pattern examples
5. **Validate manually**: Run validators from `validators/`
6. **Iterate**: Fix issues, deepen understanding, refine

## Notes

- **This is a reference library**, not a framework or package
- **No automated enforcement** - that's intentional
- **Manual discipline first** - automation comes later
- **Copy, don't import** - these are learning tools
- **Understand, don't comply** - know the reasons

## Source Attribution

All content extracted from [rylan-unifi-case-study v1.0.0](https://github.com/RylanLabs/rylan-unifi-case-study), a production repository with 344 commits representing real-world infrastructure automation.

The original system included extensive CI/CD automation (32 checks), Gatekeeper enforcement, and Trinity agent systems. Those are **intentionally excluded** from this library—we're extracting the underlying patterns and principles, not the enforcement machinery.

---

**Next steps**: Content extraction from source repository in progress.
