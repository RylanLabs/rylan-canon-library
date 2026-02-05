# Ansible Inventory Patterns

> Canonical hybrid static + dynamic inventory patterns  
> Version: 4.5.1  
> Guardian: Carter (Guardian)  
> Ministry: Configuration Management  
> Compliance: Seven Pillars, Hellodeolu v6

---

## Overview

Production inventory combines **static manifest** (source of truth) with **dynamic discovery** (runtime state). This provides:

- **Auditability**: Static manifest in Git tracks configuration intent
- **Accuracy**: Dynamic API data reflects actual network state
- **Idempotency**: Merge logic deterministic and repeatable
- **Scalability**: Works with 5 devices or 500+ devices

---

## Architecture

### Static Manifest Pattern

**File**: `inventory/device-manifest.yml`

Static inventory is the **source of truth** for device metadata:

```yaml
---
# Device manifest: canonical source for device inventory
# Purpose: Define device roles, tiers, and static metadata
# Authority: Network admin via Git PR
# Format: YAML, 140-char line limit (inline metadata)

devices:
  # Tier 1: Core infrastructure (full automation)
  - hostname: usg-3p-01
    device_role: gateway
    tier: T1
    ansible_host: 192.168.1.1
    ansible_user: ansible
    management_ip: 192.168.100.1
    device_type: ubiquiti_usg
    serial_number: "USG1234567"
    firmware_version: "2.1.3"
    vlan_management_id: 100
    dns_servers: ["1.1.1.1", "8.8.8.8"]
    ntp_servers: ["time.nist.gov", "time.google.com"]
    snmp_community: "public"
    monitoring_enabled: true
    backup_enabled: true
    backup_schedule: "0 2 * * *"

  - hostname: usw-24-poe-01
    device_role: switch
    tier: T1
    ansible_host: 192.168.1.10
    device_type: ubiquiti_switch
    serial_number: "SW0987654"
    firmware_version: "5.0.8"
    vlan_trunk_id: [1, 10, 20, 100]
    uplink_port: "1"
    redundancy_partner: "usw-24-poe-02"

  # Tier 2: Limited automation (backup only)
  - hostname: udk-gen2-01
    device_role: controller
    tier: T2
    ansible_host: 192.168.1.50
    device_type: ubiquiti_controller
    serial_number: "UDK789456"
    firmware_version: "7.3.166"
    backup_enabled: true
    restore_enabled: false

  # Tier 3: Monitoring only
  - hostname: uap-ac-pro-01
    device_role: access_point
    tier: T3
    ansible_host: 192.168.1.20
    device_type: ubiquiti_ap

  # Tier 4: Unmanaged
  - hostname: printer-office
    device_role: printer
    tier: T4
    ansible_host: 192.168.1.100

groups:
  # Group definitions
  unifi_gateways:
    - usg-3p-01

  unifi_switches:
    - usw-24-poe-01

  unifi_controllers:
    - udk-gen2-01

  unifi_access_points:
    - uap-ac-pro-01
```

**Key Principles**:

1. **Single source of truth**: Only Git updates device metadata
2. **Tier classification**: T1 (full), T2 (limited), T3 (monitor), T4 (none)
3. **Inline metadata**: 140-char limit allows complete device record per line
4. **Immutable**: Schema validated before accepting changes
5. **Auditable**: Every change tracked in Git history

---

### Dynamic Inventory Pattern

**File**: `scripts/unifi-dynamic-inventory.py`

Dynamic inventory fetches **runtime state** from UniFi Integration API v1:

