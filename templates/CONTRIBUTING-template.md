# Contributing Guidelines

> Based on [rylan-patterns-library](https://github.com/RylanLabs/rylan-patterns-library)
> Principles: Seven Pillars, IRL-First, No Bypass Culture

---

## Welcome

Thank you for considering contributing to this project! We follow discipline-first principles from rylan-patterns-library to ensure production-grade code quality.

## Philosophy

**Manual discipline before automated enforcement.**

We believe developers who understand *why* patterns exist write better code than those who merely comply with automated gates. Our contribution process emphasizes:

- **Understanding** principles over following rules
- **Manual validation** before automated enforcement
- **Educational** feedback over blocking gates
- **Sustainable** discipline over rigid compliance

## Code of Conduct

<!-- TODO: Add code of conduct or link to one -->

Be respectful, constructive, and collaborative.

## Getting Started

### 1. Familiarize Yourself

Before contributing, review:

- **Seven Pillars**: [rylan-patterns-library/docs/seven-pillars.md](https://github.com/RylanLabs/rylan-patterns-library/blob/main/docs/seven-pillars.md)
- **Bash Discipline**: [rylan-patterns-library/docs/bash-discipline.md](https://github.com/RylanLabs/rylan-patterns-library/blob/main/docs/bash-discipline.md)
- **IRL-First Approach**: [rylan-patterns-library/docs/irl-first-approach.md](https://github.com/RylanLabs/rylan-patterns-library/blob/main/docs/irl-first-approach.md)

### 2. Set Up Development Environment

```bash
# Clone repository
git clone <repository-url>
cd <project-directory>

# TODO: Add project-specific setup steps

# Install ShellCheck (optional, for validation)
# Ubuntu/Debian: sudo apt-get install shellcheck
# macOS: brew install shellcheck
```

### 3. Find an Issue

- Browse [open issues](../../issues)
- Look for `good first issue` labels
- Or propose a new feature/improvement

## Contribution Process

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Changes

**Follow Seven Pillars**:

1. **Idempotency**: Safe to run multiple times
2. **Error Handling**: Explicit exit codes and error messages
3. **Audit Logging**: Observable execution
4. **Documentation**: Clear headers and inline comments
5. **Validation**: Input checking
6. **Reversibility**: Backup/rollback capability
7. **Observability**: Progress reporting

**Bash scripts must include**:
- Proper shebang: `#!/usr/bin/env bash`
- Strict mode: `set -euo pipefail`
- Header with description, usage, examples
- Error handling with cleanup traps
- Audit logging with timestamps
- Input validation

**Use templates** from rylan-patterns-library:
```bash
cp path/to/rylan-patterns-library/templates/script-template.sh new-script.sh
# Customize for your use case
```

### 3. Validate Your Changes

**Run validators manually** (from rylan-patterns-library):

```bash
# Validate bash headers
./validators/validate-bash-headers.sh scripts/your-script.sh

# Check Seven Pillars compliance
./validators/validate-seven-pillars.sh scripts/your-script.sh

# Run ShellCheck
./validators/shellcheck-wrapper.sh scripts/your-script.sh
```

**Fix issues** until all validators pass.

**Manual testing**:
```bash
# Test happy path
./scripts/your-script.sh <valid-args>

# Test error cases
./scripts/your-script.sh <invalid-args>

# Test idempotency (run twice)
./scripts/your-script.sh <args>
./scripts/your-script.sh <args>  # Should be safe
```

### 4. Document Your Changes

- Update README.md if adding features
- Add inline comments explaining *why*, not just *what*
- Update usage examples if command-line interface changes
- Document any new dependencies

### 5. Commit Your Changes

**Commit message format**:
```
<type>: <short description>

<Detailed explanation of changes>

- What changed
- Why it changed
- Any breaking changes or considerations

Validates:
- validate-bash-headers.sh: ✓
- validate-seven-pillars.sh: ✓
- shellcheck-wrapper.sh: ✓
```

**Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Create pull request with:
- Clear title and description
- Reference related issues
- List validation results
- Describe testing performed

## Pull Request Review

### What Reviewers Look For

**Code quality**:
- Seven Pillars compliance
- Bash discipline standards
- Clear documentation
- Proper error handling

**Testing**:
- Manual testing performed
- Edge cases considered
- Idempotency verified

**Validation**:
- All validators pass
- ShellCheck clean
- No obvious security issues

### Review Process

1. **Automated checks**: (if configured) Basic validation
2. **Manual review**: Maintainer reviews code and principles
3. **Feedback**: Educational feedback on improvements
4. **Iteration**: Address feedback, update PR
5. **Approval**: Once ready, PR is approved
6. **Merge**: Maintainer merges to main branch

**Philosophy**: Reviews are educational, not gatekeeping. We provide feedback to help you understand principles, not just comply with rules.

## Validation Checklist

Before submitting PR, verify:

- [ ] All bash scripts have proper headers
- [ ] `set -euo pipefail` present in all scripts
- [ ] Error handling with cleanup traps implemented
- [ ] Audit logging with timestamps added
- [ ] Input validation included
- [ ] Scripts tested manually (happy path + errors)
- [ ] Idempotency verified (safe to run twice)
- [ ] Documentation updated (README, inline comments)
- [ ] `validate-bash-headers.sh` passes
- [ ] `validate-seven-pillars.sh` passes
- [ ] `shellcheck-wrapper.sh` passes
- [ ] Commit messages follow format

## Questions?

- Check [rylan-patterns-library documentation](https://github.com/RylanLabs/rylan-patterns-library/tree/main/docs)
- Open an issue for discussion
- Ask in pull request comments

<!-- TODO: Add project-specific contact information -->

---

**Thank you for contributing with discipline!**

*Based on principles from [RylanLabs Pattern Library](https://github.com/RylanLabs/rylan-patterns-library)*
