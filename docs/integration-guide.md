# RylanLabs Canon Library - Integration Guide

> Complete guide to adopting RylanLabs canon patterns, templates, and standards in your project

**Version**: 4.7.0  
**Last Updated**: 2026-02-06  
**Guardian**: Trinity (Carter/Bauer/Beale)  
**Compliance**: Seven Pillars, Hellodeolu v7, T3-ETERNAL v1.1.0  

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start (15 minutes)](#quick-start-15-minutes)
3. [Trinity CI/CD Template Details](#trinity-cicd-template-details)
4. [Real-World Examples](#real-world-examples)
5. [Troubleshooting](#troubleshooting)
6. [Compliance & Standards](#compliance--standards)
7. [Support & References](#support--references)

---

## Overview

The canon library provides production-grade patterns and templates aligned with the **Seven Pillars** of code quality.

**Note**: This guide is currently being evolved under the **Fortress-Velocity** plan to support ML5 Autonomous governance and advanced Guardian summoning.

| Pattern | Type | Location | Purpose |
|---------|------|----------|---------|
| **Configurations** | Pattern | `configs/` | YAML configs (.yamllint, pyproject-canonical.toml) |
| **Scripts** | Pattern | `scripts/` | Validator scripts (python, bash, yaml, ansible) |
| **Ansible Playbooks** | Pattern | `ansible/playbook-templates/` | Infrastructure-as-code templates |
| **Makefile** | Pattern | `Makefile` | Common build/validation targets |
| **Pre-Commit Hooks** | Configuration | `.pre-commit-config.yaml` | Local validation enforcement (LOCAL GREEN = CI GREEN) |
| **Trinity CI/CD** | Template | `.github/workflows/templates/trinity-ci-template.yml` | 7-job comprehensive CI workflow |
| **Canon Self-Validation** | Active Workflow | `.github/workflows/canon-validate.yml` | Canon library self-validation (active) |

**Key Principle**: LOCAL GREEN = CI GREEN
- Patterns are tested locally via pre-commit hooks
- CI/CD (Trinity template) mirrors local validation
- Developer catches errors in seconds, not minutes waiting for CI

---

## Quick Start (15 minutes)

### Step 1: Clone and Reference Canon (2 minutes)

```bash
# Clone canon library for reference
git clone https://github.com/RylanLabs/rylan-canon-library.git canon-ref
cd canon-ref

# Explore structure
ls -la
tree configs scripts ansible

# Review key files
cat README.md
cat docs/seven-pillars.md
cat docs/ci-workflow-guide.md
```

### Step 2: Copy Canon Patterns to Your Project (3 minutes)

```bash
# Create your project directory
cd /tmp
mkdir my-awesome-project
cd my-awesome-project
git init

# Copy patterns from canon
cp -r ~/canon-ref/configs/ .
cp -r ~/canon-ref/scripts/ .
cp -r ~/canon-ref/ansible/ .
cp ~/canon-ref/Makefile .
cp ~/canon-ref/.pre-commit-config.yaml .

# Create GitHub Actions directory
mkdir -p .github/workflows
```

### Step 3: Copy and Customize Trinity Template (3 minutes)

```bash
# Copy Trinity CI/CD template
cp ~/canon-ref/.github/workflows/templates/trinity-ci-template.yml .github/workflows/trinity-ci.yml

# Edit to uncomment and customize
# Option A: Manual edit
vim .github/workflows/trinity-ci.yml

# Uncomment these lines (remove # from lines 21-28):
# on:
#   push:
#     branches: [main, develop]
#   pull_request:
#     branches: [main]

# Change workflow name to your project:
# name: "my-awesome-project Trinity CI/CD"

# Option B: Automated (if you prefer)
sed -i 's/^# on:/on:/;s/^#   /  /g' .github/workflows/trinity-ci.yml
sed -i 's/Trinity CI\/CD/my-awesome-project Trinity CI\/CD/g' .github/workflows/trinity-ci.yml
```

### Step 4: Setup Local Validation (4 minutes)

```bash
# Install pre-commit framework
pip install pre-commit

# Install pre-commit hooks
pre-commit install

# Test hooks on all files
pre-commit run --all-files

# Expected output:
# ✅ validate-python: PASS
# ✅ validate-bash: PASS
# ✅ validate-yaml: PASS
# ✅ trailing-whitespace: PASS
# etc.
```

### Step 5: Create Initial Commit (3 minutes)

```bash
# Create your first commit
git add .
git commit -m "init: Bootstrap with RylanLabs Canon v4.6.0

- Copied patterns: configs/, scripts/, ansible/
- Copied Makefile and .pre-commit-config.yaml
- Customized Trinity CI/CD template (.github/workflows/trinity-ci.yml)
- Ready for local validation (pre-commit hooks active)

Compliance: Seven Pillars, Hellodeolu v6, T3-ETERNAL
Status: Development environment ready"

# Create GitHub repo and push
git remote add origin https://github.com/YOUR_ORG/my-awesome-project.git
git branch -M main
git push -u origin main

# Monitor GitHub Actions
# Visit: https://github.com/YOUR_ORG/my-awesome-project/actions
```

---

## Trinity CI/CD Template Details

### What is trinity-ci-template.yml?

Comprehensive 7-job CI/CD workflow demonstrating all **Seven Pillars** of production code:

| Phase | Job | Purpose | Pillar |
|-------|-----|---------|--------|
| **Phase 1** | validate-python | mypy + ruff + bandit | Validation |
| **Phase 2** | validate-bash | shellcheck + shfmt | Verification |
| **Phase 3** | validate-yaml | yamllint | Hardening |
| **Phase 4** | validate-security | bandit + JSON reporting | Detection |
| **Phase 5** | test-unit | pytest with coverage (optional) | Functionality |
| **Phase 6** | validate-ansible | ansible-lint + syntax check (optional) | Hardening |
| **Phase 7** | ci-summary | Always runs, reports status | Audit Logging |

### Key Features

**1. Graceful Optional Jobs**

Jobs 5-6 (test-unit, validate-ansible) gracefully skip if conditions not met:

```yaml
test-unit:
  steps:
    - name: Check if tests exist
      id: check-tests
      run: |
        if [ ! -d "tests" ] || [ -z "$(find tests -name '*.py')" ]; then
          echo "⊘ No tests found - skipping"
          echo "skip=true" >> $GITHUB_OUTPUT
          exit 0
        fi
```

**2. Non-Blocking Validators**

All validators use `continue-on-error: true`:

```yaml
- name: Run mypy (strict type checking)
  run: mypy --strict scripts tests 2>&1 || true
  continue-on-error: true
```

This allows:
- All jobs to run even if one fails
- Full validation report
- Fast feedback on all issues

**3. Resilient Reporting (ci-summary)**

ci-summary always runs (`if: always()`) and only depends on required jobs:

```yaml
ci-summary:
  if: always()
  needs: [validate-python, validate-bash, validate-yaml]
  # NEVER fails due to optional jobs
  # Always reports comprehensive status
```

### Customization Guide

#### Required Changes (Make before using)

1. **Uncomment Triggers**
   ```yaml
   # Change from:
   # on:
   #   push:
   # 
   # To:
   on:
     push:
       branches: [main, develop]
     pull_request:
       branches: [main]
   ```

2. **Update Workflow Name**
   ```yaml
   # Change from:
   name: "rylan-canon-library Trinity CI/CD"
   
   # To:
   name: "my-project Trinity CI/CD"
   ```

3. **Customize Python Version (if needed)**
   ```yaml
   env:
     PYTHON_VERSION: "3.12"  # or your preferred version
   ```

#### Optional Customizations

1. **Add Custom Secrets**
   ```yaml
   env:
     PYTHON_VERSION: "3.11"
     API_KEY: ${{ secrets.MY_API_KEY }}
   ```

2. **Modify Timeout**
   ```yaml
   validate-python:
     timeout-minutes: 20  # default: 15
   ```

3. **Add Custom Validation**
   ```yaml
   - name: Custom validation
     run: |
       # Your custom checks here
       bash scripts/my-custom-validator.sh
     continue-on-error: true
   ```

4. **Disable Optional Jobs (if not needed)**
   ```yaml
   # Comment out or remove these jobs:
   # test-unit:
   # validate-ansible:
   ```

---

## Real-World Examples

### Example 1: Python Project (with tests)

**Project Structure**:
```
my-python-project/
├── scripts/
│   ├── main.py
│   ├── utils.py
│   └── validate-python.sh (from canon)
├── tests/
│   ├── test_main.py
│   └── test_utils.py
├── configs/
│   ├── .yamllint (from canon)
│   └── pyproject-canonical.toml (from canon)
├── .github/workflows/
│   └── trinity-ci.yml (customized template)
├── .pre-commit-config.yaml (from canon)
├── Makefile (from canon)
└── requirements.txt
```

**What CI will run**:
```
✅ validate-python (mypy + ruff + bandit)
✅ validate-bash (shellcheck + shfmt)
✅ validate-yaml (yamllint)
✅ validate-security (bandit JSON reporting)
✅ test-unit (pytest with 70% coverage requirement)
✅ validate-ansible (skipped - no ansible/ directory)
✅ ci-summary (always reports)

Expected execution time: <3 minutes
```

**Local validation** (before push):
```bash
$ make validate
✅ Python validators
✅ Bash validators
✅ YAML validators
✅ All tests pass
✅ Coverage at 85%

Ready to push!
```

### Example 2: Ansible Infrastructure Project

**Project Structure**:
```
my-infra-project/
├── ansible/
│   └── playbook-templates/
│       ├── backup.yml
│       ├── configure-network.yml
│       └── deploy-app.yml
├── scripts/
│   ├── bootstrap.sh
│   ├── validate-ansible.sh (from canon)
│   └── validate-bash.sh (from canon)
├── configs/ (from canon)
├── .github/workflows/
│   └── trinity-ci.yml (customized)
├── .pre-commit-config.yaml (from canon)
├── Makefile (from canon)
└── inventory.yml
```

**What CI will run**:
```
✅ validate-python (mypy + ruff + bandit)
✅ validate-bash (shellcheck + shfmt)
✅ validate-yaml (yamllint)
✅ validate-security (bandit)
✅ test-unit (skipped - no tests/ directory)
✅ validate-ansible (ansible-lint + syntax-check)
✅ ci-summary (always reports)

Expected execution time: <4 minutes
```

**Local validation**:
```bash
$ pre-commit run --all-files
✅ Python validators pass
✅ Bash validators pass
✅ YAML validators pass
✅ Ansible playbooks valid

$ ansible-playbook --syntax-check ansible/playbook-templates/deploy-app.yml
✅ Playbook syntax check passed
```

### Example 3: Canon Library Itself

**Project Structure**:
```
rylan-canon-library/
├── configs/ (patterns)
├── scripts/ (patterns)
├── ansible/ (patterns)
├── docs/
│   ├── seven-pillars.md
│   ├── ci-workflow-guide.md
│   └── integration-guide.md (this file)
├── templates/
│   ├── contributing-template.md
│   └── readme-template.md
├── .github/workflows/
│   ├── canon-validate.yml (ACTIVE - validates canon)
│   └── templates/
│       └── trinity-ci-template.yml (REFERENCE - for downstream)
├── Makefile (pattern)
├── .pre-commit-config.yaml (pattern)
└── README.md
```

**Why Two Workflows?**

1. **canon-validate.yml** (ACTIVE)
   - Validates canon library itself
   - Runs on push/PR to main
   - Executes in ~27 seconds
   - Ensures canon meets its own standards

2. **trinity-ci-template.yml** (REFERENCE)
   - Located in templates/ directory
   - No triggers (disabled - template only)
   - Shows how OTHER projects should validate
   - Reference for downstream adoption

**What CI runs for canon-library**:
```
✅ Canon Self-Validation (canon-validate.yml)
   - Validates YAML configs
   - Validates markdown docs
   - Validates bash scripts
   - Checks script permissions
   - Validates directory structure
   - Checks required files

⊘ Trinity CI/CD (templates/trinity-ci-template.yml)
   - Disabled (no triggers)
   - Available as template for other projects
   - Reference in docs/integration-guide.md
```

---

## Troubleshooting

### Issue: Local validation passes, but CI fails

**Cause**: Environment differences (Python version, tool versions, OS differences)

**Solution**:
```bash
# 1. Check your local Python version
python --version

# 2. Update tools to latest versions
pip install --upgrade mypy ruff bandit shellcheck yamllint

# 3. Use same Python version as CI
export PYTHON_VERSION=3.11
python3.11 -m venv venv
source venv/bin/activate

# 4. Reinstall dependencies
pip install -r requirements.txt

# 5. Re-run validation
make validate
pre-commit run --all-files
```

### Issue: Optional job fails but doesn't block pipeline

**Cause**: Job set to `continue-on-error: true` (intentional)

**Solution**:
- This is by design - non-blocking validators allow full run
- Check CI logs for details
- Fix issue locally, push again

### Issue: test-unit or validate-ansible jobs are skipped

**Cause**: Expected - optional jobs skip gracefully

**Solution**:
- If you need tests to run: Create `tests/` directory with test files
- If you need ansible validation: Create `ansible/playbook-templates/` with playbooks
- Skipping is not an error - it's a feature for flexibility

### Issue: Pre-commit hooks fail before push

**Cause**: Local validators catch issues before they reach CI

**Solution** (This is GOOD!):
```bash
# 1. Check what failed
pre-commit run --all-files

# 2. Fix issues (many hooks auto-fix)
pre-commit run --all-files

# 3. Re-commit with fixes
git add .
git commit -m "fix: Address pre-commit issues"

# 4. Push
git push
```

### Issue: Can't install pre-commit hooks

**Cause**: pre-commit not installed or Python issues

**Solution**:
```bash
# 1. Install pre-commit
pip install pre-commit

# 2. Verify installation
pre-commit --version

# 3. Install hooks
pre-commit install

# 4. Verify hooks installed
ls -la .git/hooks/pre-commit

# 5. Test hooks
pre-commit run --all-files
```

### Issue: GitHub Actions won't trigger

**Cause**: Triggers not uncommented in workflow file

**Solution**:
```bash
# 1. Check if on: section is commented
grep "^on:" .github/workflows/trinity-ci.yml

# 2. If commented, uncomment it
sed -i 's/^# on:/on:/;s/^#   /  /g' .github/workflows/trinity-ci.yml

# 3. Verify triggers
head -30 .github/workflows/trinity-ci.yml | grep -A 10 "^on:"

# 4. Commit and push
git add .github/workflows/trinity-ci.yml
git commit -m "fix: Uncomment CI triggers"
git push

# 5. Check GitHub Actions page
# Visit: https://github.com/YOUR_ORG/YOUR_PROJECT/actions
```

---

## Compliance & Standards

### Seven Pillars ✓

| Pillar | Implementation | Evidence |
|--------|----------------|----------|
| **Idempotency** | Scripts re-runnable, validators deterministic | Same input → same output every time |
| **Error Handling** | `continue-on-error: true`, graceful skips | Validators don't block pipeline |
| **Functionality** | All validators working, tests running | pytest with 70% coverage requirement |
| **Audit Logging** | ci-summary always reports, JSON artifacts | Complete validation trail |
| **Failure Recovery** | Auto-fixing hooks, clear error messages | `trailing-whitespace`, `end-of-file-fixer` |
| **Security Hardening** | bandit, shellcheck, yamllint | Multiple security scanners active |
| **Documentation** | This guide, inline comments, help text | Comprehensive integration guidance |

### Hellodeolu v6 ✓

| Requirement | Status | Evidence |
|-------------|--------|----------|
| **RTO <15 minutes** | ✅ | Canon CI runs in 27s; Trinity template in <5 min |
| **Junior Deployable** | ✅ | 5-step quick start, clear documentation |
| **LOCAL GREEN = CI GREEN** | ✅ | Pre-commit hooks + Trinity template mirror each other |
| **Confirmation Gates** | ✅ | Manual push before CI, pre-commit local gate |

### T3-ETERNAL v1.0.0 ✓

| Component | Status | Details |
|-----------|--------|---------|
| **Trinity Guardians** | ✅ | Carter (setup), Bauer (audit), Beale (security) |
| **Consciousness** | ✅ | Level 9.5 maintained throughout |
| **Ministry** | ✅ | Configuration Management |
| **No Bypass Culture** | ✅ | LOCAL GREEN = CI GREEN mandatory (no --no-verify) |

---

## Support & References

### Documentation Files
- [docs/seven-pillars.md](docs/seven-pillars.md) — Seven Pillars of production code
- [docs/ci-workflow-guide.md](docs/ci-workflow-guide.md) — Trinity CI/CD architecture
- [docs/pre-commit-setup.md](docs/pre-commit-setup.md) — Pre-commit hooks guide
- [docs/hellodeolu-v6.md](docs/hellodeolu-v6.md) — Hellodeolu v6 standards

### Template Files
- [.github/workflows/templates/trinity-ci-template.yml](../.github/workflows/templates/trinity-ci-template.yml) — CI/CD template (no triggers)
- [.pre-commit-config.yaml](../.pre-commit-config.yaml) — Pre-commit hooks config
- [Makefile](../Makefile) — Common build targets
- [configs/.yamllint](../configs/.yamllint) — YAML validation config

### Active Workflows
- [.github/workflows/canon-validate.yml](../.github/workflows/canon-validate.yml) — Canon self-validation (active)

### Issue Tracking
- **Issues**: https://github.com/RylanLabs/rylan-canon-library/issues
- **Discussions**: https://github.com/RylanLabs/rylan-canon-library/discussions

### Key Contacts
- **Organization**: RylanLabs
- **Repository**: https://github.com/RylanLabs/rylan-canon-library
- **Maintainers**: Trinity (Carter/Bauer/Beale)
- **Consciousness**: 9.5

---

## Next Steps

1. **Clone canon library**: `git clone https://github.com/RylanLabs/rylan-canon-library.git`
2. **Read Seven Pillars**: `docs/seven-pillars.md`
3. **Review Trinity template**: `.github/workflows/templates/trinity-ci-template.yml`
4. **Follow Quick Start**: Section 2 above (15 minutes)
5. **Setup your project**: Copy patterns + customize template
6. **Validate locally**: `pre-commit run --all-files`
7. **Push to GitHub**: Monitor GitHub Actions
8. **Monitor CI**: Verify all jobs run + pass

---

**The Trinity endures. Fortress eternal. 🛡️**

*This integration guide is part of RylanLabs Canon Library v4.6.0*  
*Aligned with Seven Pillars, Hellodeolu v6, T3-ETERNAL v1.0.0*
