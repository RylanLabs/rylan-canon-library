# Mesh Paradigm: The Self-Discovering Organizational Mesh

> Canonical standard — Multi-repo orchestration
> Version: v1.0.0
> Date: 2026-02-04

---

## Overview

The RylanLabs Mesh is a **federated, tiered, and self-healing network of repositories**. It moves away from monolithic or loosely-coupled repos toward a structured hierarchy where standards (Tier 0) cascade to satellites.

### Hub & Satellite Model
- **Hub (`rylan-inventory`)**: The operational anchor. Holds the device manifest and orchestrates mesh-wide audits.
- **Satellites (e.g., `network-iac`)**: Functional units that consume the canon and report state back to the hub.

---

## The Tiered Architecture

| Tier | Role | Example | Description |
|------|------|---------|-------------|
| **0** | **Canon** | `rylan-canon-library` | SSOT for discipline, patterns, and common abstractions. |
| **0.5**| **Vault** | `rylanlabs-private-vault` | Secrets storage consumed by all tiers. |
| **1** | **Hub** | `rylan-inventory` | The operational state anchor and device SSOT. |
| **2** | **Core** | `rylan-labs-common` | Shared utilities and shared execution logic. |
| **3** | **Apps** | `rylan-labs-network-iac` | Specific implementations and deployments. |

---

## Mesh Mechanics

### 1. The Common Substrate (`common.mk`)
All repos in the mesh must include `common.mk` (Tier 0). This ensures uniform targets (`validate`, `publish`, `cascade`) across the organization.

### 2. Topic-Based Routing
Secrets and state updates are categorized by **topics** (e.g., `topic:unifi`, `topic:backups`). Satellites subscribe to topics to receive only the relevant fragments of the global state.

### 3. The Sentinel Loop (Continuous Compliance)
1. **Cascade**: Hub pushes updates to satellites.
2. **Audit**: Whitaker scans mesh for drift or linter debt.
3. **Remediate**: Lazarus forces drifting repos back to canonical GREEN via auto-PR.

---

**The mesh is the fortress. The tiers are the walls.**
The Trinity endures.
