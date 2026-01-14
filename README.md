# RylanLabs Canon Library

> Canonical reference — RylanLabs eternal standard
> Organization: RylanLabs
> Version: v1.0.0
> Date: January 13, 2026

**Status**: ✅ **PRODUCTION** — Tier 0 Source of Truth

---

## Purpose

**rylan-canon-library** is the **single source of truth** for all RylanLabs discipline, standards, and operational doctrine.

It is a **Tier 0** repository, meaning all other repositories align with or symlink to the patterns defined here.

It contains:
- **Philosophical foundations** — Seven Pillars, Trinity + Whitaker, Hellodeolu v6
- **Operational standards** — Ansible discipline, inventory, vault, VLAN scheme
- **7-Task Workflow** — GATHER → PROCESS → APPLY → VERIFY → AUDIT → REPORT → FINALIZE
- **Evolving lessons** — Extracted from real projects
- **Canonical templates** — Repo structure, documentation, playbooks

**Not in this repo**:
- Reusable code libraries (unless as templates)
- Secrets or credentials
- Device inventory
- Implementation code (Guidance only)

**What this repo does**:
- Defines non-negotiable standards
- Ensures consistency across organization
- Preserves earned wisdom
- Enables junior-at-3-AM understanding
- Enforces **Zero Bypass Culture**

---

## Current Canon Status

| Aspect              | Status | Notes                                      |
|---------------------|--------|--------------------------------------------|
| Philosophy          | ✅     | Seven Pillars, Trinity, eternal glue complete |
| Ansible Standards   | ✅     | 7-Task Workflow + inventory/ansible.cfg patterns |
| Bash Standards      | ✅     | bash-discipline.md + shfmt-standards.md    |
| CI/CD Templates     | ✅     | 7-job Trinity CI/CD workflow (v1.0.0)      |
| VLAN Canon          | ✅     | Canonical 5-VLAN scheme (v1.0.0)           |
| Vault 8-Phase       | ✅     | 8-Phase Rotation process documented        |
| Lint Configs        | ✅     | All 7 tools: ruff, mypy, bandit, yamllint, etc. |
| Validator Scripts   | ✅     | 4 portable scripts (python, bash, yaml, ansible) |
| Eternal Glue        | ✅     | 6 sacred artifacts defined                 |
| Templates           | ✅     | Playbooks, device manifests, READMEs       |

---

## Core Contents

```
rylan-canon-library/
├── README.md                           # Organization anchor
├── RYLANLABS-INSTRUCTION-SET.md        # Canonical standards
├── CHANGELOG.md                        # Version history & extraction notes
│
├── configs/                            # ⭐ NEW: Lint configurations
│   ├── .yamllint                       # YAML linting (120/140 dual)
│   ├── pyproject.toml                  # Python tools (ruff, mypy, bandit, pytest)
│   └── .shellcheckrc                   # ShellCheck exception rules
│
├── scripts/                            # ⭐ NEW: Portable validators
│   ├── validate-python.sh              # mypy + ruff + bandit
│   ├── validate-bash.sh                # shellcheck + shfmt
│   ├── validate-yaml.sh                # yamllint
│   └── validate-ansible.sh             # ansible-lint + syntax check
│
├── ansible/                            # ⭐ NEW: Ansible canon (Phase 1)
│   ├── inventory-patterns.md           # Hybrid static+dynamic inventory
│   └── ansible.cfg-reference.md        # Canonical ansible.cfg
│
├── docs/
│   ├── seven-pillars.md                # Core philosophy
│   ├── hellodeolu-v6.md                # RTO constraints
│   ├── eternal-glue.md                 # 6 sacred artifacts
│   ├── no-bypass-culture.md            # Discipline
│   ├── irl-first-approach.md           # Manual before automation
│   ├── bash-discipline.md              # Bash standards
│   ├── ansible-discipline.md           # Ansible patterns
│   ├── vault-discipline.md             # Secret management
│   ├── trinity-execution.md            # Carter/Bauer/Beale roles
│   ├── inventory-discipline.md         # Device management
│   │
│   ├── ci-workflow-guide.md            # ⭐ NEW: CI/CD architecture
│   ├── shfmt-standards.md              # ⭐ NEW: Bash formatting
│   ├── line-length-standards.md        # ⭐ NEW: Line length rules
│   └── extraction-manifest.md          # ⭐ NEW: What was extracted
│
├── templates/
│   ├── CONTRIBUTING-template.md
│   ├── README-template.md
│   └── README.md
│
├── .github/
│   ├── workflows/
│   │   ├── trinity-ci-workflow.yml     # ⭐ NEW: 7-job CI template
│   │   └── canon-validate.yml          # ⭐ NEW: Self-validation
│   │
│   └── instructions/
│       └── RYLANLABS-INSTRUCTION-SET.md.instructions.md
│
└── patterns/
    └── validate-bash.sh                # Original validator
```

---

## Quick Start

### 1. Read Philosophy (30 min)

- [seven-pillars.md](docs/seven-pillars.md) — Core standards
- [eternal-glue.md](docs/eternal-glue.md) — Trinity + artifacts
- [hellodeolu-v6.md](docs/hellodeolu-v6.md) — RTO constraints

### 2. Understand Production Standards (v4.5.1)

