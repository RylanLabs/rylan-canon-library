# Makefile Reference

> Convenience targets for local development, validation, and CI simulation

## Quick Start

```bash
# Show all targets
make help

# Run all validators
make validate

# Auto-fix formatting
make format

# Simulate full CI locally
make ci-local
```

---

## Available Targets

### Validation Targets

#### `make validate` — Run ALL validators

Executes all 4 validators sequentially:
1. Python validator (mypy + ruff + bandit)
2. Bash validator (shellcheck + shfmt)
3. YAML validator (yamllint)
4. Ansible validator (if playbooks/ exists)

**Usage**:
```bash
make validate

# Output:
# Running Python validation...
# ✅ mypy validation passed
# ✅ ruff linting passed
# ...
# Running Bash validation...
# ✅ shellcheck passed
# ...
# ✅ All validations passed
```

**When to use**: Before committing code, to ensure LOCAL GREEN = CI GREEN.

---

#### `make validate-python` — Python only

Runs Python validator:
- mypy --strict (type checking)
- ruff check (linting)
- ruff format --check (formatting)
- bandit (security scanning)

**Usage**:
```bash
make validate-python
```

**Example output**:
```
Running Python validation...
[PASS] mypy validation passed
[PASS] ruff linting passed
[PASS] ruff formatting passed
[PASS] bandit security scan passed
✅ Python validation complete
```

---

#### `make validate-bash` — Bash only

Runs Bash validator:
- shellcheck (static analysis)
- shfmt formatting check

**Usage**:
```bash
make validate-bash
```

---

#### `make validate-yaml` — YAML only

Runs YAML validator:
- yamllint (config, playbooks, workflows)

**Usage**:
```bash
make validate-yaml
```

---

#### `make validate-ansible` — Ansible only

Runs Ansible validator (only if `playbooks/` directory exists):
- Ansible syntax check
- ansible-lint

**Usage**:
```bash
make validate-ansible

# If no playbooks/ directory:
# ⊘ Ansible validation skipped (no playbooks/ directory)
```

---

### Development Targets

#### `make ci-local` — Simulate full CI locally

Runs validators + pytest with coverage:
1. All 4 validators (sequential)
2. pytest (if tests/ exists, must pass 70% coverage)

**Usage**:
```bash
make ci-local

# Output:
# Running Python validation...
# ... validators ...
# Running pytest with coverage...
# ===== test session starts =====
# collected X items
# ... tests pass ...
# ===== coverage report =====
# TOTAL ... 70% (or higher)
# ✅ CI simulation complete
```

**When to use**: Before pushing to GitHub, to verify full CI pipeline locally.

**Time**: ~1-2 minutes

---

#### `make lint-quick` — Fast linting (skip strict mypy)

Runs quick linting without strict type checking:
- ruff check (linting only)
- ruff format --check (formatting only)

**Usage**:
```bash
make lint-quick
```

**When to use**: During rapid development when you want feedback without mypy's strict checks.

**Time**: ~10 seconds

---

#### `make format` — Auto-fix formatting

Automatically fixes formatting issues:
- ruff format (Python formatting)
- shfmt -i 2 -ci -bn (Bash formatting with canonical 2-space indent)

**Usage**:
```bash
make format

# Output:
# Auto-fixing formatting...
#   - Fixing Python (ruff format)...
#   - Fixing Bash (shfmt -i 2 -ci -bn)...
# ✅ Formatting complete
```

**Then stage and commit**:
```bash
git add .
git commit -m "chore: Auto-format with make format"
```

**When to use**: After making changes, before committing.

---

#### `make clean` — Remove cache files

Removes temporary cache and build files:
- `__pycache__/`
- `.pytest_cache/`
- `.mypy_cache/`
- `.ruff_cache/`
- `.venv/` (optional)
- `*.pyc` files

**Usage**:
```bash
make clean

# Output:
# Cleaning cache files...
# ✅ Cleanup complete
```

---

## Common Workflows

### Before Committing

```bash
# 1. Fix formatting
make format

# 2. Validate
make validate

# 3. Stage & commit
git add .
git commit -m "feat: Add new feature"
```

### During Development (Rapid Iteration)

```bash
# Quick lint (no mypy)
make lint-quick

# Only if passing:
make validate
```

### Before Pushing to GitHub

