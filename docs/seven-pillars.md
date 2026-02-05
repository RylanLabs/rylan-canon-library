# Seven Pillars of Production-Grade Code

> Canonical definition — Infrastructure-as-Code standards
> Version: v2.1.0 (Mesh-Aligned)
> Date: 2026-02-04

---

## The Pillars (Production-Grade — Non-Negotiable)

### 1. Idempotency

**Principle**: Multiple executions produce identical outcome — no side effects on re-run.

**Why**: Junior-at-3-AM must re-run safely. Prevents drift, enables automation.

**Canon**:
- Check state before action
- Declarative source of truth (YAML/JSON)
- No destructive ops without guard

**Example**:
```bash
# BAD — appends every run
echo "key=value" >> /etc/config

# GOOD — idempotent
if ! grep -q "^key=" /etc/config; then
  echo "key=value" >> /etc/config
fi
```

---

### 2. Error Handling

**Principle**: Fail fast, fail loud, provide context.

**Why**: 3-AM failures need immediate actionable diagnosis.

**Canon**:
- \`set -euo pipefail\` mandatory
- Trap ERR + EXIT
- Meaningful exit codes (0=pass, 1=err, 2=usage, 3=config, 4=net, 5=perm)
- Actionable messages (what + how to fix)

**Example**:
```bash
#!/usr/bin/env bash
set -euo pipefail
trap 'echo "ERROR at line \$LINENO (exit \$?)"; exit 1' ERR

if [[ ! -f "\$CONFIG" ]]; then
  echo "❌ Config missing: \$CONFIG" >&2
  echo "   Create: cp config.example.yaml \$CONFIG" >&2
  exit 3
fi
```

---

### 3. Audit Logging

**Principle**: Every action traceable.

**Why**: Forensics, compliance, blameless post-mortems.

**Canon**:
- Timestamped to stderr
- Success + failure logged
- Git commits explain WHY (Conventional Commits)
- Structured (JSON) when complex

**Example**:
```bash
log() { echo "[\$(date -Iseconds)] \$*" >&2; }
log "Starting VLAN 10 creation"
log_success "VLAN 10 created"
```

---

### 4. Documentation Clarity

**Principle**: Junior at 3 AM can run and understand.

**Why**: Knowledge transfer > clever code.

**Canon**:
- Header: purpose, usage, prereqs, output, agent
- Inline comments for non-obvious
- Clear naming (kebab-case files, snake_case functions)
- README quick-start with examples

---

### 5. Validation

**Principle**: Verify inputs, preconditions, and postconditions.

**Why**: Prevent garbage-in-garbage-out; ensure state matches intent.

**Canon**:
- Pre-flight checks pass before change
- Post-flight checks verify success
- Multi-repo compliance (Whitaker)

---

### 6. Reversibility

**Principle**: Rollback path always exists.

**Why**: Partial failures must not leave broken state.

**Canon**:
- Backup before destructive change
- Trap cleanup
- Rollback instructions in error
- RTO <15min (Lazarus)

---

### 7. Observability

**Principle**: Visibility into state and progress.

**Why**: Understanding "what is happening now" during execution.

**Canon**:
- Progress reporting
- Debugging information available (VERBOSE=1)
- Integration with mesh monitoring

---

**Trinity Alignment**:
1. **Carter**: Identity (Idempotency, Documentation)
2. **Bauer**: Verification (Error Handling, Validation)
3. **Beale**: Hardening (Audit Logging, Security)
4. **Whitaker**: Offensive Validation (Observability)
5. **Lazarus**: Recovery (Reversibility)

**Hellodeolu v7 Outcomes**:
- Junior-at-3-AM deployable
- Maturity Level 5 (Autonomous)
- Dynamic Mesh Reconciliation

**The fortress demands these pillars. No exceptions.**
