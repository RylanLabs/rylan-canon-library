# RylanLabs Mesh-Man: Operational Manual

---
title: Mesh-Man Operational Manual
version: v2.2.0-mesh
guardian: Bauer
date: 2026-02-05
compliance: Hellodeolu v7, Seven Pillars
---

> [!IMPORTANT]
> This manual is auto-generated from common.mk and the root Makefile. It represents the SINGLE SOURCE OF TRUTH for mesh orchestration.

## 🛡️ Core Infrastructure (Canon Library)
These targets are the 'Eternal Glue' used across the mesh.

| Target | Purpose | Guardian | Timing Estimate |
|:-------|:--------|:---------|:----------------|
| `cascade` | Distribute secrets/state through mesh (Beale) | Beale | 2m |
| `clean` | Remove temporary audit files and logs | Lazarus | 5s |
| `help` | Show shared targets | Bauer | <5s |
| `inject-canon` | Inject Tier 0 Canon into satellite (Bootstrap) | N/A | Unknown |
| `mesh-man` | Regenerate MESH-MAN.md operational manual | Carter | 10s |
| `mesh-remediate` | Force drift back to green (Lazarus) | Lazarus | 5m |
| `org-audit` | Multi-repo compliance scan (Whitaker) | Whitaker | 5m |
| `publish` | Sync state to mesh (Carter) | Carter | 60s |
| `re-init` | Re-sync repository with Canon Hub symlinks (Lazarus) | Lazarus | 20s |
| `refresh-readme` | Auto-generate README tier metadata from canon-manifest | Carter | <10s |
| `repo-init` | Bootstrap new repositories to RylanLabs standards | Lazarus | 2m |
| `resolve` | Materialize symlinks for Windows/WSL/CI compatibility (Agnosticism Pattern) | Beale | 15s |
| `rollback-canon` | Revert Phase 0 injection (Emergency Only) | N/A | Unknown |
| `test` | Run Bauer unit tests (Pytest) | Bauer | 30s |
| `validate` | Run standard Whitaker gates (Validator Suite) | Whitaker | 30s |
| `warm-session` | Establish 8-hour password-less GPG session (Asymmetric Warm) | N/A | Unknown |

### 3. Secure Publishing (Ansible Galaxy)

```bash
make publish ARGS="--dry-run" # Build and validate without pushing
make publish                  # Interactive prompt for token + [y/N] gate
```

* **Gate**: Controlled by `scripts/publish-gate.sh`.
* **Audit**: Logs results to `.audit/publish-gate.jsonl`.
* **Safety**: Automatic CI detection (auto-confirms if `CI=true` and token present).

## ⚖️ Compliance Standards

* **Idempotency**: All targets must be safe to run repeatedly.
* **Observability**: Every run produces an entry in `.audit/audit-trail.jsonl`.
* **Junior-Deployable**: Descriptions must be clear enough for a Level 1 engineer.
