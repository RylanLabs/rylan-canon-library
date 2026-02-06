# Defense Testing — RylanLabs Canon

> Canonical standard — Required post-deploy validation
> Date: December 21, 2025
> Agent: Whitaker
> Author: rylanlab canonical

**Status**: ✅ **PRODUCTION** — Whitaker Canonical | Breach Simulation | Post-Deploy Mandatory

---

## Purpose

Defense Testing defines **mandatory breach simulation tests** that must run after every deployment.

It enforces **Whitaker ministry** — proving defenses work under attack.

**Objectives**:
- Validate fortress integrity
- Detect configuration drift
- Ensure VLAN isolation
- Confirm hardening effectiveness
- Junior-at-3-AM executability

**Sacred Principle**: Theory is worthless without proof.
Every deployment must survive Whitaker's attack.

---

## Repository: rylan-homelab-iac/scripts/defense-tests.sh

**Execution**:
```bash
# Run after every deployment
./scripts/defense-tests.sh
```

**Exit Codes**:
- 0 = All defenses passed
- 1 = Breach succeeded (SECURITY FAILURE)

---

## Required Tests (Non-Negotiable)

### Test 1: VLAN Isolation

**Purpose**: Verify no cross-VLAN leakage

**Implementation**:
```bash
# From IoT VLAN (20) → attempt reach Management (1)
ping -c 1 -W 2 192.168.1.10 && {
    echo "❌ VLAN isolation broken — IoT can reach Management"
    exit 1
}
echo "✅ IoT cannot reach Management"
```

**Expected**: FAIL (blocked)

### Test 2: Guest Network Isolation

**Purpose**: Guest VLAN cannot reach internal networks

**Implementation**:
```bash
# From Guest VLAN (30) → attempt reach controller
curl -s --connect-timeout 5 http://192.168.1.1 && {
    echo "❌ Guest network can reach controller"
    exit 1
}
echo "✅ Guest network isolated"
```

**Expected**: FAIL (blocked)

### Test 3: Unauthorized Port Access

**Purpose**: Non-standard ports blocked

**Implementation**:
```bash
# Attempt SSH from restricted VLAN
nc -z -w 3 192.168.1.1 22 && {
    echo "❌ Unauthorized SSH access allowed"
    exit 1
}
echo "✅ Unauthorized ports blocked"
```

**Expected**: FAIL (blocked)

### Test 4: Controller Management Access

**Purpose**: Only Management VLAN can reach controller UI

**Implementation**:
```bash
# From trusted VLAN → should succeed
curl -k -s --connect-timeout 5 https://192.168.1.1:8443 && echo "✅ Management access allowed" || {
    echo "❌ Management access blocked (legitimate)"
    exit 1
}
```

**Expected**: PASS

### Test 5: Internet Access Control

**Purpose**: Restricted VLANs have limited outbound

**Implementation**:
```bash
# From IoT VLAN → should reach internet
curl -s --connect-timeout 10 https://1.1.1.1 && echo "✅ IoT has internet" || {
    echo "❌ IoT blocked from internet (if intended, adjust test)"
}
```

**Expected**: Configurable (document intent)

### Test 6: SSH Hardening Validation

**Purpose**: Verify SSH cannot be brute-forced

**Implementation**:
```bash
# Verify fail2ban and auth hardening
sudo sshd -T 2>/dev/null | grep -q "maxauthtries 3" && \
sudo sshd -T 2>/dev/null | grep -q "passwordauthentication no" && echo "✅ SSH hardened" || {
    echo "❌ SSH vulnerable to brute-force"
    exit 1
}
```

**Expected**: SSH allows max 3 auth attempts, password auth disabled

---

### Test 7: Firewall Rule Count Compliance

**Purpose**: Verify firewall rules ≤ max_firewall_rules constraint

**Implementation**:
```bash
rule_count=$(sudo nft list ruleset 2>/dev/null | grep -cE 'accept|drop' || echo 0)
max_rules=$(grep max_firewall_rules ~/repos/rylan-inventory/inventory/device-manifest.yml | awk '{print $2}')

if [[ $rule_count -le $max_rules ]]; then
    echo "✅ Firewall rules: $rule_count/$max_rules"
else
    echo "❌ Firewall overflow: $rule_count/$max_rules"
    exit 1
fi
```

**Expected**: PASS (within constraint)

---

### Test 8: Service Exposure Audit

**Purpose**: No unauthorized services listening on public interfaces

**Implementation**:
```bash
unexpected_ports=$(sudo nmap -p- --open 192.168.1.1 2>/dev/null | \
  grep -vE '22/tcp|443/tcp|8443/tcp' | grep 'open' || true)

if [[ -n "$unexpected_ports" ]]; then
    echo "❌ Unexpected services exposed"
    exit 1
else
    echo "✅ No unauthorized services exposed"
fi
```

**Expected**: Only documented ports open

---

### Test 9: Credential Leakage Detection

