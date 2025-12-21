# Vault Discipline — RylanLabs Canon

> Canonical standard — Production-grade secrets management  
> Date: December 21, 2025  
> Agent: Carter  
> Author: rylanlab canonical

**Status**: ✅ **PRODUCTION** — Carter Ministry Canonical | Zero Cleartext | Rotation Enforced

---

## Purpose

Vault Discipline defines non-negotiable standards for all secrets and credential management in RylanLabs repositories.

It enforces **Carter ministry** — identity hygiene and zero cleartext leakage.

**Objectives**:

- Zero cleartext secrets in repositories
- Encrypted storage at rest
- Audited access and rotation
- Junior-at-3-AM usability
- Integration with Ansible orchestration

---

## Repository: rylanlabs-private-vault

**Visibility**: PRIVATE  
**Access**: RylanLabs team only

**Structure** (Mandatory):

```
rylanlabs-private-vault/
├── README.md
├── .gitignore
├── keys/
│   ├── ssh/
│   │   ├── personal-id_ed25519
│   │   ├── personal-id_ed25519.pub
│   │   └── README.md
│   └── github/
│       ├── deploy-key-private
│       ├── deploy-key-public
│       └── README.md
└── vault-passwords/
    └── ansible-vault-pass
```

---

## Security Standards (Non-Negotiable)

1. **Never Commit Cleartext**
   - No passwords, tokens, private keys in plain text
   - Violation blocked by .gitignore and pre-commit

2. **Permissions**
   - Private keys: `chmod 600`
   - Public keys: `chmod 644`
   - Vault password files: `chmod 600`

3. **Encryption**
   - Vault password files for ansible-vault
   - Future: git-crypt or sops for broader coverage

4. **Rotation**
   - Annual mandatory
   - Immediate on suspected compromise
   - Documented in commit message

5. **Access Control**
   - Private repository
   - Team members only
   - Audit via git history

---

## Key Management

### Personal SSH Keys (keys/ssh/)

- One key per operator
- ED25519 preferred
- Passphrase protected
- Used for daily GitHub + server access

### GitHub Deploy Keys (keys/github/)

- One per purpose/repo
- Read-only unless write required
- No passphrase (automation)

### Ansible Vault Password (vault-passwords/)

- Strong random password (openssl rand -base64 32)
- Used for playbook encryption
- Referenced via --vault-password-file

---

## Usage in Playbooks

```yaml
- hosts: all
  vars_files:
    - "{{ lookup('env', 'HOME') }}/repos/rylanlabs-private-vault/vault-passwords/ansible-vault-pass"
  vars:
    ansible_ssh_private_key_file: "{{ lookup('env', 'HOME') }}/repos/rylanlabs-private-vault/keys/ssh/personal-id_ed25519"
```

### Environment Variables (Mandatory)

```bash
export VAULT_PASSWORD_FILE="$HOME/repos/rylanlabs-private-vault/vault-passwords/ansible-vault-pass"
export ANSIBLE_PRIVATE_KEY_FILE="$HOME/repos/rylanlabs-private-vault/keys/ssh/personal-id_ed25519"
```

---

## Trinity Integration

**Carter → Bauer → Beale** (Execution Order)

1. **Carter** (bootstrap | identity hygiene)
   - Validates vault structure, permissions, cleartext coverage
   - Executes: `scripts/validate-vault.sh`
   - Exit codes: 0 (pass) | 1 (perms fail) | 2 (gitignore fail) | 3 (rotation fail)

2. **Bauer** (verification | audit)
   - Audits key usage in playbooks and git history
   - Verifies rotation cadence (annual + emergency)
   - Detects unrotated keys, cleartext leakage

3. **Beale** (hardening | detection)
   - Tests SSH hardening with vault keys (`beale-harden.sh --ssh`)
   - Monitors key usage patterns via audit logs
   - Detects unauthorized access attempts

**Workflow Example**:

```bash
# 1. Bootstrap vault (Carter)
./scripts/validate-vault.sh
# Output: PASS | All keys 600/644, .gitignore enforced, last rotation: 2025-12-21

# 2. Verify integration (Bauer)
ansible --syntax-check site.yml
ssh -T git@github.com  # Test deploy key

# 3. Harden SSH (Beale)
./beale-harden.sh --ssh-key-file "$ANSIBLE_PRIVATE_KEY_FILE"
```

