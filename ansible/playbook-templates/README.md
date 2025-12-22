# UniFi Automation Playbook Templates

> Production-ready Ansible playbooks for UniFi controller automation  
> Organization: RylanLabs  
> Version: 4.5.2-playbooks  
> Guardian: Trinity (Carter, Bauer, Beale)  

---

## 📋 Overview

This directory contains **4 canonical playbook templates** for UniFi network controller automation. All templates follow the **Seven Pillars** of production-grade code and are designed for **junior-at-3-AM** deployability.

**Templates Included**:
1. [backup-controller.yml](#backup-controlleryml) — Network controller backup with retention
2. [manage-vlans.yml](#manage-vlansyml) — VLAN creation and management
3. [manage-firewall-rules.yml](#manage-firewall-rulesyml) — Firewall rule automation
4. [rollback-firewall.yml](#rollback-firewallyml) — Disaster recovery and rollback

---

## 📦 Template Specifications

### backup-controller.yml

**Purpose**: Automated backup of UniFi controller with retention policy

**Guardian**: Beale (Hardening)

**Use Case**:
- Daily controller backups
- Compliance: Long-term retention (configurable)
- Disaster recovery preparation
- Data protection across network changes

**Compliance**:
- ✅ **Idempotency**: Safe to run multiple times (backup deduplication via timestamp)
- ✅ **Error Handling**: Fail fast on API errors, validate backup integrity
- ✅ **Audit Logging**: All actions logged to `.audit/phase-3-playbooks/`
- ✅ **Reversibility**: Backups versioned, restore path documented
- ✅ **Observability**: Backup metadata stored (SHA256, size, retention date)

**Variables**:

| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `backup_retention_days` | int | 30 | Retention policy (days) |
| `backup_dir` | path | `/var/backups/unifi` | Local backup storage |
| `unifi_user` | string | — | Controller username |
| `unifi_password` | string | — | Controller password (use vault) |

**Example**:

```bash
ansible-playbook ansible/playbook-templates/backup-controller.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars "backup_retention_days=30 unifi_user=admin unifi_password='$UNIFI_PASSWORD'"
```

**Output**:
- Backup file: `/var/backups/unifi/unifi-backup-20251222T150000.tar.gz`
- Metadata: `unifi-backup-20251222T150000.tar.gz.metadata`
- Audit log: `.audit/phase-3-playbooks/backup-controller-20251222T150000.log`
- Retention: Old backups auto-deleted after `backup_retention_days`

---

### manage-vlans.yml

**Purpose**: Create and manage UniFi VLANs with validation constraints

**Guardian**: Bauer (Verification)

**Use Case**:
- New network segment setup
- VLAN isolation and security
- Multi-tenant network isolation
- Guest network provisioning

**Compliance**:
- ✅ **Validation**: Max 5 VLANs per run (safety limit)
- ✅ **Idempotency**: Rerun safely if one VLAN fails
- ✅ **Conflict Detection**: Pre-check for VLAN ID conflicts
- ✅ **Audit Logging**: All VLAN operations logged
- ✅ **Reversibility**: All VLANs marked `managed=true` for safe deletion

**Variables**:

| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `vlans` | list | [] | List of VLAN definitions |
| `max_vlans_per_run` | int | 5 | Safety constraint |

**VLAN Definition Structure**:

```yaml
vlans:
  - id: 100              # VLAN ID (must be unique)
    name: "Guest"        # Human-readable name
    subnet: "10.20.0.0/24"  # Network CIDR

  - id: 200
    name: "IoT"
    subnet: "10.30.0.0/24"
```

**Example**:

```bash
ansible-playbook ansible/playbook-templates/manage-vlans.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars 'vlans=[{id: 100, name: "Guest", subnet: "10.20.0.0/24"}, {id: 200, name: "IoT", subnet: "10.30.0.0/24"}]'
```

**Validation**:
- ✅ Controller accessibility
- ✅ VLAN count (1-5 per run)
- ✅ VLAN ID uniqueness
- ✅ Subnet format (CIDR)
- ✅ DHCP pool calculation

**Output**:
- Audit log: `.audit/phase-3-playbooks/vlan-management-20251222T150000.log`
- Completion log: `.audit/phase-3-playbooks/vlan-completion-20251222T150000.log`
- Status: All VLANs verified in controller

---

### manage-firewall-rules.yml

**Purpose**: Create and manage UniFi firewall rules with safety constraints

**Guardian**: Carter (Identity — source/dest verification)

**Use Case**:
- Network access control
- Threat mitigation
- Compliance enforcement
- Zero-trust segmentation

**Compliance**:
- ✅ **Validation**: Max 10 rules per run (DoS prevention)
- ✅ **Deduplication**: Idempotent rule creation via src/dst/port hash
- ✅ **Conflict Detection**: Pre-check rule overlaps
- ✅ **Audit Logging**: All rules logged with logging=true
- ✅ **Reversibility**: All rules tagged `managed=true` for safe deletion

**Variables**:

| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `rules` | list | [] | List of firewall rule definitions |
| `max_rules_per_run` | int | 10 | Safety constraint |

**Firewall Rule Definition**:

```yaml
rules:
  - action: "accept"          # accept, drop, reject
    src_subnet: "10.0.0.0/8"   # Source subnet (CIDR)
    dst_port: "443"             # Destination port
    protocol: "tcp"             # Protocol (default: tcp)

  - action: "drop"
    src_subnet: "192.168.1.0/24"
    dst_port: "22"
```

**Example**:

```bash
ansible-playbook ansible/playbook-templates/manage-firewall-rules.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars 'rules=[{action: "accept", src_subnet: "10.0.0.0/8", dst_port: "443"}]'
```

**Validation**:
- ✅ Controller accessibility
- ✅ Rule count (1-10 per run)
- ✅ Rule structure (action, src_subnet required)
- ✅ Duplicate detection (input)
- ✅ Port/protocol validation

**Output**:
- Audit log: `.audit/phase-3-playbooks/firewall-rules-20251222T150000.log`
- Completion log: `.audit/phase-3-playbooks/firewall-completion-20251222T150000.log`
- Status: All rules verified + logging enabled

---

### rollback-firewall.yml

**Purpose**: Disaster recovery — rollback firewall rules to last known good state

**Guardian**: Beale (Hardening — emergency procedures)

**Use Case**:
- Incident response
- Accidental rule deletion recovery
- Configuration regression
- RTO <5min restoration

**Compliance**:
- ✅ **Reversibility**: Complete audit trail of all deletions
- ✅ **Error Handling**: Validates rollback before applying
- ✅ **Observability**: Pre/post-rollback snapshots
- ✅ **Idempotency**: Multiple rollback runs produce identical state
- ✅ **Audit Logging**: All actions timestamped and logged

**Variables**:

| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `rollback_to` | string | `"latest"` | `latest` or specific timestamp |
| `dry_run` | bool | false | Preview changes without applying |
| `backup_dir` | path | `/var/backups/unifi-firewall` | Backup storage |

**Example (Rollback to Latest)**:

```bash
ansible-playbook ansible/playbook-templates/rollback-firewall.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars "rollback_to=latest"
```

**Example (Dry Run Preview)**:

```bash
ansible-playbook ansible/playbook-templates/rollback-firewall.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars "rollback_to=latest dry_run=true"
```

**Example (Specific Backup)**:

```bash
ansible-playbook ansible/playbook-templates/rollback-firewall.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars "rollback_to=20251222T150000"
```

**Workflow**:
1. ✅ **Plan Phase**: Determine rollback source, analyze diffs
2. ✅ **Preview**: Display changes needed (dry run)
3. ✅ **Confirm**: Human authorization (safety gate)
4. ✅ **Execute**: Delete old rules, create target rules
5. ✅ **Verify**: Validate final state matches target
6. ✅ **Archive**: Store pre/post-rollback snapshots

**Output**:
- Rollback log: `.audit/phase-3-playbooks/rollback-firewall-20251222T150000.log`
- Pre-rollback snapshot: `/var/backups/unifi-firewall/pre-rollback-rules-20251222T150000.json`
- Post-rollback snapshot: `/var/backups/unifi-firewall/post-rollback-rules-20251222T150000.json`
- Completion log: `.audit/phase-3-playbooks/rollback-completion-20251222T150000.log`

---

## 🔒 Security & Compliance

### Credential Management

**NEVER** hardcode credentials. Use Ansible Vault:

```bash
# Create vault-encrypted variables file
ansible-vault create inventory/unifi-secrets.yml

# Encrypt plaintext variables
ansible-vault encrypt inventory/unifi-secrets.yml

# Run playbook with vault
ansible-playbook ansible/playbook-templates/backup-controller.yml \
  --vault-password-file ~/.vault_pass
```

**Vault File Template**:

```yaml
---
unifi_user: admin
unifi_password: "{{ vault_password }}"
```

### Certificate Validation

All templates disable certificate validation (`validate_certs: false`) for lab/dev environments. **For production**:

```yaml
# In playbooks, change:
validate_certs: false  # ← DEV ONLY

# To production:
validate_certs: true   # ← PRODUCTION
ca_path: /etc/ssl/certs/ca-certificates.crt
```

---

## 📊 Usage Patterns

### Pattern 1: Daily Backup Schedule

```yaml
# In cron or AWX schedule:
0 2 * * * ansible-playbook backup-controller.yml \
  -i inventory/unifi-hosts.yml \
  --vault-password-file ~/.vault_pass
```

### Pattern 2: New Network Deployment

```bash
# Step 1: Create VLANS
ansible-playbook manage-vlans.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars 'vlans=[{id: 100, name: "Production", subnet: "10.100.0.0/24"}]'

# Step 2: Add firewall rules
ansible-playbook manage-firewall-rules.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars 'rules=[{action: "accept", src_subnet: "10.100.0.0/24", dst_port: "443"}]'
```

### Pattern 3: Disaster Recovery

```bash
# Immediate: Backup current state
ansible-playbook backup-controller.yml \
  -i inventory/unifi-hosts.yml

# Step 2: Rollback firewall to known good
ansible-playbook rollback-firewall.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars "rollback_to=latest"

# Step 3: Verify recovery
ansible-playbook manage-firewall-rules.yml \
  -i inventory/unifi-hosts.yml \
  --syntax-check
```

---

## 🧪 Testing & Validation

### Syntax Check (No Changes)

```bash
ansible-playbook backup-controller.yml --syntax-check
ansible-playbook manage-vlans.yml --syntax-check
ansible-playbook manage-firewall-rules.yml --syntax-check
ansible-playbook rollback-firewall.yml --syntax-check
```

### Dry Run (Plan Only)

```bash
# VLAN dry run
ansible-playbook manage-vlans.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars 'vlans=[{id: 100, name: "Test", subnet: "10.20.0.0/24"}]' \
  -C

# Firewall dry run
ansible-playbook manage-firewall-rules.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars 'rules=[{action: "accept", src_subnet: "10.0.0.0/8", dst_port: "443"}]' \
  -C

# Rollback dry run
ansible-playbook rollback-firewall.yml \
  -i inventory/unifi-hosts.yml \
  --extra-vars "rollback_to=latest dry_run=true"
```

### Full Validation

```bash
# Run all syntax checks
for playbook in ansible/playbook-templates/*.yml; do
  echo "Checking $playbook..."
  ansible-playbook "$playbook" --syntax-check
done

# Lint with ansible-lint
ansible-lint ansible/playbook-templates/
```

---

## 📚 Audit Trail & Observability

All playbooks populate `.audit/phase-3-playbooks/` with timestamped logs:

```
.audit/phase-3-playbooks/
├── backup-controller-20251222T150000.log
├── vlan-management-20251222T150000.log
├── firewall-rules-20251222T150000.log
├── rollback-firewall-20251222T150000.log
└── ...
```

**Log Format**:

```
[2025-12-22T15:00:00Z] Operation completed successfully
  Controller: 192.168.1.1
  Action: backup-controller
  Status: VERIFIED
  SHA256: abc123def456...
```

---

## 🚀 Junior-at-3-AM Deployment Checklist

Before running in production:

- [ ] All secrets in Ansible Vault (never plaintext)
- [ ] Certificate validation enabled (production)
- [ ] Inventory file correct (right controller)
- [ ] Syntax check passed (`--syntax-check`)
- [ ] Dry run executed (`-C` flag)
- [ ] Backup exists (for rollback support)
- [ ] On-call team notified
- [ ] Rollback procedure reviewed
- [ ] Audit logs captured (`.audit/` directory)
- [ ] Post-execution verification completed

---

## 📖 References

- **Ansible Docs**: https://docs.ansible.com/
- **UniFi API**: https://ubntwifi.github.io/
- **ansible-lint**: https://docs.ansible.com/projects/lint/
- **RylanLabs Seven Pillars**: [docs/seven-pillars.md](../docs/seven-pillars.md)
- **Hellodeolu v6**: [docs/hellodeolu-v6.md](../docs/hellodeolu-v6.md)

---

**The fortress demands discipline. No shortcuts. No exceptions.**

**The Trinity endures.**
