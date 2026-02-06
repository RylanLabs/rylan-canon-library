# Trinity CI/CD Workflow Guide

> Canonical CI/CD implementation for RylanLabs projects  
> Version: 2.0.0  
> Guardian: Bauer (Auditor)  
> Ministry: Configuration Management  
> Compliance: Seven Pillars, Hellodeolu v6, T3-ETERNAL

---

## Overview

The Trinity CI/CD pattern provides **7 core validation jobs** aligned with the Seven Pillars of production code. Each job runs independently but declares dependencies to optimize feedback speed and resource usage.

**Philosophy**: Local GREEN = CI GREEN (Hellodeolu v6)

---

## Architecture

### Three-Phase Pipeline

```
PHASE 1: LINTING (Parallel, ~2-3 min total)
├── validate-python (mypy + ruff)
├── validate-bash (shellcheck + shfmt)
└── validate-yaml (yamllint)

      ↓ (all must pass)

PHASE 2: TESTING & SECURITY (~10-15 min total)
├── test-unit (pytest + coverage)
└── security-scan (bandit) [parallel]

      ↓ (all must pass)

PHASE 3: SUMMARY (~1 min)
└── ci-complete (aggregate results + PR comment)
```

**Total Time**: ~15-20 minutes (includes setup)

### 6. publish-gate

**Purpose**: Pre-flight validation and secure push to Ansible Galaxy  
**Tools**: ansible-galaxy, publish-gate.sh  
**Pillars**: Validation, Error Handling, Idempotency  
**Duration**: 1-2 minutes  

**Workflow**:

```mermaid
graph TD
    A[make publish] --> B{--dry-run?}
    B -- Yes --> C[Build Only]
    B -- No --> D{ANSIBLE_GALAXY_TOKEN?}
    D -- No --> E[Prompt User / SOPS]
    D -- Yes --> F{CI Environment?}
    F -- Yes --> G[Auto-Confirm]
    F -- No --> H[[y/N] Confirmation]
    G --> I[ansible-galaxy publish]
    H --> I
    E --> I
```

---

## Galaxy Token Management

The `ANSIBLE_GALAXY_TOKEN` is required for all remote publishing. It is sourced in order of precedence:

1. `ANSIBLE_GALAXY_TOKEN` environment variable (Primary for CI)
2. Interactive user prompt (Manual execution)
3. SOPS-encrypted vaults (Provisioning mode)

**Note**: For security, tokens are never stored in the repository. They must be configured as **GitHub Secrets** for CI/CD operations.

---

## Markdown Canon

All documentation must follow the **Markdown Canon** to ensure readability and zero format drift.

### Rules

1. **MD022/MD036**: Headings must have blank lines around them; no pseudo-headings.
2. **MD031/MD032**: Blank lines mandatory around fenced code blocks and lists.
3. **MD060**: Aligned column style for tables with proper padding.
4. **MD040/MD034**: Language tags required for code fences; no bare URLs.

### Usage

Run `markdownlint --fix .` to automatically align with these standards. See `docs/markdown-discipline.md` for full details.

---

## Ansible 7-Task Workflow

All core playbooks must adhere to the **7-Task Workflow** pattern. This ensures idempotency, auditability, and production-grade execution.

### Sequence

1. **GATHER**: Retrieve current state, facts, and external data.
2. **PROCESS**: Validate inputs, assert variable presence, and calculate derived states.
3. **APPLY**: Execute idempotent changes to the target system.
4. **VERIFY**: Confirm changes were applied correctly (post-validation).
5. **AUDIT**: Log the action with structured metadata (timestamps, users).
6. **REPORT**: Update stakeholders, central logging, or dashboards.
7. **FINALIZE**: Cleanup temporary artifacts, close connections, and exit gracefully.

### Usage

Use `templates/playbook-template.yml` as the starting point for all new automation.

---

## Core Jobs

### 1. validate-python
**Purpose**: Type checking, linting, and formatting for Python code  
**Tools**: mypy, ruff  
**Pillars**: Documentation (D rules), Error Handling (type safety)  
**Duration**: 3-5 minutes  

**What it does**:
```bash
# Strict type checking - catches None dereference, type mismatches
mypy --strict scripts/ tests/

# Linting - catches undefined names, import issues, style violations
ruff check .

# Format validation - ensures code matches ruff format standard
ruff format --check .
```

