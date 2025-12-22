# Inventory Discipline — RylanLabs Canon

> Canonical standard — Production-grade device manifest management
> Date: December 21, 2025
> Agent: Carter
> Author: rylanlab canonical

**Status**: ✅ **PRODUCTION** — Carter Ministry Canonical | Single Source of Truth | Audit-Enforced

---

## Purpose

Inventory Discipline defines non-negotiable standards for the **device manifest** — the single source of truth for what exists in the RylanLabs fortress.

It enforces **Carter ministry** — establishing identity of all managed infrastructure before any action.

**Objectives**:
- Single source of truth (no drift)
- Audit trail of all device changes
- Hardware constraint awareness
- Junior-at-3-AM clarity
- Integration with orchestration

---

## Repository: rylan-inventory

**Visibility**: PRIVATE
**Access**: RylanLabs team only

**Structure** (Mandatory):

```
rylan-inventory/
├── README.md
├── .gitignore
├── inventory/
│   ├── device-manifest.yml     # Sacred — CANONICAL
│   ├── group_vars/
│   │   └── all.yml
│   └── host_vars/
│       └── .gitkeep
└── .github/
    └── workflows/ (future CI)
```

---

## device-manifest.yml — Canonical Format

```yaml
---
# device-manifest.yml
# Purpose: Single source of truth — Complete device catalogue
# Agent: Carter
# Ministry: bootstrap
# Maturity Level: 9.9
# Sacred: Never modify via GUI. Always via playbook. Always committed to git.
# OPSEC: Generic hostnames (conceal vendor/model). Hardware field private-repo-only.
devices:
  ctrl-01:
    hostname: "ctrl-01"
    ip: "192.168.1.1"
    role: "controller"
    hardware: "UniFi Cloud Key Gen2"
    vlans_supported: [1, 10, 20, 30]
    vlans_active: [1]
    backup_enabled: true
    comments: "Primary network controller"
  gw-01:
    hostname: "gw-01"
    ip: "192.168.1.254"
    role: "gateway"
    hardware: "UniFi Security Gateway 3P"
  sw-poe-01:
    hostname: "sw-poe-01"
    ip: "192.168.1.2"
    role: "switch_poe"
    hardware: "UniFi Switch 8 60W"
    ports: 8
    poe_enabled: true
  sw-flex-01:
    hostname: "sw-flex-01"
    ip: "192.168.1.3"
    role: "switch"
    hardware: "UniFi Switch Flex 2.5G 5"
    ports: 5
  ap-01:
    hostname: "ap-01"
    ip: "192.168.1.20"
    role: "access-point"
    hardware: "UniFi AC Lite"
  ap-02:
    hostname: "ap-02"
    ip: "192.168.1.21"
    role: "access-point"
    hardware: "UniFi AC Lite"
constraints:
  max_vlans: 4
  max_firewall_rules: 10
  vlan_99_supported: false
  cpu_limited: true
  ram_limited: true
metadata:
  last_updated: "2025-12-21"
  updated_by: "Carter bootstrap"
  version: "1.0.0"
  audit_trail: "git log device-manifest.yml"
```

### Naming Convention (OPSEC Hardened)

**Generic Format**: `<role>-<sequence>`

| Role | Prefix | Example | Hardware (Private) |
|------|--------|---------|--------------------|
| Controller | `ctrl-` | `ctrl-01` | UniFi Cloud Key Gen2 |
| Gateway | `gw-` | `gw-01` | UniFi Security Gateway 3P |
| Switch (PoE) | `sw-poe-` | `sw-poe-01` | UniFi Switch 8 60W |
| Switch (Flex) | `sw-flex-` | `sw-flex-01` | UniFi Switch Flex 2.5G |
| Access Point | `ap-` | `ap-01` | UniFi AC Lite |

**Why Generic Names Matter (OPSEC)**:

❌ **Exposed** (Vendor-Specific):
```
rylan-uck-g2       → Brand (UniFi) + Model (Cloud Key Gen2) + Owner (Rylan)
usg-3p             → Exact model (CVE-2024-XXXX for USG 3P)
us-8-60w           → Exact switch model
ap-lite-1/2        → Network scale (2 APs), topology hints
```

✅ **Hardened** (Generic):
```
ctrl-01            → Function only (controller)
gw-01              → Function only (gateway)
sw-poe-01          → Function + capability (PoE)
ap-01, ap-02       → Scale visible, vendor hidden
```

**Attack Vector Prevented**:
1. Attacker finds leaked inventory (GitHub misconfiguration, compromised laptop)
2. Generic names → Can't search Shodan for `rylan-uck-g2`
3. Can't enumerate exact exploits for `UniFi Cloud Key Gen2 CVE-2024-XXXX`
4. Network topology obfuscated (function-based, not topology-based)

**Hardware Field Policy**:
- ✅ **Keep in private repo** (`rylan-inventory/` — PRIVATE) for operational awareness
- ❌ **Redact in public canon docs** (`rylan-patterns-library/docs/`) for OPSEC
- Example: Public docs show `ap-01` with role "access-point", hardware field omitted

---

---

## Update Standards (Non-Negotiable)

1. **Never Modify via GUI**
   - All changes via playbook
   - Commit to git
   - Audit trail preserved

2. **Commit Message Format**
   ```text
   feat(inventory): add device ap-lite-3
   Agent: Carter
   Ministry: bootstrap
   Device: ap-lite-3
   IP: 192.168.1.22
   Role: access-point
   Rationale: Additional coverage for office
   ```

3. **Validation Before Commit**
   - YAML syntax valid
   - All required fields present
   - Hardware constraints respected

---

## Trinity Integration

**Carter → Bauer → Beale → Whitaker** (Execution Order)

