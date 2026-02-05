# The Sentinel Loop: Continuous Compliance

> Canonical standard — Automated Governance
> Version: v1.0.0
> Date: 2026-02-04

---

## Overview

The Sentinel Loop is the event-driven heart of the RylanLabs Mesh. It ensures that the "Pact of Discipline" made during development is maintained in perpetuity through automated auditing and remediation.

---

## The Four Stages

### 1. Cascade (Provision)
The Hub (`rylan-inventory`) or Canon (`rylan-canon-library`) pushes out new standards or state.
- **Trigger**: Commit to Tier 0.
- **Action**: `make cascade`.

### 2. Audit (Detect)
Whitaker scans all satellite repos for compliance with the new state.
- **Trigger**: Every 4 hours (Scheduled Action).
- **Action**: `make org-audit`.
- **Output**: Drift report in `.audit/`.

### 3. Remediate (Fix)
Lazarus identifies drifted repos and attempts an automated fix.
- **Action**: `make mesh-remediate`.
- **Mechanism**: Auto-dependency updates, linter autofixes, and automated Pull Requests with Whitaker's verification.

### 4. Validate (Prove)
The final gate. The mesh proves it is back in a GREEN state.
- **Action**: `make validate`.

---

## Maturity Level 5 (Autonomous)

A repository achieves Maturity Level 5 when the Sentinel Loop can remediate 90% of drift without human intervention. The transition from Level 4 (Pinnacle/Manual) to Level 5 is marked by the activation of **Self-Healing Workflows** (`compliance-gate.yml`).

---

**Audit always. Remediate automatically.**
The Trinity endures.
