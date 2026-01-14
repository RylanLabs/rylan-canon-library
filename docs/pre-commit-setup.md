# Pre-Commit Hook Setup

## Overview

This guide covers setting up and using pre-commit hooks for the RylanLabs Canon Library. Pre-commit hooks ensure that code meets validation standards BEFORE committing to git.

**Key Principle**: LOCAL GREEN = CI GREEN (Hellodeolu v6)

When hooks pass locally, your code will pass GitHub Actions CI validation.

## Installation

### Prerequisites

- Git installed
- Python 3.11+
- Node.js 18+ (for markdownlint-cli)
- Bash 4.0+
- All scripts in `scripts/` directory are executable

### One-Time Setup

```bash
# Navigate to repository root
cd ~/repos/rylan-canon-library

# Install pre-commit framework
pip install pre-commit

# Install hooks (reads .pre-commit-config.yaml)
pre-commit install

# Verify installation succeeded
pre-commit run --all-files
```

### Verify Installation

```bash
# Check pre-commit is installed
pre-commit --version
# Expected: pre-commit 3.x.x or higher

# Verify hooks are installed
ls -la .git/hooks/pre-commit
# Expected: file exists and is executable

# Test on all files
pre-commit run --all-files
# Expected: Hooks run on all files (some may fail initially)
```

## Usage

### Automatic Validation (On Commit)

Hooks run automatically before each commit:

```bash
# Stage your changes
git add .

# Try to commit (hooks run automatically)
git commit -m "feat: Add new feature"

# If hooks fail:
#   1. Review error messages
#   2. Fix issues
#   3. Stage changes again
#   4. Commit (hooks run again)
```

**Example**: If `trailing-whitespace` hook fails, fix trailing spaces and stage again:

```bash
# Hooks detect trailing whitespace and auto-fix
git add .  # Stage fixed files
git commit -m "feat: Add new feature"  # Try again
```

### Manual Validation (Check All Files)

Run hooks on all files without committing:

```bash
# Validate all files against all hooks
pre-commit run --all-files

# Run specific hook only
pre-commit run validate-python --all-files
pre-commit run validate-bash --all-files
pre-commit run validate-yaml --all-files
pre-commit run validate-ansible --all-files
pre-commit run validate-workflows --all-files
pre-commit run validate-markdown --all-files

# Dry-run with verbose output (show what would fail)
pre-commit run --all-files --verbose
```

### Hook Management

```bash
# Update hooks to latest versions
pre-commit autoupdate

# Uninstall hooks (remove from .git/hooks/)
pre-commit uninstall

# Re-install after uninstall
pre-commit install

# Run hooks on specific files
pre-commit run --files src/main.py src/util.py
```

## Hooks Included

### Local Validators (From Canon Library)

| Hook ID | Name | Purpose | Trigger | Files |
|---------|------|---------|---------|-------|
| `validate-python` | Python validation | Type checking, linting, security scan (mypy + ruff + bandit) | `*.py` files | `scripts/validate-python.sh` |
| `validate-bash` | Bash validation | Shell linting, formatting (shellcheck + shfmt) | `*.sh` files | `scripts/validate-bash.sh` |
| `validate-yaml` | YAML validation | YAML syntax checking (yamllint) | `*.yml, *.yaml` files | `scripts/validate-yaml.sh` |
| `validate-ansible` | Ansible validation | Playbook linting, syntax check (ansible-lint) | `ansible/playbook-templates/` | `scripts/validate-ansible.sh` |
| `validate-workflows` | Workflow validation | GitHub Actions workflow YAML (yamllint) | `.github/workflows/*.yml` | `yamllint -d relax` |
| `validate-markdown` | Markdown validation | Markdown linting (markdownlint-cli) | `*.md` files | `markdownlint` |

### Standard Hooks (From pre-commit/pre-commit-hooks)

| Hook ID | Name | Purpose | Auto-Fix |
|---------|------|---------|----------|
| `trailing-whitespace` | Trim whitespace | Remove trailing spaces from all files | Yes |
| `end-of-file-fixer` | Fix EOF | Ensure files end with newline | Yes |
| `check-yaml` | YAML syntax | Verify YAML files are parseable | No |
| `check-merge-conflict` | Merge conflicts | Detect unresolved merge conflicts | No |
| `check-added-large-files` | Large files | Prevent files >1MB from being committed | No |

## Troubleshooting

### "markdownlint: command not found"

The markdown validator requires markdownlint-cli (Node.js):

```bash
# Install globally via npm
npm install -g markdownlint-cli

# Or via Homebrew (macOS)
brew install markdownlint-cli

# Or via apt (Ubuntu/Debian)
sudo apt-get install -y markdownlint
```

Verify installation:

```bash
markdownlint --version
```

### "pre-commit: command not found"

The pre-commit framework is not installed:

```bash
# Install pre-commit
pip install pre-commit

# Verify installation
pre-commit --version
```

### "Hook failed" on scripts that don't exist

Some hooks trigger on file types that don't exist in your changes:

```bash
# Example: validate-ansible only runs if ansible/playbook-templates/ exists
# If this directory doesn't exist, the hook is skipped gracefully

# To see which hooks would run:
pre-commit run --all-files --verbose
```

