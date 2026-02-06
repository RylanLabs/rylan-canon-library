# Kebab-Case Discipline (Naming Convention)

> Canonical Standard — Identity & Discovery
> Version: v1.0.0
> Status: ✅ ACTIVE
> Guardian: Bauer / Whitaker

---

## 1. The Core Principle

To ensure cross-platform compatibility, searchability, and 3 AM readability, all files in the RylanLabs Mesh must adhere to the **Kebab-Case Discipline**.

**Kebab-case** uses only lowercase letters, numbers, and hyphens to separate words.

### Regex Rules

| Extension | Format | Regex |
| :--- | :--- | :--- |
| `.md` | kebab-case | `^[a-z0-9]+(-[a-z0-9]+)*\.md$` |
| `.sh` | kebab-case | `^[a-z0-9]+(-[a-z0-9]+)*\.sh$` |
| `.py` | snake_case | `^[a-z0-9]+(_[a-z0-9]+)*\.py$` |

---

## 2. Standards & Examples

| Type | Format | Example |
| :--- | :--- | :--- |
| **Operational Doc** | kebab-case | `inventory-discipline.md` |
| **CLI Script** | kebab-case | `rotate-ssh-keys.sh` |
| **Python Module** | snake_case | `audit_helper.py` |
| **Architectural** | kebab-case | `tiered-satellite-hierarchy.md` |

### Allowed Exceptions

* `README.md`, `CHANGELOG.md`, `MESH-MAN.md` (Root metadata)
* `Makefile`, `common.mk`
* `LICENSE`
* `__init__.py` (Python package marker)
* `test_*.py` (Standard test naming)
* Binaries or legacy CLI helpers with documented exceptions.

---

## 3. Advanced Discipline

* **Unicode Normalization**: All filenames must be normalized via NFKC form.
* **Safety**: Strip unsafe characters; avoid case-insensitive collisions (e.g., `File.md` and `file.md`).
* **Submodules**: Fix naming violations inside nested repositories first, then update the parent pointer.

---

## 4. Automation & Enforcement

The discipline is enforced via the following Trinity mechanisms:

1. **Whitaker Gate**: `scripts/whitaker-scan.sh` fails if non-compliant files are introduced.
2. **Bauer Audit**: `make naming-audit` generates a JSON report of all violations.
3. **Lazarus Remediation**: `scripts/rename-to-kebab.sh` can auto-fix violations.

### How to Fix

1. Run `make naming-fix-interactive` to rename the file.
2. Update any internal Markdown links to the new path.
3. Commit the changes with a GPG-signed commit.

---

## 5. Rollback & Reversibility (RTO < 2m)

If a migration causes broken links or mesh instability, use the mapped rollback:

```bash
./scripts/rename-to-kebab.sh --rollback
```

Refer to `.audit/kebab-mapping.json` for historical mapping.

---
**Standardization is the bedrock of autonomy.**
The fortress endures.