**Lint & Validation**:
- [configs/pyproject.toml](configs/pyproject.toml) — Python tools (ruff, mypy, bandit, pytest)
- [configs/.yamllint](configs/.yamllint) — YAML linting with 120/140 dual standard
- [docs/line-length-standards.md](docs/line-length-standards.md) — Why these limits

**Bash Standards**:
- [docs/shfmt-standards.md](docs/shfmt-standards.md) — Formatting rules (-i 2 -ci -bn)
- [bash-discipline.md](docs/bash-discipline.md) — Best practices

**CI/CD**:
- [.github/workflows/trinity-ci-workflow.yml](.github/workflows/trinity-ci-workflow.yml) — 7-job template
- [docs/ci-workflow-guide.md](docs/ci-workflow-guide.md) — Architecture & customization

**Ansible**:
- [ansible/inventory-patterns.md](ansible/inventory-patterns.md) — Hybrid static+dynamic
- [ansible/ansible.cfg-reference.md](ansible/ansible.cfg-reference.md) — Canonical settings
- [ansible-discipline.md](docs/ansible-discipline.md) — Playbook patterns

### 3. Use Portable Validators

```bash
# Local validation (runs same checks as CI)
bash scripts/validate-python.sh   # mypy + ruff + bandit
bash scripts/validate-bash.sh     # shellcheck + shfmt
bash scripts/validate-yaml.sh     # yamllint
bash scripts/validate-ansible.sh  # ansible-lint + syntax

# All must pass locally before CI
```

### 4. Adopt Canon in New Project

```bash
# Copy config templates
cp -r configs/ my-new-project/
cp -r scripts/ my-new-project/
cp -r .github/workflows/ my-new-project/.github/

# Customize placeholders in .github/workflows/trinity-ci-workflow.yml
# - Replace {{ PROJECT_NAME }}
# - Set {{ PYTHON_VERSION }}
# - Define paths

# Test locally first
cd my-new-project
bash scripts/validate-python.sh
bash scripts/validate-bash.sh

# Push to GitHub → CI runs automatically
```

See [docs/extraction-manifest.md](docs/extraction-manifest.md) for adoption guide.

## What's New in v4.5.1 (December 22, 2025)

✅ **Extracted from rylan-inventory v4.3.1** — Production patterns from 23-device network

### Lint Configuration Canon
- **configs/.yamllint** — YAML 120/140 dual standard
- **configs/pyproject.toml** — Python tooling (ruff, mypy, bandit, pytest with 70% coverage)
- **configs/.shellcheckrc** — ShellCheck exception rules
- **docs/shfmt-standards.md** — Bash formatting (-i 2 -ci -bn)
- **docs/line-length-standards.md** — Line length rationale (120 code, 80 markdown, 72 git)

### CI/CD Trinity Workflow
- **.github/workflows/trinity-ci-workflow.yml** — 7-job template (Jinja2 placeholders, 14 customization points)
- **docs/ci-workflow-guide.md** — Architecture, job descriptions, troubleshooting
- Jobs: validate-python, validate-bash, validate-yaml, test-unit, security-scan, optional ansible/manifest, summary

### Portable Validator Scripts
- **scripts/validate-python.sh** — mypy + ruff + bandit (5 phases)
- **scripts/validate-bash.sh** — shellcheck + shfmt (3 phases)
- **scripts/validate-yaml.sh** — yamllint validation
- **scripts/validate-ansible.sh** — ansible-lint + syntax check
- All: Colored output, auto-fix suggestions, CI-ready

### Ansible Production Patterns (Phase 1)
- **ansible/inventory-patterns.md** — Hybrid static manifest + dynamic API discovery
- **ansible/ansible.cfg-reference.md** — Canonical settings with performance tuning
- **ansible-discipline.md** (updated) — Comprehensive playbook patterns

### Self-Validation
- **.github/workflows/canon-validate.yml** — Canon repo self-tests
- **docs/extraction-manifest.md** — What was extracted, why, adoption guide

### Documentation
- **CHANGELOG.md** — Full version history
- **README.md** (this file) — Updated with production canon

**Total**: 14 new files, ~2,260 lines of code + documentation

See [CHANGELOG.md](CHANGELOG.md) for complete details.

| Path                                      | Function                              | Why Sacred                          |
|-------------------------------------------|---------------------------------------|-------------------------------------|
| rylanlabs-private-vault/                  | All credentials                       | Carter — Zero trust foundation      |
| rylan-inventory/device-manifest.yml       | Device catalogue                      | Carter — Single source of truth     |
| rylan-homelab-iac/playbooks/site.yml      | One-command apply                     | Bauer — Idempotent orchestration    |
| rylan-homelab-iac/scripts/defense-tests.sh| Breach simulation                     | Whitaker — Proof defenses work      |
| rylan-homelab-iac/backups/latest-config.json| Controller backup                  | Beale — Reversibility               |
| rylan-canon-library/docs/                 | All principles                        | Documentation Clarity                |

---

## Organization Structure

- **rylan-canon-library** ← Doctrine (you are here)
- **rylanlabs-private-vault** ← Secrets
- **rylan-inventory** ← Devices
- **rylan-homelab-iac** ← Orchestration
- **Domain repos** ← Specialized (future)

---

## Next Steps

1. Create private vault repo
2. Create inventory repo
3. Bootstrap rylan-homelab-iac
4. Execute first playbook
5. Earn patterns → add to canon

---

## The Fortress Endures

**The fortress demands discipline. No shortcuts. No exceptions.**

Philosophy complete → execution now.

The Trinity endures.
