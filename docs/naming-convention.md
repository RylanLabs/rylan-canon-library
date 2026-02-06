# Kebab-Case Discipline (Naming Convention)

> Canonical Standard — Identity & Discovery
> Version: v1.0.0
> Status: ✅ ACTIVE
> Guardian: Bauer / Whitaker

---

## 1. The Core Principle

To ensure cross-platform compatibility, searchability, and 3 AM readability, all files in the RylanLabs Mesh must adhere to the **Kebab-Case Discipline**.

**Kebab-case** uses only lowercase letters, numbers, and hyphens to separate words.

### Regex Rule
`^[a-z0-9]+(-[a-z0-9]+)*\.md$`

---

## 2. Standards & Examples

| Type | Format | Example |
| :--- | :--- | :--- |
| **Operational Doc** | kebab-case | `inventory-discipline.md` |
| **Checklist** | kebab-case | `release-checklist.md` |
| **Architectural** | kebab-case | `tiered-satellite-hierarchy.md` |

### Exceptions
*   `README.md` (Root metadata)
*   `CHANGELOG.md` (Root metadata)
*   `MESH-MAN.md` (Root manual)
*   `Makefile` / `common.mk`
*   `LICENSE`

---

## 3. Automation & Enforcement

The discipline is enforced via the following Trinity mechanisms:

1.  **Whitaker Gate**: `scripts/whitaker-scan.sh` fails if non-compliant files are introduced.
2.  **Bauer Audit**: `make naming-audit` generates a JSON report of all violations.
3.  **Lazarus Remediation**: `scripts/rename-to-kebab.sh` can auto-fix violations.

### How to Fix
If you receive a naming violation error:
1.  Run `make naming-fix-interactive` to rename the file.
2.  Update any internal Markdown links to the new path.
3.  Commit the changes with a GPG-signed commit.

---

## 4. Rollback & Reversibility (RTO < 2m)

If a migration causes broken links or mesh instability, use the mapped rollback:
```bash
./scripts/rename-to-kebab.sh --rollback
```
Refer to `.audit/kebab-mapping.json` for historical mapping.

---
**Standardization is the bedrock of autonomy.**
The fortress endures.

