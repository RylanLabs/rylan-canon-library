# RylanLabs Tier 0 Canon Library

> **The Single Source of Truth for Organizational Discipline.**
> Version: v2.1.0 (Mesh-Aligned)
> Status: ✅ PRODUCTION

## Repository Metadata

| Attribute | Value |
| :--- | :--- |
| **Tier** | 0 (Canonical Standards) |
| **Type** | Governance (rylan-*) |
| **Naming Convention** | \`rylan-canon-library\` |
| **Dependencies** | None (Root) |
| **Maturity Level** | 5 (Autonomous) |
| **Status** | Production |
| **Guardian** | Trinity Council |
| **Ministry** | Oversight |

## Overview

The \`rylan-canon-library\` is the Tier 0 anchor for the RylanLabs Mesh. It defines the philosophical pillars,
operational standards, and shared abstractions (\`common.mk\`) consumed by all other repositories in the mesh.

### The Paradigm Shift

We have moved from static documentation to a **federated meta-GitOps mesh**. In this environment,
the \`Makefile\` is the entry point, and \`ansible\` is the infrastructure execution layer.

---

## The Seven Pillars (v7)

1. **Idempotency**: Safe to run multiple times.
2. **Error Handling**: Fail fast, fail loud, provide context.
3. **Audit Logging**: Every action traceable.
4. **Documentation Clarity**: Junior-at-3-AM ready.
5. **Validation**: Verify before change.
6. **Reversibility**: Rollback path always exists (RTO <15min).
7. **Observability**: Visibility into state and progress.

---

## Mesh Tiers

- **Tier 0**: `rylan-canon-library` (Sacred Standards)
- **Tier 0.5**: `rylanlabs-private-vault` (Asymmetric Secrets)
- **Tier 1**: `rylan-inventory` (Operational Hub)
- **Tier 2**: Core Utilities
- **Tier 3**: Satellite Applications

---

## Quick Start

### 1. Warm the session (Identity)

```bash
make warm-session
```

### 2. Validate current state (Verification)

```bash
make validate
```

### 3. Publish to Galaxy (Extraction)

```bash
make publish ARGS="--dry-run"
```

### 4. Initialize a new Mesh repository

```bash
./scripts/repo-init.sh my-new-repo
```

---

## The Trinity+ Expansion

- **Carter**: Identity & Bootstrap
- **Bauer**: Verification & Audit
- **Beale**: Hardening & Isolation
- **Whitaker**: Offensive Validation
- **Lazarus**: Recovery & Resilience

---

## Validation Framework (Maturity Level 5)

The library provides autonomous validators that enforce the "No-Bypass" culture:

| Script | Agent | Mission | Features |
| :--- | :--- | :--- | :--- |
| `validate-sops.sh` | Whitaker | Secret Integrity | MAC verification, Key rotation checks |
| `validate-yaml.sh` | Bauer/Lazarus | Config Discipline | Auto-remediation, JSON audits, Heritage checks |
| `validate-bash.sh` | ShellCheck | Logic Hardening | POSIX compliance, Trap enforcement |

### Using the YAML Validator

```bash
# Standard validation (CI mode)
./scripts/validate-yaml.sh

# Remediation mode (Fixes whitespace/EOF)
./scripts/validate-yaml.sh --fix
```

### Bauer Audits

Every run generates a machine-readable audit in `.audit/validate-yaml.json` for ingestion by higher-level Trinity agents.

---

**The fortress demands discipline. No shortcuts. No exceptions.**

The Trinity endures.