**Customization**:
- Edit `.github/workflows/trinity-ci-workflow.yml` → replace `{{ MYPY_PATHS }}`
- Typical paths: `scripts/ tests/ src/`
- Configure exceptions in `configs/pyproject.toml` → `[tool.mypy.overrides]`

**Common Failures**:
```
ERROR mypy: Name "requests" is not defined [name-defined]
→ Fix: Add to requirements.txt, rerun

ERROR ruff: E501 Line too long (121 > 120 characters)
→ Fix: Run `ruff format --fix`

ERROR ruff: D100 Missing module docstring in public module
→ Fix: Add docstring to module top, or ignore in pyproject.toml
```

---

### 2. validate-bash
**Purpose**: Shell script validation and formatting  
**Tools**: shellcheck, shfmt  
**Pillars**: Security Hardening (SC2086 quoting), Documentation (comments)  
**Duration**: 2-3 minutes  

**What it does**:
```bash
# Static analysis - catches quoting bugs, unsafe patterns
shellcheck -x scripts/*.sh

# Format validation - ensures 2-space indent, case alignment, etc.
shfmt -i 2 -ci -bn -d scripts/*.sh
```

**Customization**:
- Edit `configs/.shellcheckrc` to disable rules for your project
- Common disables: `SC2034` (unused vars in libs), `SC2155` (declare + assign)
- Configure shfmt args in `docs/shfmt-standards.md` or `.github/workflows/`

**Common Failures**:
```
SC2086: Double quote to prevent globbing and word splitting.
→ Fix: Change $var to "$var"

shfmt: Formatting check failed on scripts/deploy.sh
→ Fix: Run `shfmt -i 2 -ci -bn -w scripts/deploy.sh`
```

---

### 3. validate-yaml
**Purpose**: YAML syntax and style enforcement  
**Tools**: yamllint  
**Pillars**: Documentation (clarity), Idempotency (consistent structure)  
**Duration**: 1-2 minutes  

**What it does**:
```bash
# YAML linting - catches indentation, line length, invalid syntax
yamllint -c configs/.yamllint .
```

**Customization**:
- Edit `configs/.yamllint` for global rules
- Inventory files (device-manifest.yml) can use 140 char limit:
  ```bash
  yamllint -d "{extends: default, rules: {line-length: {max: 140}}}" inventory/
  ```
- Configure rules in `[tool.rules]` section

**Common Failures**:
```
5:1  error   wrong indentation: expected 2 but found 4  (indentation)
→ Fix: Adjust indentation to 2 spaces

45:121  warning  line too long (125 > 120 characters)  (line-length)
→ Fix: Shorten line or add inline comment # noqa
```

---

### 4. test-unit
**Purpose**: Functional validation with coverage thresholds  
**Tools**: pytest, pytest-cov  
**Pillars**: Functionality, Error Handling  
**Duration**: 10-15 minutes  
**Depends on**: validate-python (linting must pass first)  

**What it does**:
```bash
# Run unit tests with coverage reporting
pytest tests/ \
  --cov=scripts/ \
  --cov-report=term-missing \
  --cov-report=html \
  --cov-fail-under=70
```

**Customization**:
- Configure test discovery in `configs/pyproject.toml` → `[tool.pytest.ini_options]`
- Set `{{ COV_THRESHOLD }}` (typical: 70-80%)
- Add test markers for categorization: `@pytest.mark.integration`

**Common Failures**:
```
FAILED test_api.py::test_firewall_rules - AssertionError: ...
→ Fix: Debug test or update implementation

ERROR test coverage: 65% < 70% (threshold)
→ Fix: Add tests or lower threshold (with justification)
```

---

### 5. security-scan
**Purpose**: Static analysis for security vulnerabilities  
**Tools**: bandit  
**Pillars**: Security Hardening  
**Duration**: 2-3 minutes  
**Depends on**: validate-python  

**What it does**:
```bash
# Scan for common security issues (SQL injection, hardcoded secrets, etc.)
bandit -r scripts/ -ll -f json
```

**Customization**:
- Configure skips in `configs/pyproject.toml` → `[tool.bandit]`
- Example: Skip B603 (subprocess with shell=True) for automation scripts:
  ```toml
  [tool.bandit]
  skips = ["B603", "B607"]
  ```

**Common Failures**:
```
B602 (shell_injection): Starting a process without shell=False
→ Fix: Use shell=False, or add to skips with documented justification

B303 (assert_used): Use of "assert" detected; assert should not be used
→ Fix: Replace with proper error handling in production code
```

