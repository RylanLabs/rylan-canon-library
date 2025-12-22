# Pre-Commit Hook Setup

> Enable LOCAL GREEN = CI GREEN — Automatic validation on every commit

## Overview

Pre-commit hooks automatically run RylanLabs validators (Python, Bash, YAML, Ansible) before each commit. This ensures code quality gates are met before pushing to GitHub, where CI would catch them anyway.

**Benefit**: Catch errors locally in <30 seconds instead of waiting for GitHub Actions.

---

## Installation

### Prerequisites
- Git installed
- Python 3.11+
- Pre-commit package

### Setup (One-Time)

```bash
# 1. Install pre-commit package
pip install pre-commit

# 2. Navigate to project directory
cd /path/to/your/project

# 3. Install hooks
pre-commit install

# Expected output:
# Installing pre-commit into .git/hooks/pre-commit
# A .git/hooks directory will be created if it doesn't exist
```

### Verify Installation

```bash
# Check if hooks are installed
ls -la .git/hooks/pre-commit

# Expected: -rwxr-xr-x (executable)
```

---

## Usage

### Automatic (Default)

Hooks run automatically on every `git commit`:

```bash
# Make changes
echo "# New feature" >> scripts/my-script.py

# Stage changes
git add scripts/my-script.py

# Commit (hooks run automatically)
git commit -m "feat: Add new feature"

# Hooks execute:
# - Python validator (mypy, ruff, bandit)
# - Bash validator (shellcheck, shfmt)
# - YAML validator (yamllint)
# - Ansible validator (if playbooks/ exists)

# If all pass: commit succeeds
# If any fail: commit blocked, see error output
```

### Manual Validation

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run validate-python --all-files

# Run hooks on changed files only (default)
pre-commit run
```

### Dry-Run (Preview Changes)

```bash
# See what would be validated
pre-commit run --all-files --verbose

# See detailed output
pre-commit run validate-python --all-files --verbose
```

---

## Common Workflows

### Before Committing

```bash
# 1. Make your changes
vim scripts/my-script.sh

# 2. Stage changes
git add scripts/my-script.sh

# 3. Commit (hooks run automatically)
git commit -m "fix: Improve my-script.sh"

# If hooks fail:
# - Review error output
# - Fix issues
# - Stage changes
# - Try commit again
```

### Debugging a Failing Hook

```bash
# 1. Run failing hook manually with verbose output
pre-commit run validate-bash --all-files --verbose

# 2. Review the error message
# Example: "ShellCheck: SC2086 (Double quote variables)"

# 3. Fix the issue
# Example: Change $var to "$var"

# 4. Stage fixed files
git add scripts/fixed-file.sh

# 5. Try committing again
git commit -m "fix: Address ShellCheck warning"
```

### Bypass Hooks (Emergency Only)

⚠️ **NOT RECOMMENDED** - Violates No Bypass Culture

If you absolutely must bypass hooks (e.g., emergency fix):

```bash
git commit --no-verify -m "emergency: Bypass hooks"
```

**Important**: You MUST acknowledge in your commit message that you bypassed validation.

---

## Troubleshooting

### Issue: "pre-commit: command not found"

**Solution**: Install pre-commit globally

```bash
pip install --user pre-commit

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

### Issue: Hooks not running on commit

**Solution**: Reinstall hooks

```bash
pre-commit uninstall && pre-commit install
```

### Issue: Hook fails but I think the error is wrong

**Solution**: Run the hook manually to inspect

```bash
# Run the validator directly
bash scripts/validate-python.sh

# This shows you exactly what the hook is checking
```

### Issue: Hook changes my files (e.g., formatting)

**Solution**: This is intentional! Stage and commit the changes:

```bash
# Example: ruff auto-formats your Python
# After pre-commit run:
git add scripts/my-script.py
git commit -m "chore: Auto-format with ruff"
```

### Issue: Pre-commit is very slow

**Solution**: Run only on changed files instead of all files:

```bash
# Default: runs on changed files only
pre-commit run

# Don't use --all-files for every commit
# Use it only when you need to validate everything
pre-commit run --all-files  # Slower, but comprehensive
```

---

## Customization

### Disable a Specific Hook (Temporarily)

Edit `.pre-commit-config.yaml` and set `stages: []`:

```yaml
- id: validate-ansible
  stages: []  # Disabled
```

Then reinstall:

```bash
pre-commit install
```

### Disable All Hooks (Temporarily)

```bash
pre-commit uninstall
# ... do work without hooks
pre-commit install  # Re-enable
```

### Update Hook Versions

```bash
pre-commit autoupdate

# Review changes
git diff .pre-commit-config.yaml

# Commit if satisfied
git add .pre-commit-config.yaml
git commit -m "chore: Update pre-commit hook versions"
```

---

## Integration with IDE

### VS Code

Install the "pre-commit" extension:

```
ext install idleberg.pre-commit
```

Then you'll see pre-commit validation inline.

### PyCharm / IntelliJ

Go to Settings > Tools > Python Integrated Tools > Default Test Runner and select "pytest".

Pre-commit will integrate automatically.

---

## Best Practices

1. **Always fix locally first**: Run hooks before committing
2. **Read error messages carefully**: They tell you exactly what's wrong
3. **Don't bypass**: `--no-verify` defeats the purpose
4. **Keep hooks fast**: Don't add slow checks to pre-commit
5. **Test changes**: `pre-commit run --all-files` before pushing
6. **Document exceptions**: If you disable a hook, document why

---

## Reference

| Command | Purpose |
|---------|---------|
| `pre-commit install` | Setup hooks |
| `pre-commit run` | Run on changed files |
| `pre-commit run --all-files` | Run on all files |
| `pre-commit run [hook-id] --all-files` | Run specific hook |
| `pre-commit uninstall` | Remove hooks |
| `pre-commit autoupdate` | Update hook versions |
| `git commit --no-verify` | Bypass hooks (not recommended) |

---

## Compliance

✅ Seven Pillars: Idempotency, Error Handling, Functionality, Audit Logging, Failure Recovery, Security, Documentation  
✅ Hellodeolu v6: LOCAL GREEN = CI GREEN  
✅ No Bypass Culture: Hooks enforce validation, bypass logged in commit message

---

## Support

- **Canon Library**: https://github.com/RylanLabs/rylan-canon-library
- **Pre-Commit Docs**: https://pre-commit.com/
- **Issues**: GitHub Issues on canon repo