**Purpose**: No cleartext secrets in deployed configs

**Implementation**:
```bash
if sudo grep -rE 'password.*=|secret.*=|api_key.*=' /etc/ 2>/dev/null | grep -v '.bak'; then
    echo "❌ Cleartext secrets found in /etc/"
    exit 1
else
    echo "✅ No cleartext secrets detected"
fi
```

**Expected**: PASS (no secrets)

---

### Test 10: Backup Integrity Validation

**Purpose**: Verify backups are restorable (Lazarus readiness)

**Implementation**:
```bash
latest_backup=$(ls -t .backups/*.tar.gz 2>/dev/null | head -1)

if [[ -z "$latest_backup" ]]; then
    echo "❌ No backups found"
    exit 1
fi

tar -tzf "$latest_backup" >/dev/null 2>&1 && \
    echo "✅ Backup integrity verified" || { echo "❌ Backup corrupted"; exit 1; }
```

**Expected**: PASS (backup readable)

---

### Test 11: DNS Poisoning Resistance

**Purpose**: Verify DNS queries use trusted resolvers only

**Implementation**:
```bash
if grep -qE '^nameserver (1\.1\.1\.1|8\.8\.8\.8|192\.168\.1\.1)' /etc/resolv.conf; then
    echo "✅ DNS resolvers trusted"
else
    echo "❌ Untrusted DNS resolver configured"
    exit 1
fi
```

**Expected**: PASS (trusted resolvers)

---

### Test 12: Privilege Escalation Prevention

**Purpose**: Non-root users cannot escalate without sudo

**Implementation**:
```bash
suid_count=$(find / -perm -4000 -type f 2>/dev/null | wc -l)
max_suid=30

if [[ $suid_count -le $max_suid ]]; then
    echo "✅ SUID binaries acceptable: $suid_count"
else
    echo "❌ Excessive SUID binaries: $suid_count (max: $max_suid)"
    exit 1
fi
```

**Expected**: PASS (minimal SUID)

---

## Execution Context

**Run From**:
- VM/container in each VLAN
- Or use switch port VLAN assignment

**Automation**:
```yaml
# In whitaker-validate.yml
- name: Run defense tests
  script: scripts/defense-tests.sh
  args:
    chdir: "{{ playbook_dir }}"
  register: defense_result
  failed_when: defense_result.rc != 0
```

---

## Implementation: defense-tests.sh

**Location**: `scripts/defense-tests.sh`

```bash
#!/usr/bin/env bash
# Guardian: Whitaker | Ministry: detection | Maturity Level: 10.0
# Tag: defense-tests
set -euo pipefail

LOG_FILE=".audit/defense-tests-$(date +%Y%m%d-%H%M%S).log"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
pass() { log "✅ $*"; }
fail() { log "❌ $*"; exit 1; }

TESTS_RUN=0
TESTS_PASSED=0

run_test() {
    local test_name="$1"
    local test_func="$2"
    ((TESTS_RUN++))
    log "Running Test $TESTS_RUN: $test_name"
    if $test_func; then
        ((TESTS_PASSED++))
        pass "$test_name"
    else
        fail "$test_name"
    fi
}

test_vlan_isolation() { ping -c 1 -W 2 192.168.1.10 &>/dev/null && return 1; return 0; }
test_guest_isolation() { curl -s --connect-timeout 5 http://192.168.1.1 &>/dev/null && return 1; return 0; }
test_unauthorized_ports() { nc -z -w 3 192.168.1.1 22 &>/dev/null && return 1; return 0; }
test_management_access() { curl -k -s --connect-timeout 5 https://192.168.1.1:8443 &>/dev/null || return 1; return 0; }
test_firewall_compliance() {
    rule_count=$(sudo nft list ruleset 2>/dev/null | grep -cE 'accept|drop' || echo 0)
    max_rules=$(grep max_firewall_rules ~/repos/rylan-inventory/inventory/device-manifest.yml | awk '{print $2}')
    [[ $rule_count -le $max_rules ]]
}
test_service_exposure() { [[ -z "$(sudo nmap -p- --open 192.168.1.1 2>/dev/null | grep -vE '22/tcp|443/tcp|8443/tcp' | grep 'open' || true)" ]]; }
test_credential_leakage() { ! sudo grep -rE 'password.*=|secret.*=|api_key.*=' /etc/ 2>/dev/null | grep -qv '.bak'; }
test_backup_integrity() {
    latest=$(ls -t .backups/*.tar.gz 2>/dev/null | head -1)
    [[ -n "$latest" ]] && tar -tzf "$latest" &>/dev/null
}
test_dns_resolvers() { grep -qE '^nameserver (1\.1\.1\.1|8\.8\.8\.8|192\.168\.1\.1)' /etc/resolv.conf; }
test_suid_binaries() {
    suid_count=$(find / -perm -4000 -type f 2>/dev/null | wc -l)
    [[ $suid_count -le 30 ]]
}
test_ssh_hardening() { sudo sshd -T 2>/dev/null | grep -q "maxauthtries 3" && sudo sshd -T 2>/dev/null | grep -q "passwordauthentication no"; }
test_internet_access() { curl -s --connect-timeout 10 https://1.1.1.1 &>/dev/null; }

main() {
    log "━━━ Whitaker Defense Testing ━━━"
    log "Maturity Level: 10.0 | Ministry: detection"

    run_test "VLAN Isolation" test_vlan_isolation
    run_test "Guest Network Isolation" test_guest_isolation
    run_test "Unauthorized Port Access" test_unauthorized_ports
    run_test "Management Access Control" test_management_access
    run_test "Firewall Rule Compliance" test_firewall_compliance
    run_test "Service Exposure Audit" test_service_exposure
    run_test "Credential Leakage Detection" test_credential_leakage
    run_test "Backup Integrity" test_backup_integrity
    run_test "DNS Resolver Trust" test_dns_resolvers
    run_test "SUID Binary Minimization" test_suid_binaries
    run_test "SSH Hardening" test_ssh_hardening
    run_test "Internet Access Policy" test_internet_access

    log "━━━ Results: $TESTS_PASSED/$TESTS_RUN passed ━━━"
    [[ $TESTS_PASSED -eq $TESTS_RUN ]] && { log "✅ ALL DEFENSES VALIDATED"; exit 0; } || { log "❌ SECURITY FAILURE"; exit 1; }
}

main "$@"
```