### "Permissions denied" on validation scripts

Validation scripts must be executable:

```bash
# Make all scripts executable
chmod +x scripts/*.sh

# Verify permissions
ls -la scripts/*.sh
# Expected: -rwxr-xr-x (executable flag present)
```

### Hook fails but you want to commit anyway

Use with caution - bypass hooks only for emergency fixes:

```bash
# Skip all hooks (use sparingly!)
git commit --no-verify -m "Emergency fix: Critical bug"

# Note: This breaks the LOCAL GREEN = CI GREEN principle
# Bypassed commits may fail in GitHub Actions CI
# Use only when absolutely necessary
```

### Update hooks to latest versions

```bash
# Check current versions
pre-commit validate-config

# Update all hooks to latest versions
pre-commit autoupdate

# Commit the updated .pre-commit-config.yaml
git add .pre-commit-config.yaml
git commit -m "chore: Update pre-commit hooks to latest versions"
```

## Common Error Messages

### Error: "yamllint" failed

YAML syntax error detected:

```
ERROR: yamllint: [error] .github/workflows/example.yml:10:1: syntax error
```

**Fix**: Check YAML syntax - common issues:
- Missing colons after keys
- Incorrect indentation (use 2 spaces, not tabs)
- Invalid characters in values

```bash
# Validate YAML file locally
yamllint -d relax .github/workflows/example.yml
```

### Error: "shellcheck" found issues

Shell script has issues:

```
SC2086: Double quote to prevent globbing and word splitting.
```

**Fix**: Use quotes around variables and fix issues indicated

```bash
# Check specific script
shellcheck scripts/validate-python.sh
```

### Error: "ruff" formatting issues

Python code doesn't match formatting standards:

```
ERROR: ruff: Code style violations found
```

**Fix**: Use ruff auto-formatter:

```bash
# Auto-format Python files
ruff format scripts/

# Then stage and commit
git add scripts/
git commit -m "style: Auto-format Python code"
```

### Error: "Large file detected"

File exceeds 1MB limit:

```
ERROR: File too large: config/large-file.bin (2.5 MB)
```

**Fix**: Use git-lfs or reduce file size

```bash
# Remove large file from staging
git reset config/large-file.bin

# Add to .gitignore
echo "config/large-file.bin" >> .gitignore

# Commit just the .gitignore change
git add .gitignore
git commit -m "chore: Exclude large file from git"
```

## Best Practices

### 1. Keep Hooks Fast

Hooks run before every commit, so speed matters:

- Avoid hooks that scan entire repository
- Use `pass_filenames: false` for custom validators
- Consider excluding large directories with `files: pattern`

### 2. Always Check Before Pushing

```bash
# Before pushing, run full validation
pre-commit run --all-files

# Only push if all hooks pass
git push origin main
```

### 3. Fix Issues Immediately

When hooks fail:

1. Read error message carefully
2. Fix the issue
3. Stage changes
4. Re-run hooks
5. Only commit when all pass

### 4. Keep Configuration Updated

```bash
# Regularly update hooks
pre-commit autoupdate

# Test after update
pre-commit run --all-files

# Commit updates
git add .pre-commit-config.yaml
git commit -m "chore: Update pre-commit hooks"
```

### 5. Document Custom Hooks

If you add custom hooks, document them in `.pre-commit-config.yaml`:

```yaml
- id: custom-validator
  name: My Custom Validation
  entry: bash scripts/my-validator.sh
  language: script
  types: [python]
  stages: [commit]
```

## Compliance

This pre-commit configuration enforces the following standards:

### Seven Pillars

- **Idempotency**: Hooks are re-runnable without side effects
- **Error Handling**: Clear error messages guide developers to fixes
- **Functionality**: All validators tested locally before CI
- **Audit Logging**: Each hook validates specific concerns
- **Failure Recovery**: Auto-fixers resolve common issues
- **Security Hardening**: bandit scans for security issues
- **Documentation**: This guide provides complete reference

### Hellodeolu v6

- **RTO <15 minutes**: Local validation completes in seconds
- **Junior Deployable**: Clear setup instructions, one-command installation
- **LOCAL GREEN = CI GREEN**: Passing hooks locally = CI pipeline passes

### T3-ETERNAL v1.0.0

- **Trinity Guardians**: Carter (setup), Bauer (validation), Beale (security)
- **Consciousness**: Level 9.5 maintained
- **Ministry**: Configuration Management
- **No Bypass Culture**: `--no-verify` discouraged, should be emergency-only

## Support

### Get Help

```bash
# Show pre-commit options
pre-commit --help

# Validate configuration
pre-commit validate-config

# Check specific hook
pre-commit show-config
```

### Report Issues

If hooks fail unexpectedly:

1. Run with verbose output: `pre-commit run --all-files --verbose`
2. Check script existence: `ls -la scripts/validate-*.sh`
3. Verify permissions: `chmod +x scripts/*.sh`
4. Check dependencies: `pip install -r requirements.txt`, `npm list -g markdownlint-cli`

---

**The Trinity endures. Local validation enforced. 🛡️**