```python
#!/usr/bin/env python3
"""
UniFi Dynamic Inventory for Ansible
Merges static device-manifest.yml with live API data

Usage:
  ansible-inventory -i scripts/unifi-dynamic-inventory.py --list
  ansible-playbook -i scripts/unifi-dynamic-inventory.py playbooks/manage-vlans.yml
"""

import json
import os
import sys
from typing import Any

import requests
from urllib3.exceptions import InsecureRequestWarning

# Suppress SSL warnings in lab environment (enable in production)
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


def fetch_api_devices() -> list[dict[str, Any]]:
  """
  Fetch devices from UniFi Integration API v1
  
  Endpoint: GET /proxy/network/integration/v1/sites/{site_id}/devices
  
  Returns:
    List of device dicts with runtime state:
      - name: Device hostname
      - ip: Current IP address
      - state: online/offline/unmanaged
      - version: Firmware version
      - model: Device model
      - uptime: Seconds since last restart
  """
  
  unifi_url = os.getenv("UNIFI_URL", "https://192.168.1.50:8443")
  api_key = os.getenv("UNIFI_API_KEY")
  site_id = os.getenv("UNIFI_SITE_ID", "default")
  
  if not api_key:
    raise ValueError("UNIFI_API_KEY environment variable not set")
  
  headers = {
    "X-API-KEY": api_key,
    "Accept": "application/json",
  }
  
  url = f"{unifi_url}/proxy/network/integration/v1/sites/{site_id}/devices"
  
  try:
    response = requests.get(url, headers=headers, verify=False, timeout=10)
    response.raise_for_status()
    
    data = response.json()
    if data.get("code") != "SUCCESS":
      raise ValueError(f"API error: {data.get('message', 'Unknown')}")
    
    return data.get("data", [])
  
  except requests.RequestException as e:
    print(f"ERROR: Failed to fetch devices: {e}", file=sys.stderr)
    return []


def load_static_manifest() -> dict[str, Any]:
  """
  Load device-manifest.yml as inventory source of truth
  
  Returns:
    Dict with 'devices' list and 'groups' dict
  """
  
  import yaml
  
  manifest_path = "inventory/device-manifest.yml"
  
  if not os.path.exists(manifest_path):
    raise FileNotFoundError(f"Manifest not found: {manifest_path}")
  
  with open(manifest_path) as f:
    return yaml.safe_load(f)


def merge_inventory() -> dict[str, Any]:
  """
  Merge static manifest + dynamic API data into Ansible inventory
  
  Algorithm:
    1. Load static manifest (source of truth)
    2. Fetch live device state from API
    3. Merge runtime state into static metadata
    4. Group devices by tier (T1-T4)
    5. Return Ansible-compatible inventory dict
  
  Returns:
    Ansible inventory format:
      {
        "_meta": {"hostvars": {"hostname": {...}}},
        "T1": {"hosts": ["hostname1", "hostname2"]},
        "T2": {"hosts": [...]},
        ...
      }
  """
  
  static = load_static_manifest()
  dynamic = fetch_api_devices()
  
  # Build device lookup by hostname (from API)
  dynamic_devices = {dev.get("name"): dev for dev in dynamic}
  
  # Initialize Ansible inventory
  inventory = {
    "_meta": {"hostvars": {}},
    "all": {"children": ["T1", "T2", "T3", "T4"]},
  }
  
  # Initialize tier groups
  for tier in ["T1", "T2", "T3", "T4"]:
    inventory[tier] = {"hosts": [], "vars": {}}
  
  # Populate from static manifest
  for device in static.get("devices", []):
    hostname = device.get("hostname")
    tier = device.get("tier", "T4")
    
    # Add to tier group
    if tier in inventory and hostname:
      inventory[tier]["hosts"].append(hostname)
    
    # Add host variables
    if hostname:
      hostvars = dict(device)  # Start with static metadata
      
      # Merge dynamic state if device is online
      if hostname in dynamic_devices:
        runtime = dynamic_devices[hostname]
        hostvars.update({
          "runtime_ip": runtime.get("ip"),
          "runtime_state": runtime.get("state"),
          "runtime_firmware": runtime.get("version"),
          "runtime_model": runtime.get("model"),
          "runtime_uptime_seconds": runtime.get("uptime"),
        })
      else:
        hostvars.update({
          "runtime_state": "unknown",  # Not in API response
        })
      
      inventory["_meta"]["hostvars"][hostname] = hostvars
  
  # Add group metadata
  for group_name, hosts in static.get("groups", {}).items():
    if group_name not in inventory:
      inventory[group_name] = {"hosts": []}
    inventory[group_name]["hosts"] = hosts
  
  return inventory


if __name__ == "__main__":
  try:
    inv = merge_inventory()
    print(json.dumps(inv, indent=2))
  except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)
    sys.exit(1)
```

**Key Features**:

1. **Read-only**: Never modifies devices or API state
2. **Deterministic**: Same manifest + API = same inventory
3. **Fault-tolerant**: Missing API device → use static metadata
4. **Mergeable**: Static + runtime = complete view
5. **Cacheable**: Can cache API results for speed

---

## Tier Classification (T1-T4)

| Tier | Automation | Scope | Examples | Ansible Treatment |
|------|-----------|-------|----------|-------------------|
| **T1** | Full | All configuration management | Gateway, core switch, controller | All playbooks |
| **T2** | Limited | Backup, monitoring, validation | Backup gateway, secondary controller | Safe tasks only |
| **T3** | Monitoring | Facts, connectivity, health | Printers, VoIP, guest devices | Read-only gather_facts |
| **T4** | None | Excluded from automation | Workstations, personal devices | Never targeted |

### Playbook Targeting Examples

```yaml
# Target only T1 (core infrastructure)
- hosts: T1
  gather_facts: yes
  tasks:
    - name: Apply configuration management
      # Full control - can deploy changes

# Target T1 + T2 (production + backup)
- hosts: "T1:T2"
  gather_facts: yes
  tasks:
    - name: Backup configurations
      # Safe tasks - no destructive changes

# Target T1 + T2 + T3 (everything except unmanaged)
- hosts: "!T4"
  gather_facts: yes
  tasks:
    - name: Gather monitoring data
      # Read-only - facts only
```

---

## Static Inventory File Format (hosts.yml)

**File**: `inventory/hosts.yml`

Alternative static-only format (for projects without API):

```yaml
---
all:
  children:
    T1:
      children:
        unifi_gateways:
          hosts:
            usg-3p-01:
              ansible_host: 192.168.1.1
              device_role: gateway
              ansible_user: ansible

        unifi_switches:
          hosts:
            usw-24-poe-01:
              ansible_host: 192.168.1.10
              device_role: switch

    T2:
      children:
        unifi_controllers:
          hosts:
            udk-gen2-01:
              ansible_host: 192.168.1.50
              device_role: controller

    T3:
      children:
        unifi_access_points:
          hosts:
            uap-ac-pro-01:
              ansible_host: 192.168.1.20

    T4:
      # Unmanaged devices (placeholder for reference)

  vars:
    ansible_user: ansible
    ansible_python_interpreter: /usr/bin/python3
    ansible_connection: ssh
```

---

## Integration with Dynamic Inventory

### CLI Usage

```bash
# Test dynamic inventory script
ansible-inventory -i scripts/unifi-dynamic-inventory.py --list | head -50

# List specific group
ansible-inventory -i scripts/unifi-dynamic-inventory.py --graph T1

# Use in playbook
ansible-playbook -i scripts/unifi-dynamic-inventory.py playbooks/manage-vlans.yml
```

### Environment Variables

```bash
export UNIFI_URL="https://192.168.1.50:8443"
export UNIFI_API_KEY="REDACTED_RYLANLABS_TOKEN_v1"
export UNIFI_SITE_ID="default"
```

### Caching for Performance

```bash
# Cache API results for 5 minutes (dev/lab only)
export ANSIBLE_INVENTORY_CACHE_PLUGIN=jsonfile
export ANSIBLE_INVENTORY_CACHE_PLUGIN_CONNECTION=/tmp/ansible_cache
export ANSIBLE_INVENTORY_CACHE_PLUGIN_TIMEOUT=300
```

---

## Group Variables (group_vars/)

### Structure

```
inventory/
├── device-manifest.yml
├── hosts.yml
└── group_vars/
    ├── all/
    │   ├── vars.yml          # Public variables
    │   └── vault.yml         # Encrypted secrets
    ├── T1/
    │   └── vars.yml
    ├── T2/
    │   └── vars.yml
    └── unifi_gateways/
        └── vars.yml
```

### Example: group_vars/all/vars.yml

```yaml
---
# Global variables for all devices
# Overridable per-group or per-host

ansible_user: ansible
ansible_port: 22
ansible_python_interpreter: /usr/bin/python3

# UniFi API configuration
unifi_url: "https://192.168.1.50:8443"
unifi_site_id: "default"
# unifi_api_key: from vault.yml (encrypted)

# Backup configuration
backup_retention_days: 30
backup_path: /opt/backups

# Monitoring
monitoring_enabled: true
ntp_servers:
  - "time.nist.gov"
  - "time.google.com"
```