---

## Rotation Procedure

```bash
# 1. Generate new key
ssh-keygen -t ed25519 -C "rotation-2025-12-21" -f ~/.ssh/id_ed25519_new

# 2. Add to GitHub + servers
# 3. Test new key
ssh -i ~/.ssh/id_ed25519_new git@github.com

# 4. Update vault
mv ~/.ssh/id_ed25519_new ~/repos/rylanlabs-private-vault/keys/ssh/personal-id_ed25519
git add keys/ssh/
git commit -m "chore(vault): rotate personal SSH key (annual)
Agent: Carter
Ministry: bootstrap
Reason: Annual rotation policy"

# 5. Remove old key from systems
```

---

## Emergency Procedures

### Compromised Key (RTO: <30 minutes)

| T+Min | Action | Owner | Validation |
|-------|--------|-------|------------|
| 0 | **LOCK**: Revoke key on GitHub + servers | Operator | GitHub revoke confirmed, SSH access denied |
| 5 | Generate new ED25519 key (`ssh-keygen -t ed25519`) | Carter | Passphrase confirmed, pubkey exported |
| 15 | Deploy to critical systems via Ansible | Bauer | `ansible -i inventory site.yml --limit critical` |
| 20 | Validate access (`validate-vault.sh`) | Carter | Exit code 0, new key in use |
| 25 | Commit emergency rotation | Carter | Commit message includes breach context |
| 30 | File incident report | Security | `docs/incidents/YYYY-MM-DD-key-compromise.md` |

**Commit Message Format**:
```
security(vault): emergency rotation - personal SSH key compromised

Affected: personal-id_ed25519
Reason: Suspected compromise (incident #XYZ)
NewKey: <fingerprint>
Rotated: 2025-12-21T14:30:00Z
Revoked: GitHub + <servers>

Ministry: Carter (bootstrap)
Agent: <Operator Name>
```

### Lost Access (RTO: <15 minutes)

1. Generate recovery key (stored securely offline)
2. Add to GitHub + critical systems
3. Update vault path: `keys/ssh/recovery-id_ed25519`
4. Document recovery rotation in git log

### Breach Simulation (Whitaker Ministry)

**Test**: Can attacker extract secrets from repo?

```bash
# Simulate vault breach detection
./scripts/simulate-vault-breach.sh --target rylanlabs-private-vault

# Expected output:
# ✓ .gitignore blocks vault-passwords/
# ✓ All private keys 600 (unreadable to attacker)
# ✓ No cleartext secrets in git history
# ✓ Rotation audit trail intact
```

**Incident Report Structure**:

```markdown
# Incident: Key Compromise — 2025-12-21

## Timeline
- T+0m: Compromise detected
- T+5m: Key revoked
- T+20m: New key deployed
- T+30m: All systems validated

## Root Cause
...

## Remediation
...

## Prevention
...
```

---

## Validation Checklist (Executable)

**Reference**: `scripts/validate-vault.sh` (Carter ministry executable)

### Manual Verification

- [ ] Private files 600 permissions (`ls -la keys/ssh/personal-id_ed25519`)
- [ ] No cleartext secrets (`git log --all -p -- vault-passwords/ | head -1`)
- [ ] README.md documents all keys and rotation history
- [ ] .gitignore blocks `vault-passwords/`, `keys/ssh/*-private`
- [ ] Git log shows annual rotation + emergency rotations with incident context
- [ ] Test access works (`ssh -T git@github.com`)
- [ ] Key fingerprints match GitHub SSH keys
- [ ] No keys in git history (pre-commit hook enforced)

### Automated Validation

```bash
# Run Carter validator
./scripts/validate-vault.sh

# Exit codes:
# 0 = PASS (all checks)
# 1 = FAIL (permissions)
# 2 = FAIL (.gitignore coverage)
# 3 = FAIL (rotation cadence)
# 4 = FAIL (git history cleartext)
```

**Coverage**: Permissions, .gitignore, rotation history, cleartext detection, key expiry

---

**The fortress demands discipline. No shortcuts. No exceptions.**

Carter ministry — identity secured.

The Trinity begins with Carter.

The Trinity endures.