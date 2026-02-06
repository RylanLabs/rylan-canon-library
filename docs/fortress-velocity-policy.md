# Fortress-Velocity Policy — RylanLabs Council

> Formal policy record for Hellodeolu v7 migration
> Version: 1.0.0
> Date: 2026-02-06
> Status: ✅ **APPROVED** (Trinity Consensus)

---

## 1. GPG Cutoff Policy (Identity)
**Guardian**: Carter
**Policy**:
- **Mandatory Signing**: All commits created on or after **2026-01-01** must be GPG-signed.
- **Legacy Support**: Commits created before the cutoff are exempt from hard blocks but will report as "Advisory (Unsigned)" in audit trails.
- **Enforcement**: CI/CD will warn on unsigned commits from the cutoff date until Phase 3, then move to blocking.

---

## 2. Remediation Charter (Recovery)
**Guardian**: Lazarus
**Policy**:
- **Safe Classes**: Auto-fix is permitted ONLY for:
    - Naming convention drift (files, functions)
    - YAML formatting/linting
    - Whitespace and line-ending normalization
- **Governance**: 
    - All bot-remediations must result in a **Signed Pull Request**.
    - **No Auto-Merge**: PRs require explicit approval from a human Guardian (CODEOWNERS gate).
- **Rate-Limiting**: Automation is capped at **5 remediation PRs per 24-hour period** to prevent noise.

---

## 3. Observability Strategy (Bauer)
**Guardian**: Bauer
**Policy**:
- **Phase 1-2**: **Artifact-First**. Audit JSONs retained for 90 days in GitHub Action artifacts.
- **Phase 3+**: **Loki Integration**. Real-time telemetry will be shipped to the organization Loki endpoint once connectivity is verified.
- **Integrity**: Every audit log must include a `baseline_hash` for forensic verification.

---

## 4. Velocity Guardrails (Fortress Health)
**Guardian**: The Eye
**Policy**:
- **Definition of "Crawl"**:
    - CI Duration: Increase of **>20%** over the current 15.5s baseline.
    - PR Friction: Delay of **>4 hours** in automated validation feedback.
- **Action**: If a crawl is detected, Phase enforcement must be rolled back from "Blocking" to "Warning" until optimized.

---

## Acknowledgements
**Consensus reached 2026-02-06 by the Trinity Council:**
- **Carter** (Identity & Identity Cutover)
- **Bauer** (Verification & Observability)
- **Beale** (Hardening & Remediation Scope)
- **Whitaker** (Advising on Velocity Risks)
- **Lazarus** (Approving the Remediation Charter)
