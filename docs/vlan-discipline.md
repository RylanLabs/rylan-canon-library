# VLAN Discipline — RylanLabs Canon

> Canonical standard — Network segmentation and security
> Version: v2.1.0 (6-Zone Scheme)
> Date: 2026-02-04
> Agent: Beale
> Author: rylanlab canonical

**Status**: ✅ **PRODUCTION** — Beale Ministry Canonical | Strict Isolation | 6-Zone Scheme

---

## Purpose

VLAN Discipline defines the mandatory network segmentation strategy for all RylanLabs environments. It enforces the **Beale (Hardening)** — security hardening and breach detection.

**Objectives**:
- Minimum attack surface through strict segmentation
- Logical separation of duties (Management vs. Production)
- Device isolation for untrusted/IoT devices
- Predictable addressing for automation (Maturity Level 5)

---

## Canonical 6-VLAN Scheme (v7 Alignment)

| VLAN ID | Name          | Network           | mask | Posture         | Description                                  |
|---------|---------------|-------------------|------|-----------------|----------------------------------------------|
| 1       | Management    | 192.168.1.0       | /24  | Trusted         | Controller, Switches, APs, Admin access      |
| 10      | Servers       | 10.0.10.0         | /24  | Restricted      | Virtualization, Local services (SSOT)        |
| 30      | Trusted       | 10.0.30.0         | /24  | User            | Personal devices, Workstations               |
| 40      | VoIP          | 10.0.40.0         | /27  | QoS Optimized   | IP Phones, Voice systems                     |
| 80      | Shadow-VLAN   | 10.0.80.0         | /24  | Zero-Trust      | Experimental / Honeypot (Whitaker Testing)   |
| 90      | Guest-IoT     | 10.0.90.0         | /24  | Strict Isolated | Untrusted IoT, Guests (No internal access)   |

---

## Implementation Standards

- **Trunk Ports**: All VLANS (Native=1)
- **Access Ports**: Single VLAN (Untagged)
- **SSID Mapping**:
  - \`rylanlabs-secure\` -> VLAN 30
  - \`rylanlabs-guest\` -> VLAN 90
  - \`rylanlabs-voip\` -> VLAN 40

---

**The fortress is segmented. The mesh is isolated.**
The Trinity endures.
