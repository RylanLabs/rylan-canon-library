# Ansible Configuration Reference

> Canonical ansible.cfg settings for production playbooks  
> Version: 4.5.1  
> Guardian: Bauer (Auditor)  
> Ministry: Configuration Management  
> Compliance: Seven Pillars, Hellodeolu v6

---

## Overview

`ansible.cfg` defines global settings that apply to all playbooks. Canonical configuration optimizes for:

- **Performance**: Caching, pipelining, reduced round-trips
- **Security**: Vault integration, SSH hardening, minimal exposure
- **Auditability**: Logging, callbacks, detailed output
- **Reliability**: Retries, timeouts, graceful degradation

---

## Canonical Configuration

**File**: `ansible.cfg`

```ini
# RylanLabs Canonical Ansible Configuration
# Version: 4.5.1
# Guardian: Bauer (Auditor)
# Purpose: Standardized settings for all projects
#
# Usage: Copy to new project root, customize as needed
# Security: Never commit plaintext secrets - use ansible-vault

[defaults]
# ============================================================================
# INVENTORY & DISCOVERY
# ============================================================================

# Primary inventory source (override with -i option)
inventory = inventory/hosts.yml

# Enable specific inventory plugins (order matters)
enable_plugins = host_list, yaml, ini, script, auto

# Inventory discovery patterns
extensions = yml, yaml, ini

# Inventory caching (for dynamic inventory performance)
# Requires: inventory cache plugin (see [inventory] section)

# ============================================================================
# CONNECTION & EXECUTION
# ============================================================================

# Default remote user (can override per-host)
remote_user = ansible

# Don't require SSH password (use keys only)
ask_pass = False

# Default port for SSH connections
remote_port = 22

# Connection plugins (order of preference)
connection = ssh

# Timeout for connections (seconds)
timeout = 10

# Python interpreter on remote host
interpreter_python = auto_silent
# Options:
#   auto        - Detect from ansible_python_interpreter
#   auto_silent  - Auto without warnings
#   /usr/bin/python3 - Explicit path

# Pipelining: Reduce SSH round-trips by 40-60%
# WARNING: Incompatible with "sudo" without NOPASSWD
pipelining = True

# SSH args for all connections
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
# -C: Compression
# ControlMaster=auto: SSH connection multiplexing
# ControlPersist=60s: Keep connection alive for 60s
# StrictHostKeyChecking=no: Accept new host keys (lab only - disable in prod)

# Control path for SSH multiplexing
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

# ============================================================================
# FACTS & GATHERING
# ============================================================================

# Gather facts strategy (network optimization)
gathering = smart
# Options:
#   implicit  - Always gather facts (slow, compatible)
#   explicit  - Only when "gather_facts: yes" in playbook
#   smart     - Gather once per host (recommended)
#   once      - Gather once on first play

# Fact caching backend (requires jsonfile or other plugin)
fact_caching = jsonfile

# Cache connection string (where to store facts)
fact_caching_connection = /tmp/ansible_facts

# Cache timeout (seconds, 0 = never expire)
fact_caching_timeout = 3600

# Preferred SSH key file (if multiple keys available)
private_key_file = ~/.ssh/id_ed25519

# Check for host key in known_hosts (security vs convenience trade-off)
host_key_checking = True
# Set to False in lab environment if host keys change frequently

# ============================================================================
# PARALLELISM & PERFORMANCE
# ============================================================================

# Number of parallel connections (default: 5)
forks = 10
# Increase for large inventories (50+ hosts)
# Decrease if control node has low resources

# Strategy for executing tasks (linear, free, host_pinning)
strategy = linear
# linear: Sequential host ordering (safest)
# free: Hosts proceed independently (fast but harder to debug)

# ============================================================================
# CALLBACKS & OUTPUT
# ============================================================================

# Stdout callback plugin (default: default)
stdout_callback = yaml
# Options: default, json, yaml, dense, minimal, skippy, unixy, pretty

# Always show task output, even for skipped tasks
display_skipped_hosts = False

# Show task output for successful tasks
display_ok_hosts = True

# Enable custom callback plugins
bin_ansible_callbacks = True

# Always show changed status (easier to follow)
display_changed = True

# ============================================================================
# VARS & HANDLING
# ============================================================================

# Merge multiple YAML files in group_vars/ (if directory)
# Allows splitting large group_vars into multiple files
# Requires: Ansible 2.12+
# group_vars directories are merged by default

# Undefined variable handling
undefined_var_behavior = error
# error: Fail if variable undefined
# warn: Warn but continue
# strict: Strict mode (recommended)

# YAML parsing - allow duplicate keys (not recommended)
duplicate_variable_warning = True

# Include task error handling context
force_valid_group_names = True

# ============================================================================
# RETRY & ERROR HANDLING
# ============================================================================

# Retry files location (track failed tasks)
retry_files_enabled = True
retry_files_save_path = .ansible-retry/

# Max attempts before giving up (when using retries: N)
# No global setting - configured per-task

# ============================================================================
# PRIVILEGE ESCALATION
# ============================================================================

[privilege_escalation]

# Enable sudo by default (can override per-task with become:)
become = False

# Privilege escalation method
become_method = sudo
# Options: sudo, su, pbrun, pfexec, doas, ksu

# User to escalate to (default: root)
become_user = root

# Ask password for escalation (not recommended - use NOPASSWD)
become_ask_pass = False

# ============================================================================
# PLUGINS & EXTENSIONS
# ============================================================================

[inventory]

# Inventory caching (for dynamic inventory performance)
cache = yes

# Cache plugin backend (jsonfile or other)
cache_plugin = jsonfile

# Cache connection (directory for jsonfile)
cache_connection = /tmp/ansible_inventory_cache

# Cache timeout (seconds)
cache_timeout = 300

# ============================================================================
# SSH CONNECTION SETTINGS
# ============================================================================

[ssh_connection]

# Connection control
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

# Pipelining reduces SSH round-trips
pipelining = True

# Transfer binary files more efficiently
retries = 3
timeout = 10

# ============================================================================
# VAULT (ENCRYPTED SECRETS)
# ============================================================================

# Vault password file location (DO NOT COMMIT - add to .gitignore)
vault_password_file = .vault_pass
# Alternative: export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass

# Vault identity (for projects with multiple vault passwords)
# vault_identity_list = default, prod, lab

# ============================================================================
# ROLES
# ============================================================================

[defaults]

# Roles search path (where to find roles/)
roles_path = roles:~/.ansible/roles:/usr/share/ansible/roles

# ============================================================================
# PYTHON & DEPENDENCIES
# ============================================================================

# Path to Python interpreter on control node
# (Usually defaults to system Python - no need to set)

# Library paths (where to find custom modules/plugins)
library = library

# ============================================================================
# LOGGING & DEBUGGING
# ============================================================================

# Log file for all Ansible events
log_path = /var/log/ansible.log
# Note: Set this only on control node, not in repo (or use CI-specific)

# Log format string (default: %(now)s - %(levelname)s - %(message)s)
# log_format = %(asctime)s | %(name)s | %(levelname)s | %(message)s
```