### Carter (Bootstrap | Identity)
- Validates inventory schema (`scripts/validate-inventory.sh`)
- Enforces generic naming conventions (no vendor exposure)
- Blocks commits with missing required fields
- **Exit codes**: 0 (pass) | 1 (YAML) | 2 (required fields) | 3 (IP duplicate) | 4 (constraint violation)

### Bauer (Auditor | Verification)
- Detects inventory drift: manifest vs live network state
- Executes: `playbooks/detect-inventory-drift.yml`
- Compares device-manifest.yml against nmap scan results
- Reports unauthorized devices (not in manifest)
- Audits constraint violations (firewall rules > max_firewall_rules)

### Beale (Bastille | Hardening)
- Validates constraints: firewall rules ≤ 10, VLANs ≤ 4
- Tests device SSH hardening (`beale-harden.sh --device gw-01`)
- Validates VLAN isolation (e.g., VLAN 99 dropped due to hardware limits)
- Enforces access policies per role

### Whitaker (Red Team | Breach Testing)
- Simulates device compromise: lateral movement between devices
- Tests network segmentation (can compromised AP reach controller?)
- Validates credential isolation (no shared SSH keys across roles)
- Executes: `tests/whitaker-network-breach.yml`

**Workflow Example**:

```bash
# 1. Bootstrap inventory (Carter)
./scripts/validate-inventory.sh
# Output: PASS | Schema valid, all devices have required fields, no IP duplicates, constraints OK

# 2. Detect drift (Bauer)
ansible-playbook playbooks/detect-inventory-drift.yml
# Output: Device count: manifest=6, live=6, unauthorized=0

# 3. Harden devices (Beale)
beale-harden.sh --device gw-01 --check-constraints
# Output: Firewall rules: 7/10, VLANs: 1/4, SSH hardened ✓

# 4. Test breach scenarios (Whitaker)
ansible-playbook tests/whitaker-network-breach.yml --extra-vars compromise_target=ap-01
# Output: Lateral movement blocked ✓, Data exfiltration prevented ✓
```

---

**Ansible Configuration**:

```ini
# rylan-homelab-iac/ansible.cfg
[defaults]
inventory = ../rylan-inventory/inventory/device-manifest.yml
```

**Drift Detection Playbook**:

```yaml
# playbooks/detect-inventory-drift.yml
---
- name: Detect Inventory Drift
  hosts: all
  gather_facts: no
  tasks:
    - name: Verify device is in manifest
      assert:
        that:
          - inventory_hostname in groups['all']
        fail_msg: "Device {{ inventory_hostname }} not in inventory manifest!"

    - name: Verify IP matches manifest
      assert:
        that:
          - ansible_host == hostvars[inventory_hostname]['ansible_host']
        fail_msg: "IP mismatch for {{ inventory_hostname }}"

    - name: Report constraint usage
      debug:
        msg: |
          Device: {{ inventory_hostname }}
          Role: {{ device_role }}
          Firewall rules: {{ current_rules | length }}/{{ max_firewall_rules }}
          VLANs active: {{ vlans_active | length }}/{{ max_vlans }}
```

**Playbooks read manifest** — know what exists before acting.

---

## Validation (Executable)

**Reference**: `scripts/validate-inventory.sh` (Carter ministry executable)

### Automated Validation

```bash
# Run Carter validator
./scripts/validate-inventory.sh

# Exit codes:
# 0 = PASS (all checks)
# 1 = FAIL (YAML syntax invalid)
# 2 = FAIL (required fields missing)
# 3 = FAIL (duplicate IPs detected)
# 4 = FAIL (constraint violation: firewall rules or VLANs exceeded)
```

**Checks Performed**:
- YAML syntax validity
- Required fields: `hostname`, `ip`, `role`, `hardware`
- IP address uniqueness (no duplicates)
- Constraint enforcement: `max_vlans`, `max_firewall_rules`, hardware limits
- Field format validation (valid IPs, role enum)

### Manual Verification

- [ ] device-manifest.yml exists and is tracked in git
- [ ] All devices use generic naming (`ctrl-`, `gw-`, `sw-`, `ap-` prefixes)
- [ ] No vendor-specific names exposed (OPSEC hardened)
- [ ] Hardware field present (for operational knowledge in private repo)
- [ ] All required fields present: hostname, ip, role, hardware
- [ ] Constraints documented and enforced
- [ ] No direct modifications allowed (only via playbook + git)
- [ ] Git log shows audit trail of all changes
- [ ] YAML syntax valid (parseable by yamllint)
- [ ] Drift detection runs cleanly (`detect-inventory-drift.yml`)

---

## Redaction Policy (Public vs Private)

**Private Repo** (`rylan-inventory/` — PRIVATE ACCESS):
- ✅ Full device details: hostname, IP, hardware model, constraints
- ✅ Operational awareness for troubleshooting
- ✅ Used by Ansible plays and drift detection

**Public Canon Docs** (`rylan-patterns-library/docs/` — PUBLIC):
- ✅ Generic device names (`ctrl-01`, `gw-01`, `ap-01`)
- ✅ Role descriptions (controller, gateway, access-point)
- ❌ NO hardware specifications in examples
- ❌ NO IP addresses in examples (use `X.X.X.X` placeholder)
- ❌ NO vendor names in canonical examples

**Rationale**: Public documentation teaches *concepts* (inventory discipline, naming conventions, Trinity workflow). Private repos contain *operational reality* (hardware details, actual IPs). Separation enforces OPSEC while maintaining educational clarity.

---

## Validation Checklist

---

**The fortress demands discipline. No shortcuts. No exceptions.**

Carter ministry — device identity established.

Single source of truth enforced.

The Trinity endures.