```bash
# Full CI simulation
make ci-local

# If all pass:
git push origin feature-branch
```

### After Long Session

```bash
# Clean up cache
make clean

# Fresh validation
make validate
```

---

## Environment Variables

### `PYTHON_VERSION`

Override Python version (default: 3):

```bash
PYTHON_VERSION=3.11 make validate-python
PYTHON_VERSION=3.12 make ci-local
```

**Valid values**: 3, 3.11, 3.12, etc. (must be installed)

### `VENV_DIR`

Override virtual environment directory (default: `.venv`):

```bash
VENV_DIR=/custom/path make validate-python
```

---

## Performance Tuning

### Fastest Validation

```bash
make lint-quick  # ~10 seconds (ruff only)
```

### Balanced Validation

```bash
make validate-python && make validate-bash && make validate-yaml  # ~30 seconds
```

### Full Validation

```bash
make validate  # ~1 minute (all validators)
```

### Full CI

```bash
make ci-local  # ~2 minutes (validators + tests)
```

---

## Troubleshooting

### Issue: "make: command not found"

**Solution**: Install GNU Make

```bash
# macOS
brew install make

# Ubuntu/Debian
sudo apt-get install make

# Verify
make --version
```

### Issue: Validator fails but you think it's wrong

**Solution**: Run the validator directly with full output

```bash
# Instead of:
make validate-python

# Run directly:
bash scripts/validate-python.sh  # Full output

# Or run specific tool:
python3 -m mypy --strict scripts tests
```

### Issue: "shfmt: command not found"

**Solution**: Install shfmt

```bash
# macOS
brew install shfmt

# Ubuntu/Debian
sudo apt-get install shfmt

# Or download binary
wget -qO- https://github.com/mvdan/sh/releases/download/v3.8.0/shfmt_v3.8.0_linux_amd64 | sudo tee /usr/local/bin/shfmt
sudo chmod +x /usr/local/bin/shfmt

# Verify
shfmt --version
```

### Issue: Make is very slow

**Solution**: Run specific validator instead of `make validate`

```bash
# Fast (only Python):
make validate-python

# Slower (all validators):
make validate
```

### Issue: Tests fail in `make ci-local` but pass when run directly

**Solution**: Check Python version mismatch

```bash
# Verify Python version
python3 --version

# Override if needed
PYTHON_VERSION=3.12 make ci-local
```

---

## Integration with Pre-Commit

`make validate` is called by pre-commit hooks automatically on commit:

```bash
# Manual test
make validate

# Automatic on commit
git commit -m "feat: Add feature"  # Runs validators automatically
```

---

## CI/CD Integration

Use `make ci-local` to simulate GitHub Actions locally:

```bash
# Before pushing
make ci-local

# If it passes locally, CI will pass on GitHub
```

---

## Best Practices

1. **Before committing**: `make format && make validate`
2. **Before pushing**: `make ci-local`
3. **During development**: `make lint-quick` for fast feedback
4. **After long sessions**: `make clean` then `make validate`
5. **Don't bypass**: No `make --no-verify` (use pre-commit hooks instead)

---

## Reference Table

| Command | Time | Purpose |
|---------|------|---------|
| `make help` | <1s | Show all targets |
| `make lint-quick` | 10s | Fast linting |
| `make validate-python` | 15s | Python only |
| `make validate-bash` | 10s | Bash only |
| `make validate-yaml` | 5s | YAML only |
| `make validate` | 45s | All validators |
| `make format` | 20s | Auto-fix formatting |
| `make ci-local` | 2min | Full CI simulation |
| `make clean` | 5s | Remove cache |

---

## Compliance

✅ Seven Pillars: Idempotency (all targets re-runnable), Error Handling (clear output), Functionality (all validators integrated), Audit Logging (full output), Failure Recovery (validators report issues), Security (bandit + shellcheck), Documentation (this guide)

✅ Hellodeolu v6: LOCAL GREEN = CI GREEN, junior-deployable targets with clear messages

✅ RylanLabs Canon: Canonical bash indentation (-i 2 -ci -bn), no hardcoded paths

---

## Support

- **Canon Library**: https://github.com/RylanLabs/rylan-canon-library
- **Issues**: GitHub Issues on canon repo
- **Make Documentation**: https://www.gnu.org/software/make/manual/
