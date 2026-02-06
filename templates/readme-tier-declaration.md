# {{ REPO_NAME }}

## Repository Metadata

| Attribute | Value |
|-----------|-------|
| **Tier** | {{ TIER_NUMBER }} ({{ TIER_NAME }}) |
| **Type** | {{ TYPE }} |
| **Naming Convention** | {{ PREFIX }}* |
| **Dependencies** | {{ DEPENDENCIES }} |
| **Maturity Level** | {{ MATURITY_LEVEL }} |
| **Status** | {{ STATUS }} |
| **Guardian** | {{ GUARDIAN }} |
| **Ministry** | {{ MINISTRY }} |

### Tier Hierarchy

```
Tier 0 (Canon) -> Tier 0.5 (Secrets) -> Tier 1 (Inventory) -> Tier 2 (Shared) -> Tier 3 (Logic) -> Tier 4 (Execution)
```

### Validation Gates

All changes must pass the following gates:
- ✅ **Identity (Carter)**: GPG signing, manifest completeness
- ✅ **Verification (Bauer)**: Audit logging, draft detection
- ✅ **Hardening (Beale)**: Secret scanning, firewall validation
- ✅ **Adversarial (Whitaker)**: Penetration testing, bypass detection
- ✅ **Recovery (Lazarus)**: RTO validation, rollback testing

### Maturity Level 5 Compliance

Current ML5 Score: **{{ ML5_SCORE }}/10**

See `.audit/maturity-level-5-scorecard.yml` for detailed metrics.

---

**Canonical Reference**: [Tiered Satellite Hierarchy](docs/architecture/tiered-satellite-hierarchy-canonical.md)
