# Dependency Inheritance & Submodule Discipline

> Canonical standard — Dependency Management
> Version: v1.0.0
> Date: 2026-02-06
> Compliance: Hellodeolu v7, Seven Pillars

---

## Executive Summary

RylanLabs utilizes a **Tiered Dependency Model**. Repositories are "plug-and-play" modules that inherit logic, configuration, and security posture from lower-tier "Hubs" (e.g., Tier 0 Canon Library). 

This inheritance is achieved through a combination of `canon-manifest.yaml` declarations and **Git Submodules** anchored in the `.rylan/` substrate.

---

## 1. The "Plug/Unplug" Framing

A repository is defined by its dependencies. To "plug" into the RylanLabs mesh:
1.  **Declare**: Add the target repository name to the `dependencies` list in `canon-manifest.yaml`.
2.  **Attach**: Add the repository as a Git submodule under the `.rylan/` directory.
3.  **Sync**: Run `make sync-deps` or `./scripts/sync-canon.sh` to materialize the inheritance.

To "unplug", remove the dependency and clean the `.rylan/` path.

---

## 2. Submodule Wisdom (The 3 AM Guide)

Git submodules are powerful but "forgive no typos." Follow these rules to avoid "Submodule Hell":

### Avoid the Pitfalls
*   **The "Detached HEAD" Trap**: Submodules point to a specific *commit*, not a branch. When you `cd` into a submodule, you are in a detached HEAD state. 
    *   *Correction*: Never commit directly inside a submodule unless you explicitly `git checkout <branch>` first.
*   **The "Forgot to Push" error**: If you commit a submodule reference to the parent repo but forget to push the submodule commit itself, CI will fail for everyone else.
    *   *Correction*: Use `git push --recurse-submodules=check` to prevent pushing the parent if the child is missing.
*   **The "Dirty Submodule" ghost**: Sometimes a submodule shows as modified even if you changed nothing.
    *   *Correction*: Run `git submodule update --init --recursive` to reset it to the recorded commit.

### Proactive Best Practices & Hardened Gates (Bauer/Beale/Whitaker)

* **Flat Structure**: Always place submodules in `.rylan/` (e.g., `.rylan/rylan-inventory`).
    Keep the dependency graph readable by avoiding nesting.
* **Deterministic Versioning**: Submodules pin a repository to a specific SHA.
    This ensures builds remain consistent over time.
* **Deterministic Sync (The Cascade)**: Inheritance MUST happen in sequence:
    1. Tier 0 (Library) -> 2. Tier 0.5 (Vaults) -> 3. Tier 1 (Inventory) -> 4. Tier 2+ (Services).
* **Beale Allow-List**: Every submodule URL must be explicitly authorized within the RylanLabs organization.
    External URLs are blocked by default to prevent supply chain poisoning.
* **Whitaker Head Protection**: Commits on "Detached HEADs" are blocked.
    The `whitaker-detached-head.sh` hook ensures you are on a branch before making changes.
* **Lazarus Remediation**: When drift or corruption is detected, `sentinel-sync.yml` can automatically
    attempt to re-anchor the repository to the canonical ground truth.

---

## 3. Automation vs. Manual Labor

> "If a Jr Dev can't fix it at 3 AM with one command, the automation has failed."

We do not expect developers to remember complex `git submodule` flags.

* **Initialization**: `make resolve` (internalizes submodules and copies sacred files).
* **Validation**: `make validate` (runs audit-canon.sh to ensure zero-drift).
* **Update**: `make sync-deps` (safely pulls latest canonical versions with GPG verification).

---

## 4. Comparison of Approaches

| Approach | Verdict | Rationale |
| :--- | :--- | :--- |
| **Monorepo** | Rejected | Too much blast radius; difficult to manage distinct security tiers (e.g. Tier 0.5 Vault). |
| **Package Managers** | Secondary | Used for Python/Node libraries, but insufficient for "Sacred Patterns" (YAML/Bash/Markdown). |
| **Git Submodules** | **CANONICAL** | Native to Git, supports deterministic SHAs, and allows flat file inheritance via `sync-canon.sh`. |

---

## Checklist for Implementation

* [ ] Repository added to `dependencies` in `canon-manifest.yaml`.
* [ ] Submodule added: `git submodule add <url> .rylan/<name>`.
* [ ] `CANON_LIB_PATH` points to `.rylan/rylan-canon-library` in `Makefile`.
* [ ] GPG signature verification enabled for submodule pulls.
* [ ] `make validate` returns green.

---

**Federated discipline. Centralized standards.**
The fortress endures.

