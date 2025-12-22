---
applyTo: '**'
---
# RylanLabs Instruction Set

> Canonical instruction set — RylanLabs standard
> Organization: RylanLabs
> Version: 0.0.1
> Date: 20/12/2025

---

## Purpose

Single source of truth for all RylanLabs repositories.
Defines non-negotiable standards for code quality, security, resilience, and culture.

**Objectives**:

- Production-grade code everywhere
- Junior-at-3-AM deployable
- Zero drift, zero bypass
- Understanding over blind compliance
- Sustainable discipline through education

---

## Core Principles — Seven Pillars

1. **Idempotency**
   Safe to run multiple times — identical outcome.

2. **Error Handling**
   Fail fast, fail loud, provide context.

3. **Audit Logging**
   Every action traceable — timestamped, structured.

4. **Documentation Clarity**
   Junior at 3 AM can understand and execute.

5. **Validation**
   Verify inputs, preconditions, postconditions.

6. **Reversibility**
   Rollback path always exists.

7. **Observability**
   Visibility into state and progress.

**Hellodeolu v6 Alignment**:
All pillars mandatory. No exceptions.

---

## Development Standards

### Bash Canon

```bash
#!/usr/bin/env bash
# Script: <name>.sh
# Purpose: <one-line purpose>
# Agent: <Carter|Bauer|Beale>
# Author: rylanlab canonical
# Date: YYYY-MM-DD
set -euo pipefail
IFS=$'\n\t'
```

**Mandatory**:
- `set -euo pipefail`
- Trap ERR + EXIT cleanup
- ShellCheck clean
- kebab-case filenames
- snake_case functions
- UPPER_SNAKE_CASE constants

### Python Canon

- mypy --strict
- ruff check --select ALL
- ruff format
- bandit -r . -ll
- pytest --cov-fail-under=80
- pyproject.toml only

---

## Operational Standards

**Junior-at-3-AM Deployable**:

- One-command from clean system
- Clear errors + remediation
- Pre/post validation
- Rollback built-in

**Security**:

- No cleartext secrets
- Least privilege
- SSH key-only
- chmod 600 secrets

**Version Control**:

- Semantic versioning
- Branch protection on main
- Required review
- Canonical commit format

**Commit Format**:

```
<type>(<scope>): <subject>

<body: what + why>

<footer>
```

Types: feat, fix, docs, refactor, test, chore, security

---

## Cultural Canon

### No Bypass Culture

- No `--no-verify`, `[ci skip]`, manual overrides
- Bypass attempt → loud failure + discussion required
- Right way = only way

### IRL-First Approach

1. Learn principles manually
2. Practice with feedback
3. Validate understanding
4. Introduce automation
5. Maintain human oversight

**Philosophy**: Discipline through understanding, not enforcement.

---

## Trinity Alignment

### Identity (Carter)

Bootstrap identity (Samba AD/DC, RADIUS, 802.1X).
Everything starts with who you are.

### Verification (Bauer)

Verify everything (SSH hardening, GitHub keys, zero lint debt).
Nothing passes unverified.

### Hardening (Beale)

Harden the host, detect the breach (Bastille automation, Snort/Suricata).
Fortress walls + early warning.

**Execution Order**:

1. Carter → Identity first
2. Bauer → Verify intent
3. Beale → Harden + detect

Offensive validation tests all three.

---

## Repository Structure (Mandatory)

```
repo/
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── .gitignore
├── .github/
│   ├── agents/          # Agent configuration files
│   └── instructions/    # Instruction sets for agents/automation
├── docs/                # Documentation
├── scripts/             # Operational scripts
├── src/                 # Source code
└── tests/               # Test suite
```

---

## Validation Gates (Pre-Merge)

- All linters PASS
- Tests PASS + coverage
- Security scans clean
- Documentation updated
- Seven Pillars demonstrated
- No bypass attempts

---

**The fortress demands discipline. No shortcuts. No exceptions.**

The Trinity endures.