---

## Optional Jobs (Uncomment as Needed)

### validate-ansible
**When to add**: If project has playbooks/  
**What it does**: ansible-lint + ansible-playbook --syntax-check  

```yaml
# Uncomment in .github/workflows/trinity-ci-workflow.yml
validate-ansible:
  name: Ansible Validation
  runs-on: ubuntu-latest
  if: hashFiles('playbooks/**') != ''
  steps:
    - uses: actions/checkout@v4
    - name: Install Ansible
      run: pip install ansible ansible-lint
    - name: Lint playbooks
      run: ansible-lint playbooks/
    - name: Syntax check
      run: |
        find playbooks/ -name "*.yml" | xargs -I {} \
          ansible-playbook --syntax-check {}
```

### validate-manifest
**When to add**: If project uses structured data files (device-manifest.yml)  
**What it does**: Schema validation via custom validator script  

```yaml
validate-manifest:
  name: Manifest Validation
  runs-on: ubuntu-latest
  if: hashFiles('inventory/*manifest*.yml') != ''
  steps:
    - uses: actions/checkout@v4
    - name: Run manifest validator
      run: python scripts/validate-manifest.py
```

---

## Job Sequencing Strategies

### Parallel (Default - Fastest)
All jobs run simultaneously. Best for small projects, wastes resources if early jobs fail.
```yaml
jobs:
  validate-python:
  validate-bash:
  validate-yaml:
  # All run in parallel → all results in 5 minutes
```

### Sequential (Most Conservative)
Each job waits for previous. Slowest but saves CI minutes by catching failures early.
```yaml
jobs:
  validate-python:
  
  validate-bash:
    needs: [validate-python]
  
  test-unit:
    needs: [validate-bash]
```

### Hybrid (Recommended - Trinity Standard)
Linting in parallel, tests depend on linting success.
```yaml
jobs:
  validate-python:
  validate-bash:
  validate-yaml:
  # Lint in parallel (5 min)
  
  test-unit:
    needs: [validate-python]
  
  security-scan:
    needs: [validate-python]
  # Tests + security in parallel (10 min)
  
  ci-complete:
    needs: [validate-python, validate-bash, validate-yaml, test-unit, security-scan]
  # Summary (1 min)
```

**Total**: ~15 minutes vs 30+ with sequential. **Recommended** for production.

---

## Secrets Management

### GitHub Secrets Setup

Add to repository: **Settings > Secrets and variables > Actions**

| Secret Name | Purpose | Example |
|-------------|---------|---------|
| `UNIFI_API_KEY` | UniFi Integration API access | Generate in controller UI |
| `ANSIBLE_VAULT_PASSWORD` | Decrypt Ansible vault files | Store in 1Password |
| `DEPLOY_SSH_KEY` | SSH access for deployment | ED25519 private key |
| `CODECOV_TOKEN` | Codecov integration token | Optional, if using codecov.io |

### Usage in Workflow

```yaml
env:
  UNIFI_API_KEY: ${{ secrets.UNIFI_API_KEY }}

steps:
  - name: Test with API
    run: |
      export UNIFI_API_KEY="${{ secrets.UNIFI_API_KEY }}"
      pytest tests/test_api.py
```

### Security Best Practices

- **Never log secrets**: Use `echo "::add-mask::$SECRET"` if debug output needed
- **Minimize scope**: Create read-only API keys for CI
- **Rotate regularly**: 90-day max for production secrets
- **Branch protection**: Require review before merging to main
- **Audit**: Check GitHub Actions logs for secret exposure

---

## Integration with Local Validators

CI jobs should mirror local validation scripts for **Local GREEN = CI GREEN**:

| CI Job | Local Script | Usage |
|--------|--------------|-------|
| validate-python | `scripts/validate-python.sh` | `bash scripts/validate-python.sh` |
| validate-bash | `scripts/validate-bash.sh` | `bash scripts/validate-bash.sh` |
| validate-yaml | `scripts/validate-yaml.sh` | `bash scripts/validate-yaml.sh` |
| validate-ansible | `scripts/validate-ansible.sh` | `bash scripts/validate-ansible.sh` |

**Pre-commit hook** (run before git commit):
```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

set -euo pipefail

echo "[pre-commit] Running local validators..."
bash scripts/validate-python.sh || exit 1
bash scripts/validate-bash.sh || exit 1
bash scripts/validate-yaml.sh || exit 1

echo "[pre-commit] All checks passed ✓"
```