### Example: group_vars/all/vault.yml

```yaml
---
# Encrypted secrets - commit to Git with ansible-vault
# Decrypt with: export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass

vault_unifi_api_key: "{{ unifi_api_key }}"
vault_snmp_community: "{{ snmp_community }}"
vault_backup_ssh_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----

# Encrypt with:
# ansible-vault encrypt inventory/group_vars/all/vault.yml
```

---

## Schema Validation

### device-manifest.yml Schema

```json
{
  "type": "object",
  "properties": {
    "devices": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["hostname", "device_role", "tier"],
        "properties": {
          "hostname": {"type": "string", "pattern": "^[a-z0-9-]+$"},
          "device_role": {
            "type": "string",
            "enum": ["gateway", "switch", "controller", "access_point", "device"]
          },
          "tier": {
            "type": "string",
            "enum": ["T1", "T2", "T3", "T4"]
          },
          "ansible_host": {"type": "string", "format": "ipv4"},
          "device_type": {"type": "string"},
          "serial_number": {"type": "string"},
          "vlan_management_id": {"type": "integer", "minimum": 1, "maximum": 4094}
        }
      }
    },
    "groups": {
      "type": "object",
      "additionalProperties": {
        "type": "array",
        "items": {"type": "string"}
      }
    }
  }
}
```

### Validation Script

```python
#!/usr/bin/env python3
"""Validate device-manifest.yml against schema"""

import json
import sys
import yaml
from jsonschema import validate, ValidationError

# Load schema
with open("schemas/device-manifest-schema.json") as f:
  schema = json.load(f)

# Load manifest
with open("inventory/device-manifest.yml") as f:
  manifest = yaml.safe_load(f)

try:
  validate(instance=manifest, schema=schema)
  print("✓ Manifest valid")
except ValidationError as e:
  print(f"✗ Validation error: {e.message}")
  sys.exit(1)
```

---

## Performance Considerations

### Static-Only (Recommended for Lab)
- **Pros**: No API calls, fast, no network dependency
- **Cons**: Manual updates, no runtime state
- **Use case**: Dev/lab with <50 devices

### Dynamic-Only
- **Pros**: Always current, API source of truth
- **Cons**: Slow (10-30s per API call), requires API access
- **Use case**: Not recommended (source of truth lost)

### Hybrid (Recommended for Production)
- **Pros**: Git audit trail + live state, optimal speed
- **Cons**: Requires maintenance of both
- **Use case**: Production with 50+ devices

### Caching Strategy

```ini
# ansible.cfg
[inventory]
cache = yes
cache_plugin = jsonfile
cache_connection = /tmp/ansible_inventory_cache
cache_timeout = 300  # Cache for 5 minutes

# Manually refresh:
# rm -rf /tmp/ansible_inventory_cache
```

---

## Migration Path

### From Static-Only to Hybrid

1. **Create device-manifest.yml** from hosts.yml
2. **Implement unifi-dynamic-inventory.py**
3. **Test both sources** in parallel
4. **Switch to dynamic** in playbooks
5. **Deprecate hosts.yml** after 2 weeks

```bash
# Step 1: Generate manifest from current inventory
python scripts/generate-manifest-from-hosts.py > inventory/device-manifest.yml

# Step 2: Test dynamic inventory
ansible-inventory -i scripts/unifi-dynamic-inventory.py --list | jq '.T1'

# Step 3: Dry-run playbook with dynamic inventory
ansible-playbook -i scripts/unifi-dynamic-inventory.py playbooks/test.yml --check

# Step 4: Switch to dynamic in CI/CD
# .github/workflows/trinity-ci.yml: -i scripts/unifi-dynamic-inventory.py
```

---

## References

- [Ansible Inventory Documentation](https://docs.ansible.com/ansible/latest/inventory_guide/index.html)
- [Dynamic Inventory Plugins](https://docs.ansible.com/ansible/latest/plugins/inventory.html)
- [Ansible Discipline](ansible-discipline.md)
- [Seven Pillars](../seven-pillars.md)