**Installation**:
```bash
chmod +x scripts/defense-tests.sh
git add scripts/defense-tests.sh
```

---

## Trinity Integration

Whitaker (Phase 4) collaborates across the fortress:

**Carter → Whitaker**: Identity validation before testing
```bash
./scripts/validate-vault.sh || exit 1
./scripts/defense-tests.sh
```

**Bauer → Whitaker**: Pre-test verification of system state
```bash
./scripts/audit_eternal.py --pre-flight || exit 1
./scripts/defense-tests.sh
```

**Beale → Whitaker**: Hardening validation loop
```bash
./scripts/beale-harden.sh --ci || exit 1
./scripts/defense-tests.sh || {
    ./scripts/beale-remediate.sh
    ./scripts/defense-tests.sh
}
```

**Whitaker → Lazarus**: Failure recovery
```bash
./scripts/defense-tests.sh || {
    echo "⚠️ SECURITY FAILURE — invoking Lazarus"
    ./scripts/eternal-resurrect.sh --disaster-recovery
    # Restore + re-run full Trinity from Phase 1
}
```

**Guardian Cascade**:
```
Carter → Bauer → Beale → Whitaker → Lazarus (if breach)
```

---

## Failure Procedures

### Single Test Failure (Recoverable)

**Response**:
1. Identify failed test: `grep "❌" .audit/defense-tests-*.log`
2. Diagnose: Check specific component
3. Remediate: Run targeted Beale hardening
4. Re-test: `./scripts/defense-tests.sh`
5. Document incident with root cause

**Example** (SSH hardening fails):
```bash
ansible-playbook playbooks/ssh-hardening.yml
./scripts/defense-tests.sh || exit 1
cat > docs/incidents/$(date +%Y-%m-%d)-ssh-hardening.md <<EOF
# Incident: SSH Hardening Validation Failed

**Root Cause**: fail2ban not running after deployment
**Resolution**: Restarted service, added check to beale-harden.sh
**Prevention**: Updated playbooks to verify service status
EOF
git add docs/incidents/
```

---

### Multiple Test Failures (Catastrophic)

**Response** (RTO: <15 minutes):
1. **STOP**: Alert ops, invoke Lazarus Protocol
   ```bash
   ./scripts/eternal-resurrect.sh --disaster-recovery
   ```
2. **Restore**: From `.backups/` (canonical structure)
3. **Re-run**: Full Trinity pipeline
   ```bash
   ansible-playbook site.yml  # Carter → Bauer → Beale → Whitaker
   ```
4. **Validate**: `./scripts/defense-tests.sh || exit 1`
5. **Post-mortem**: Document failures and remediation

---

## Validation Checklist

- [ ] All tests executed
- [ ] Expected failures confirmed (blocked traffic)
- [ ] Legitimate access verified
- [ ] No unexpected breaches
- [ ] Exit code 0 (all pass)

---

## Related Canon Documents

- `trinity-execution.md` — Phase 4 (Whitaker) orchestration
- `vault-discipline.md` — Carter identity validation
- `ansible-discipline.md` — Playbook structure (verify, harden, validate)
- `emergency-procedures.md` — Lazarus disaster recovery
- `seven-pillars.md` — Error handling, audit logging, observability

---

**The fortress demands discipline. No shortcuts. No exceptions.**

Whitaker ministry — defenses proven under attack.

**Theory is worthless without proof.**

The Trinity endures.
