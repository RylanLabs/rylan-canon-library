# Known Gaps & Legacy Technical Debt

This document catalogs deviations from Rylan Canon standards that are currently tolerated under "Phase: Initial" maturity.

## ML5 Scorecard Gaps (Current Score: 1.2/10)

### 1. Bare Exception Handlers

- **Count**: 41
- **Severity**: High (Safety/Idempotency risk)
- **Problem**: Use of `except:` or `except Exception:` masks critical failures and complicates debugging.
- **Remediation**: Replace with specific exception types (e.g., `ValueError`, `IOError`) or add logging/re-raise logic.

### 2. Unsigned Early Commits

- **Count**: 27 / 44 Commits (Total checked)
- **Severity**: Medium (Audit/Attestation risk)
- **Problem**: Historical commits prior to the enforcement of GPG signing lack verifiable provenance.
- **Remediation**: Scoped baseline to post-v1.0.0 commits. New commits MUST be signed.

### 3. Hardcoded Paths / Environment Assumptions

- **Count**: 2
- **Problem**: Legacy scripts using absolute paths instead of relative/workspace-root resolution.
- **Remediation**: Use `REPO_ROOT` variables and workspace-relative paths.

---
*Created per Trinity Gate directive - Tolerated until Phase B Integration.*
