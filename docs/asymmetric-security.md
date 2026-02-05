# Asymmetric Security: SOPS & GPG Hybrid

> Canonical standard — Secrets Management v7
> Version: v1.0.0
> Date: 2026-02-04

---

## Overview

Asymmetric security moves away from shared passwords (symmetric) to public/private key pairs. This ensures only specific authorized entities can decrypt specific secrets, while allowing everyone to verify the source (signing).

---

## The Stack

1. **GPG (GNU Privacy Guard)**: Used for personal identities, code signing, and SOPS recipient management.
2. **Age**: Modern alternative to GPG, used for machine identities and cross-team encryption.
3. **SOPS (Secrets Operations)**: The editor/engine that handles the heavy lifting of encrypting/decrypting files using the keys above.

---

## 8-Hour Warmed sessions

To balance security and developer velocity, RylanLabs uses **Warmed GPG Sessions**:

```bash
# make warm-session
gpg-connect-agent PRESET_PASSPHRASE <key_fingerprint> -1
```
Successful warming allows **8 hours of password-less execution** for:
- Signing commits (`git commit -S`)
- Decrypting SOPS files
- Running mesh cascades

---

## Configuration (`.sops.yaml`)

Every repository must define its encryption policy in the root:

```yaml
creation_rules:
  - path_regex: .*\.vault\.yaml$
    pgp: "F5FFF5CB35A8B1F38304FC28AC4A4D261FD62D75"
    unencrypted_suffix: "_unencrypted"
```

---

## Revocation (Lazarus Phase)

In the event of a key compromise:
1. **Revoke**: Distribute a GPG revocation certificate.
2. **Re-key**: Run `sops rotate` on all files in the mesh to replace the compromised recipient with a new one.
3. **Audit**: Verify zero files remain encrypted with the old key.

---

**Asymmetric is the standard. Drift is the enemy.**
The Trinity endures.