---

## Environment Variables (Override ansible.cfg)

Set environment variables to override `ansible.cfg` for single runs:

```bash
# Inventory
export ANSIBLE_INVENTORY=inventory/hosts.yml
export ANSIBLE_INVENTORY_PLUGINS=/usr/local/lib/ansible/plugins/inventory

# Connection
export ANSIBLE_REMOTE_USER=ansible
export ANSIBLE_PRIVATE_KEY_FILE=~/.ssh/id_ed25519
export ANSIBLE_SSH_ARGS="-C -o ControlMaster=auto"

# Performance
export ANSIBLE_FORKS=20
export ANSIBLE_GATHERING=smart

# Vault
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass

# Callbacks & Output
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_FORCE_COLOR=True

# Logging
export ANSIBLE_LOG_PATH=/tmp/ansible.log
export ANSIBLE_DEBUG=True

# Example: Override for single playbook run
ANSIBLE_FORKS=50 ansible-playbook playbooks/manage-vlans.yml
```

---

## Vault Integration

### Setup Vault Password File

```bash
# Create encrypted password file (don't commit to Git!)
echo "my_vault_password_123" > .vault_pass
chmod 600 .vault_pass
echo ".vault_pass" >> .gitignore

# Set in ansible.cfg
vault_password_file = .vault_pass
```

### Encrypt Sensitive Data

```bash
# Create encrypted group_vars file
ansible-vault create inventory/group_vars/all/vault.yml

# Edit encrypted file
ansible-vault edit inventory/group_vars/all/vault.yml

# Encrypt existing file
ansible-vault encrypt inventory/group_vars/all/vault.yml

# Decrypt for viewing (temporary)
ansible-vault view inventory/group_vars/all/vault.yml
```

