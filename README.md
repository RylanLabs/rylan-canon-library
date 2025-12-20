# RylanLabs Canon Library

> Canonical reference — RylanLabs eternal standard
> Organization: RylanLabs
> Date: December 20, 2025

**Status**: 🔄 In formation — Philosophy complete, execution beginning

---

## Purpose

**rylan-canon-library** is the **single source of truth** for all RylanLabs discipline, standards, and operational doctrine.

It contains:
- **Philosophical foundations** — Seven Pillars, Trinity + Whitaker, Hellodeolu v6
- **Operational standards** — Ansible discipline, inventory, vault
- **Evolving lessons** — Extracted from real projects
- **Canonical templates** — Repo structure, documentation

**Not in this repo**:
- Reusable code libraries
- Secrets or credentials
- Device inventory
- Playbooks or roles

**What this repo does**:
- Defines non-negotiable standards
- Ensures consistency across organization
- Preserves earned wisdom
- Enables junior-at-3-AM understanding

---

## Current Canon Status

| Aspect              | Status | Notes                                      |
|---------------------|--------|--------------------------------------------|
| Philosophy          | ✅     | Seven Pillars, Trinity, eternal glue complete |
| Ansible Standards   | ✅     | ansible-discipline.md production-grade     |
| Bash Standards      | ✅     | bash-discipline.md complete                |
| Eternal Glue        | ✅     | 6 sacred artifacts defined                 |
| Templates           | 🔄     | CONTRIBUTING, README templates             |
| Code Patterns       | ⏳     | To be earned from execution                |
| Domain Repos        | 📋     | Planned (samba, freeradius, etc.)          |

---

## Core Contents

```
rylan-canon-library/
├── README.md
├── RYLANLABS-INSTRUCTION-SET.md
├── docs/
│   ├── seven-pillars.md
│   ├── hellodeolu-v6.md
│   ├── eternal-glue.md
│   ├── no-bypass-culture.md
│   ├── irl-first-approach.md
│   ├── bash-discipline.md
│   └── ansible-discipline.md
└── templates/
    ├── CONTRIBUTING-template.md
    └── README-template.md
```

---

## Quick Start

1. **Read Philosophy** (30 min):
   - [seven-pillars.md](docs/seven-pillars.md)
   - [eternal-glue.md](docs/eternal-glue.md)

2. **Understand Trinity**:
   - Carter → Identity
   - Bauer → Verification
   - Beale → Hardening
   - Whitaker → Offensive validation

3. **Apply Standards**:
   - Use templates for new repos
   - Follow ansible-discipline.md for IaC

---

## Sacred Glue (Homelab Edition)

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
