# Multi-Repo Mesh: Tiered Governance

> Canonical standard — Repository standards
> Version: v1.0.0
> Date: 2026-02-04

---

## Overview

Multi-repo governance ensures that as the organization grows, discipline does not dilute. Every repo in the mesh must adhere to the **Tier 0 Standards**.

---

## Repository Requirements

Every mesh-compliant repository must contain:
1. **`Makefile`**: Including `common.mk` and implementing mesh targets.
2. **`.github/instructions/`**: Local agent instructions synced from Tier 0.
3. **`validate.sh`**: Locally executable gate (Whitaker).
4. **`.gitleaks.toml`**: Mandatory leak detection.
5. **`README.md`**: Standard structure with attribution.

---

## Cascade Workflow

Updates to the Canon (Tier 0) are propagated through the mesh using the `cascade` mechanism:

1. **Change in Tier 0**: New script or doc update.
2. **Mesh publish**: Tier 0 triggers a mesh-wide `publish`.
3. **Satellite sync**: Satellites receive the update via Git submodule or `sync-canon.sh` wrapper.
4. **Audit**: The Sentinel loop verifies all satellites have adopted the change.

---

## Topic-Driven Management

Repos are tagged with GitHub topics to determine their role the mesh:
- `rylan-mesh-hub`: The anchor repo.
- `rylan-mesh-satellite`: Consumes standards.
- `topic:unifi`, `topic:ansible`, `topic:python`: Specific functional topics.

---

**Federated discipline. Centralized standards.**
The Trinity endures.
