# VLAN Discipline — RylanLabs Canon

> Canonical standard — Network segmentation and security
> Date: 2026-01-13
> Agent: Beale
> Author: rylanlab canonical
> Version: v1.0.0

**Status**: ✅ **PRODUCTION** — Beale Ministry Canonical | Strict Isolation | 5-Zone Scheme

---

## Purpose

VLAN Discipline defines the mandatory network segmentation strategy for all RylanLabs environments. It enforces the **Beale ministry** — security hardening and breach detection.

**Objectives**:
- Minimum attack surface through strict segmentation
- Logical separation of duties (Management vs. Production)
- Device isolation for untrusted/IoT devices
- Predictable addressing for automation

---

## Canonical 5-VLAN Scheme

| VLAN ID | Name          | Network           | mask | Posture         | Description                                  |
|---------|---------------|-------------------|------|-----------------|----------------------------------------------|
| 1       | Management    | 192.168.1.0       | /24  | Trusted         | Controller, Switches, APs, Admin access      |
| 10      | Servers       | 10.0.10.0         | /26  | Restricted      | Virtualization, DNS, Local services          |
| 30      | Trusted       | 10.0.30.0         | /24  | User            | Personal devices, Laptops, Workstations      |
| 40      | VoIP          | 10.0.40.0         | /27  | QoS Optimized   | IP Phones, Voice systems                     |
| 90      | Guest-IoT     | 10.0.90.0         | /25  | Strict Isolated | Untrusted IoT, Guests (No internal access)   |

---

## Security Posture (Non-Negotiable)

### 1. Deny-All Default
The default firewall state for all inter-VLAN traffic is **DENY**. Traffic must be explicitly permitted via the `manage-firewall-rules.yml` process.

### 2. L3 Isolation
`l3_isolation=true` must be enforced for Guest-IoT (VLAN 90). No routing to other internal VLANs is permitted at the hardware level.

### 3. Device Isolation
- **Enabled**: VLAN 90 (Guest-IoT)
- **Disabled**: All other VLANs (unless specific L2 isolation is required for security)

### 4. Management Access
Only VLAN 1 (Management) and specific authorized machines in VLAN 30 (Trusted) are permitted to access equipment management interfaces (SSH, WebUI).

---

## Implementation Patterns

### Firewall Rule Ordering
1. **Allow Established/Related** (Stateful)
2. **Allow Specific Internal** (e.g., DNS/NTP)
3. **Deny All Internal** (Inter-VLAN block)
4. **Allow Outbound Internet**

### VLAN Tagging
- Trunk ports: All VLANs permitted (native=1)
- Access ports: Single VLAN untagged
- Wireless: Specific SSIDs mapped to VLANs 30 and 90