---

## Customization Checklist

When adapting template for new project:

- [ ] Copy `.github/workflows/trinity-ci-workflow.yml` from template
- [ ] Replace `{{ PROJECT_NAME }}` in workflow name
- [ ] Set `{{ PYTHON_VERSION }}` (check `requirements.txt` or `.python-version`)
- [ ] Define `{{ MYPY_PATHS }}` (typically `scripts/ tests/ src/`)
- [ ] Define `{{ RUFF_PATHS }}` (typically `.` for entire repo)
- [ ] Define `{{ BASH_PATHS }}` (typically `scripts/`)
- [ ] Define `{{ YAML_PATHS }}` (typically `.` or `config/`)
- [ ] Set `{{ COV_THRESHOLD }}` (70% minimum, 80%+ ideal)
- [ ] Add project-specific environment variables in `env:` section
- [ ] Uncomment optional jobs if needed (validate-ansible, validate-manifest)
- [ ] Configure secrets in GitHub repo settings
- [ ] Test locally first: `bash scripts/validate-*.sh`
- [ ] Push to feature branch first (no main protection yet)
- [ ] Review workflow run in Actions tab
- [ ] Merge after successful run

---

## Troubleshooting

### "CI Passes Locally, Fails in GitHub"

**Cause**: Environment differences (Python version, tool versions, OS)

**Solution**:
```yaml
# Pin exact versions in workflow
- name: Install dependencies
  run: |
    pip install mypy==1.8.0 ruff==0.2.1 bandit==1.7.5 pytest==7.4.3
```

### "Intermittent Failures"

**Cause**: Network timeouts, API rate limits, flaky tests

**Solution**:
```yaml
# Add retries with exponential backoff
- name: Run tests with retry
  uses: nick-fields/retry@v2
  with:
    timeout_minutes: 30
    max_attempts: 3
    retry_wait_seconds: 5
    command: pytest tests/
```

### "Coverage Threshold Failures"

**Cause**: New untested code added

**Solution**:
```python
# Option 1: Add tests
def test_new_function():
    assert new_function(5) == expected_result

# Option 2: Temporarily lower threshold with FIXME comment
# TODO: Coverage dropped to 65% due to new untested feature
# Deadline: 2025-12-30
```

### "SSH Key Issues"

**Cause**: Incorrect key format, permissions, or authentication

**Solution**:
```bash
# Test SSH access manually
ssh -i ~/.ssh/deploy_key git@github.com

# Verify key is ED25519 (preferred)
ssh-keygen -t ed25519 -C "ci-deployment"

# Check permissions (should be 600)
chmod 600 ~/.ssh/deploy_key
```

---

## Performance Optimization

### Cache Dependencies

```yaml
- name: Cache pip packages
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-
```

Saves ~1-2 minutes per run.

### Skip Jobs on Doc-Only Changes

```yaml
on:
  push:
    branches: [main, develop]
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - '.gitignore'
```

### Matrix Testing (Multi-Version)

```yaml
strategy:
  matrix:
    python-version: ['3.10', '3.11', '3.12']

- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: ${{ matrix.python-version }}
```

Runs all validation across 3 Python versions.

---

## Seven Pillars Alignment

| Pillar | CI Implementation | Example |
|--------|-------------------|---------|
| **Idempotency** | Linting enforces consistent structure | Multiple runs = same result |
| **Error Handling** | mypy --strict catches type errors | None dereference prevented |
| **Functionality** | pytest validates behavior | Unit tests confirm correctness |
| **Audit Logging** | Git commits + CI logs = audit trail | Every change traced |
| **Failure Recovery** | Job dependencies prevent cascading | Failed lint → skip tests |
| **Security Hardening** | bandit + shellcheck catch vulnerabilities | SQL injection warnings |
| **Documentation** | ruff D rules + yamllint + comments | Docstrings enforced |

---

## References

- [Trinity CI Workflow Template](.github/workflows/trinity-ci-workflow.yml)
- [Lint Configurations](../configs/)
- [Validator Scripts](../scripts/)
- [Line Length Standards](line-length-standards.md)
- [Hellodeolu v6](hellodeolu-v6.md)
- [Seven Pillars](seven-pillars.md)
- [Trinity Execution](trinity-execution.md)
