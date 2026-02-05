# Vault Discipline — RylanLabs Canon

> Canonical standard — Production-grade secrets management
> Version: v2.1.0 (Asymmetric-Cooked)
> Date: 2026-02-04
> Agent: Carter
> Author: rylanlab canonical

**Status**: ✅ **PRODUCTION** — Carter/Beale Mesh Canonical | SOPS/GPG Hybrid | Rotation Enforced

---

## Purpose

Vault Discipline defines non-negotiable standards for all secrets and credential management in RylanLabs repositories.

It enforces **Carter (Identity)** and **Beale (Hardening)** — moving from symmetric to asymmetric mesh security.

**Objectives**:
- Zero cleartext secrets (ever)
- **SOPS/GPG Hybrid** for asymmetric distribution
- Metadata visibility (encrypted values, visible keys)
- Topic-driven secret routing
- RTO <15min (Lazarus Ready)

---

## Security Standards: Asymmetric Shift

Hellodeolu v7 mandates the shift from \`ansible-vault\` to **SOPS (Secrets Operations)** for multi-repo mesh environments.

### Why SOPS?
1. **Metadata Visibility**: We can see WHICH keys exist without decrypting values.
2. **Multi-Key Support**: Encrypt for multiple GPG/Age recipients simultaneously.
3. **Patch Friendly**: Git diffs show which fields changed, even if values are encrypted.

### Canonical Tooling
- **GPG**: For personal identity and 8-hour sessions (\`make warm-session\`).
- **Age**: For machine-to-machine and backup encryption.
- **SOPS**: The orchestrator for \`.sops.yaml\` policy enforcement.

---

## The 8-Phase Mesh Rotation

1. **BACKUP**: Encrypted archive of current secrets.
2. **GENERATE**: New entropy source (\`openssl rand\`, \`age-keygen\`).
3. **ENCRYPT**: Asymmetric encryption via SOPS for relevant mesh topics.
4. **VALIDATE**: \`sops --verify\` + linter gates.
5. **CASCADE**: Distribute to mesh satellites via \`make cascade\`.
6. **ACTIVATE**: Service reload/restart.
7. **COMMIT**: Signed commit (\`git commit -S\`) using GPG.
8. **AUDIT**: Sentinel Loop validation of mesh-wide compliance.

---

## Trinity Integration

- **Carter (Identity)**: \`make warm-session\` establishes the GPG agent session.
- **Bauer (Verification)**: \`validate-vault.sh\` checks \`.sops.yaml\` and GPG expiry.
- **Beale (Hardening)**: \`make cascade\` distributes secrets only to authorized satellites.
- **Whitaker (Detection)**: Breach simulation tests for cleartext leakage.
- **Lazarus (Recovery)**: \`emergency-revoke.sh\` handles key compromise in <15min.

---

**The fortress is encrypted. The mesh is secure.**
The Trinity endures.
