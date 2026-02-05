# RylanLabs Mesh Troubleshooting Guide

Maturity: Level 5 (Autonomous)  
Agent: Whitaker (Detection) / Bauer (Audit)

This document provides runbooks for common failures in the Meta-GitOps mesh.

## 1. Compliance Drift (RED Repositories)

**Symptoms**: `sentinel-loop` workflow fails; `org-audit.sh` outputs "RED" status.

**Root Causes**:

- `common.mk` manually edited in a satellite repo.
- `.gitleaks.toml` removed.
- Unsigned commits pushed to `main`.

**Runbook**:

1. Check `.audit/compliance-matrix.json` for specific failure details.
2. If Lazarus failed to remediate, manually run `make cascade` from the Canon Library or
   follow the remediation PR links in the audit.
3. Validate fixes with `make validate` in the satellite repo.

## 2. Gitleaks Failures

**Symptoms**: Commit blocked locally; `compliance-gate` fails in CI.

**Runbook**:

1. **NEVER use `--no-verify`**.
2. Run `gitleaks detect --source . -v` to identify the leaked secret.
3. If it's a false positive, add the fingerprint to `.gitleaksignore`.
4. If it's a real secret, follow [Lazarus Recovery Pattern](emergency-procedures.md) to revoke and rotate immediately.

## 3. SOPS Encryption Errors

**Symptoms**: "ERROR: SOPS encryption check failed."

**Runbook**:

1. Ensure GPG keys are warmed: `make warm-session`.
2. Check `.sops.yaml` regex patterns.
3. Verify the file contains the `sops:` or `ENC[AES256_GCM]` markers.

## 4. Substrate Desync

**Symptoms**: `Makefile` targets missing or behaving inconsistently.

**Runbook**:

1. Verify `-include .rylan/common.mk` exists in the satellite `Makefile`.
2. Run `make cascade` to pull latest Tier 0 substrate.