### Content of vault.yml

```yaml
---
# Ansible Vault encrypted file (version 1.2)
# Contains sensitive secrets for production

vault_unifi_api_key: "{{ unifi_api_key }}"
vault_backup_ssh_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
vault_snmp_community: "community-string-123"
vault_syslog_key: "encryption-key-for-syslog"

# Reference in playbooks:
# - name: Configure UniFi API
#   uri:
#     headers:
#       X-API-KEY: "{{ vault_unifi_api_key }}"
```

---

## SSH Key Management

### Generate ED25519 Keys (Recommended)

```bash
# Generate for Ansible user
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "ansible@control-node"

# Generate for deployment (stronger passphrase)
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -C "ansible-deploy"

# Add to ssh-agent for passwordless authentication
ssh-add ~/.ssh/id_ed25519

# Copy to remote devices
ssh-copy-id -i ~/.ssh/id_ed25519 ansible@192.168.1.1
```

### Configure SSH Config (~/.ssh/config)

```
Host usg-3p-01
  HostName 192.168.1.1
  User ansible
  IdentityFile ~/.ssh/id_ed25519
  ControlMaster auto
  ControlPath /tmp/ssh-%%h-%%p-%%r
  ControlPersist 60

Host usw-24-poe-01
  HostName 192.168.1.10
  User ansible
  IdentityFile ~/.ssh/id_ed25519

Host *.lan
  User ansible
  IdentityFile ~/.ssh/id_ed25519
```

---

## Performance Tuning

### For Large Inventories (50+ hosts)

```ini
[defaults]
forks = 20
gathering = smart
fact_caching = jsonfile
fact_caching_timeout = 3600

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
```

### For Lab Environments (Fast Iteration)

```ini
[defaults]
host_key_checking = False  # Accept any host key
forks = 10
gathering = smart
display_skipped_hosts = True

[ssh_connection]
pipelining = True
```

### For Production (Conservative)

```ini
[defaults]
host_key_checking = True   # Verify host keys
forks = 5
gathering = smart
display_skipped_hosts = False
undefined_var_behavior = strict

[ssh_connection]
pipelining = True
retries = 3
timeout = 30
```

---

## Debugging & Troubleshooting

### Enable Verbose Output

```bash
# Level 1: Basic info
ansible-playbook -v playbooks/manage-vlans.yml

# Level 2: More details
ansible-playbook -vv playbooks/manage-vlans.yml

# Level 3: Full debug output
ansible-playbook -vvv playbooks/manage-vlans.yml

# Level 4: Connection debugging
ansible-playbook -vvvv playbooks/manage-vlans.yml
```

### Debug Inventory

```bash
# List all hosts
ansible-inventory --list | jq '.all.hosts'

# Show vars for specific host
ansible-inventory --host usg-3p-01 | jq .

# Graph inventory structure
ansible-inventory --graph

# Check specific group
ansible-inventory --graph T1
```

### Test Connectivity

```bash
# Ping all hosts
ansible all -m ping

# Ping specific group
ansible T1 -m ping -v

# Gather facts (test Python connectivity)
ansible all -m setup -a 'filter=ansible_python_version'

# Check if user can sudo
ansible all -m command -a 'whoami' -b
```

### Dry-Run Mode

```bash
# Syntax check only
ansible-playbook playbooks/manage-vlans.yml --syntax-check

# Dry-run (check mode)
ansible-playbook playbooks/manage-vlans.yml --check

# Dry-run with differences
ansible-playbook playbooks/manage-vlans.yml --check --diff

# Run with step-by-step confirmation
ansible-playbook playbooks/manage-vlans.yml --step
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
# .github/workflows/ansible-ci.yml
name: Ansible Validation

on: [push, pull_request]

env:
  ANSIBLE_VAULT_PASSWORD_FILE: .vault_pass

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Ansible
        run: pip install ansible ansible-lint
      
      - name: Lint playbooks
        run: ansible-lint playbooks/
      
      - name: Syntax check
        run: |
          find playbooks/ -name "*.yml" | xargs -I {} \
            ansible-playbook --syntax-check {}
```

---

## References

- [Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Inventory Patterns](inventory-patterns.md)
- [Ansible Discipline](ansible-discipline.md)
- [Seven Pillars](../seven-pillars.md)
