# RylanLabs Mesh-Man: Operational manual

---
title: Mesh-Man Operational Manual
version: v2.1.0-mesh
guardian: Bauer
date: 2026-02-04
---

> [!IMPORTANT]
> This manual is auto-generated. It represents the SINGLE SOURCE OF TRUTH for all mesh operations.

## 🛡️ Core Infrastructure (Canon Library)
These targets are executed from the `rylan-canon-library` anchor.

```bash
make[1]: Entering directory '/home/egx570/repos/rylan-canon-library'
[36mMakefile            [0m Topic-driven secret distribution (Beale)
[36mMakefile            [0m Clean local artifacts
[36mMakefile            [0m Show this help
[36mMakefile            [0m Generate MESH-MAN.md coverage documentation
[36mMakefile            [0m Force drift back to green (Lazarus)
[36mMakefile            [0m Multi-repo compliance scan (Whitaker)
[36mMakefile            [0m Heartbeat: Sign, Tag, and Push (Carter)
[36mMakefile            [0m Meta-GitOps: Declarative state reconciliation
[36mMakefile            [0m Bootstrap new repositories to RylanLabs standards
[36mMakefile            [0m Run Whitaker/Sentinel compliance gates (Security/Linter)
[36mMakefile            [0m Establish 8-hour password-less GPG session (Asymmetric Warm)
[36mcommon.mk           [0m Distribute secrets/state through mesh (Beale)
[36mcommon.mk           [0m Show shared targets
[36mcommon.mk           [0m Force drift back to green (Lazarus)
[36mcommon.mk           [0m Multi-repo compliance scan (Whitaker)
[36mcommon.mk           [0m Sync state to mesh (Carter)
[36mcommon.mk           [0m Run standard Whitaker gates
make[1]: Leaving directory '/home/egx570/repos/rylan-canon-library'
```

## 🌊 Satellite Standard Targets
All satellites inheriting `common.mk` support these standard targets:

| Target | Purpose | Guardian |
|--------|---------|----------|
| `validate` | Run Whitaker/Sentinel compliance gates | Bauer |
| `warm-session` | Establish GPG session for SOPS | Carter |
| `cascade` | Sync with Tier 0 Canon | Beale |
| `clean` | Purge local artifacts | - |

## 🧠 Architecture Reference
- [Seven Pillars](docs/seven-pillars.md): Core IaC principles
- [Trinity Execution](docs/trinity-execution.md): 5-Agent operational model
- [Hellodeolu v7](docs/hellodeolu-v7.md): Autonomous Governance Architecture
- [Mesh Paradigm](docs/eternal-glue.md): Multi-repo orchestration
