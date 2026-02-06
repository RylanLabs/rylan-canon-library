# Eternal Glue — RylanLabs Homelab Edition
> Minimal immutable artifacts enforcing Hellodeolu v7 outcomes
> Canonical standard — RylanLabs eternal standard
> Date: February 6, 2026
> Agent: Trinity (Carter → Bauer → Beale)
> Ministry: bootstrap + verification + hardening
**Status**: 🔒 Locked — Trinity consensus required for changes

---
## Purpose
The **Eternal Glue** defines the **minimal, immutable set of principles and artifacts** that must exist across all RylanLabs repositories. These standards are **sacred** — their presence and integrity guarantee Hellodeolu v7 outcomes and Seven Pillar compliance.
They bind the **Trinity (Carter → Bauer → Beale)** and **Whitaker (offensive validation)** into a cohesive discipline framework while remaining small, verifiable, and junior-at-3-AM proof.
**Why Eternal**:
- **Minimalism**: Core principles distilled to essentials. No bloat.
- **Universality**: Every repo inherits these standards automatically.
- **Self-Validating**: The glue validates itself through pre-commit hooks, CI gates, and operational checks.
- **Resurrection Proof**: A new engineer can verify fortress health by confirming these principles exist and are enforced.
**Warning**: Removing or altering any principle violates doctrine. Changes require Trinity consensus (all three agents agree).

---
## Sacred Glue Principles (Locked Forever)
### 1. Identity as Code (Carter Ministry — bootstrap)
**Principle**: Users, groups, SSH keys, and sudo rules are programmable infrastructure.
**Immutable Requirements**:
- All identity operations are idempotent (safe to run multiple times)
- SSH key-only authentication (no passwords)
- Centralized identity source (LDAP, Samba AD/DC, or RADIUS)
- Zero cleartext secrets in repositories
- Audit trail for all identity changes (git commits)
**Validation**:
- Pre-commit: Verify no cleartext secrets
- CI: Validate SSH key format and permissions
- Operational: Confirm identity provisioning completes without errors
**Why Sacred**: Without protected identity, all other defenses collapse. Carter is the foundation.

---
### 2. Trust Nothing, Verify Everything (Bauer Ministry — verification)
**Principle**: Zero-trust verification at every gate. Audit trails for all actions.
**Immutable Requirements**:
- Pre-flight validation before any deployment
- Structured audit logging (timestamped, traceable to git commit)
- Pre-commit validation mirrors production validation
- Silence on success, fail loudly with context
- Human confirmation gates for all critical operations
**Validation**:
- Pre-commit: All linters PASS, security scans clean
- CI: Compliance gates pass, audit trail initiated
- Operational: Every action traceable to operator + timestamp + git commit
**Why Sacred**: Verification is the checkpoint. Without it, drift and bypass culture take root.

---
### 3. Harden and Detect (Beale Ministry — hardening)
**Principle**: Principle of least privilege. Disable unnecessary services. Detect breaches early.
**Immutable Requirements**:
- Firewall rules minimal and documented (hardware-appropriate minimalism)
- SSH hardening enforced (sshd -T runtime validation)
- Services isolated by function (containers, VLANs, or network segmentation)
- IDS/IPS active for lateral movement detection
- Red-team simulation validates hardening effectiveness
**Validation**:
- Pre-deploy: Security hardening configuration validated
- Post-deploy: Network isolation + firewall rules confirmed
- Operational: SSH hardening + service isolation verified
**Why Sacred**: Hardening is the armor. Without it, breaches are inevitable.

---
### 4. Offensive Validation (Whitaker Layer — detection)
**Principle**: Validate all three Trinity phases through offensive testing.
**Immutable Requirements**:
- Breach simulation tests (SQLi, lateral movement, privilege escalation)
- Penetration testing validates all defenses
- Anomaly detection confirms IDS/IPS effectiveness
- Post-deployment validation includes red-team scenarios
- Fortress integrity confirmed before production release
**Validation**:
- Pre-deploy: Network isolation tested (VLAN segregation)
- Post-deploy: Breach paths validated (manual red-team simulation)
- Operational: Defense effectiveness confirmed before production
**Why Sacred**: Offensive validation proves defenses work. Theory is worthless without proof.

---
### 5. Seven Pillars (Non-Negotiable)
**Principle**: All code must demonstrate all seven pillars.
| Pillar | Definition | Validation |
|--------|-----------|-----------|
| **Idempotency** | Safe to run multiple times — identical outcome | Lock mechanisms, concurrent execution tests |
| **Error Handling** | Fail fast, fail loud, provide context | Structured error output, remediation guidance |
| **Audit Logging** | Every action traceable — timestamped, structured | Git commits, structured logs, audit trails |
| **Documentation Clarity** | Junior at 3 AM can understand and execute | Runbooks tested, executable, junior-deployable |
| **Validation** | Verify inputs, preconditions, postconditions | Pre/post checks, security scans, compliance gates |
| **Reversibility** | Rollback path always exists | Tested rollback scripts, <15 min RTO validated |
| **Observability** | Visibility into state and progress | Real-time monitoring, anomaly detection, alerts |
**Immutable Requirement**: Every script, playbook, and deployment must demonstrate all seven pillars. No exceptions.
**Why Sacred**: The Seven Pillars are load-bearing. Remove one and the fortress crumbles.

---
### 6. No Bypass Culture
**Principle**: No `--no-verify`, `[ci skip]`, manual overrides, or shortcuts.
**Immutable Requirements**:
- Bypass attempts trigger loud failure + mandatory discussion
- Right way is the only way
- Discipline through understanding, not enforcement
- All exceptions require Trinity consensus + documented rationale
**Validation**:
- Pre-commit: Blocks `--no-verify` attempts
- CI: Blocks `[ci skip]` tags
- Operational: Bypass attempts logged + escalated
**Why Sacred**: Bypass culture is a slippery slope. One exception becomes precedent. Discipline requires saying "no" to shortcuts.

---
### 7. IRL-First Approach
**Principle**: Learn principles manually. Practice with feedback. Validate understanding. Introduce automation. Maintain human oversight.
**Immutable Requirements**:
- New operators learn by doing, not by reading
- Manual execution before automation
- Feedback loops validate understanding
- Automation introduced only after mastery
- Human confirmation gates remain for critical operations
**Validation**:
- Onboarding: New operators execute runbooks manually
- Feedback: Post-action review + lessons learned
- Mastery: Operator can execute at 3 AM without assistance
- Automation: Only then introduce tooling
**Why Sacred**: Understanding is the foundation of discipline. Blind automation creates fragility.

---
### 8. Hellodeolu v7 Alignment
**Principle**: All repos target v7: Autonomous Discipline.
**Immutable Requirements**:
- Complete integration of all pillars, agents, and ministries
- Human-centered confirmation gates for all critical operations
- Explicit audit trails via git commits and structured logging
- Junior-deployable runbooks with clear remediation paths
- RTO <15 minutes validated across all recovery scenarios
- Maturity Level declared in all scripts/playbooks (v9.5+ = production-grade)
**Validation**:
- Script headers declare maturity level
- CI validates maturity level requirements
- Operational: RTO validated in production
**Why Sacred**: Hellodeolu v7 is the target state. Everything else is scaffolding.

**Changelog (Consensus Date: 2026-02-06)**:
- Migrated SSOT from v6 (Holistic) to v7 (Autonomous).
- Removed static USG-3P rule count limits (≤10) in favor of hardware-appropriate minimalism.
- Consensus reached by Trinity Council for Fortress-Velocity Phase -1.

---
## Enforcement Mechanisms
### Pre-Commit Validation (Local)
Every repo includes pre-commit hooks that validate:
```bash
# 1. No cleartext secrets
# 2. Bash headers complete (Agent, Ministry, Maturity Level)
# 3. Python type safety (mypy --strict)
# 4. Linting (ruff, shellcheck, shfmt)
# 5. Security scans (bandit)
# 6. No bypass attempts (--no-verify, [ci skip])
```
**Outcome**: 80% of CI failures caught locally before push.
### CI/CD Validation (Remote)
Every repo includes CI gates that validate:
```bash
# 1. All linters PASS
# 2. Tests PASS + coverage ≥80%
# 3. Security scans clean
# 4. Documentation updated
# 5. Seven Pillars demonstrated
# 6. No bypass attempts
```
**Outcome**: Only production-grade code merges to main.
### Operational Validation (Runtime)
Every deployment includes validation that confirms:
```bash
# 1. Carter phase: Identity provisioned
# 2. Bauer phase: Pre-flight checks pass
# 3. Beale phase: Hardening applied + validated
# 4. Whitaker phase: Breach simulation passes
# 5. RTO <15 minutes achieved
# 6. Audit trail complete
```
**Outcome**: Only validated deployments reach production.

---
## Trinity Execution Order (Immutable)
All RylanLabs operations follow this sequence:
### Phase 1: Carter (Identity)
- Verify SSH keys in place
- Confirm user/group permissions
- Validate sudo rules
- Confirm vault secrets available
- **Output**: Identity audit trail
### Phase 2: Bauer (Verification)
- Run pre-flight validation checks
- Verify all preconditions met
- Generate audit log entry
- Present human confirmation gate
- **Output**: Verification report
### Phase 3: Beale (Hardening)
- Apply security hardening rules
- Run post-deployment validation
- Execute red-team simulation (optional)
- Confirm fortress integrity
- **Output**: Hardening validation report
### Phase 4: Whitaker (Offensive Validation)
- Execute breach simulation
- Validate all defenses hold
- Confirm anomaly detection active
- Document fortress health
- **Output**: Offensive validation report
### Phase 5: Human Confirmation Gate
- Operator reviews all four phases
- Explicit `[y/N]` confirmation required
- No automatic execution
- Audit trail records decision
- **Output**: Operator signature + timestamp
### Phase 6: Execution
- Deploy with full audit trail
- Monitor for anomalies
- Capture all output
- Log success/failure
- **Output**: Deployment log
### Phase 7: Post-Mortem
- Review audit trail
- Document lessons learned
- Update runbooks if needed
- Commit changes to git
- **Output**: Incident review + git commits
**Why This Order Matters**: Carter establishes who can act. Bauer verifies what they attempt. Beale hardens against breach. Whitaker proves defenses work. Skip any phase and the fortress is incomplete.

---
## Ministry Alignment Across Organization
### Ministry: bootstrap (Carter)
**Responsibility**: Identity provisioning and authentication
**Repos Involved**:
- rylanlabs-private-vault
- rylan-inventory
- rylan-samba-ad (future)
- rylan-freeradius (future)
**Validation**:
- Carter validator scripts
- Pre-commit: No cleartext secrets
- CI: SSH key format validation
- Operational: Identity provisioning audit trail
**RTO Target**: <5 minutes (identity recovery)

---
### Ministry: verification (Bauer)
**Responsibility**: Compliance scanning, audit logging, pre-flight validation
**Repos Involved**:
- rylan-homelab-iac
- rylan-canon-library
- All repos (pre-commit gates)
**Validation**:
- Bauer validator scripts
- Pre-commit: All linters PASS
- CI: Compliance gates pass
- Operational: Audit trail complete
**RTO Target**: <3 minutes (verification recovery)

---
### Ministry: hardening (Beale)
**Responsibility**: Security hardening, service isolation, IDS/IPS
**Repos Involved**:
- rylan-homelab-iac
- rylan-unifi-case-study (archived)
- Future: rylan-freepbx, rylan-osticket
**Validation**:
- Beale validator scripts (beale-harden.sh)
- Pre-deploy: Fortress configuration validated
- Post-deploy: Breach simulation passes
- Operational: Anomaly detection active
**RTO Target**: <12 minutes (hardening recovery)

---
### Ministry: detection (Whitaker)
**Responsibility**: Breach detection, incident response, red-team validation
**Repos Involved**:
- rylan-homelab-iac (defense-tests.sh)
- rylan-monitoring (future)
- rylan-osticket (future)
**Validation**:
- Whitaker validator scripts (simulate-breach.sh)
- Pre-deploy: Breach simulation dry-run
- Post-deploy: Full breach simulation
- Operational: Continuous anomaly detection
**RTO Target**: <15 minutes (full recovery)

---
## Sacred Artifacts (Minimal Set)
### 1. rylanlabs-private-vault/
**Purpose**: All credentials (SSH keys, tokens, vault passwords)
**Sacred Because**:
- Zero trust foundation — without protected secrets, identity layer collapses
- Never committed to git
- Encrypted at rest
- Audit trail for all access
**Validation**:
- Pre-commit: Blocks any secret commits
- CI: Validates vault structure
- Operational: Access logged + audited

---
### 2. rylan-inventory/device-manifest.yml
**Purpose**: Complete device catalogue + metadata
**Sacred Because**:
- Single source of truth — defines "what exists" before any action
- Prevents drift — inventory vs. reality validated continuously
- Enables rollback — know exactly what should be deployed
**Validation**:
- Pre-commit: YAML syntax valid
- CI: Device manifest schema validated
- Operational: Inventory vs. reality reconciliation

---
### 3. rylan-homelab-iac/playbooks/site.yml
**Purpose**: One-command fortress apply + check mode
**Sacred Because**:
- Idempotent execution — proves desired state enforcement
- Check mode enables verification without risk
- Single entry point — no ad-hoc commands
- Audit trail for all changes
**Validation**:
- Pre-deploy: `ansible-playbook site.yml --check` passes
- Post-deploy: `ansible-playbook site.yml` idempotent
- Operational: All changes via site.yml only

---
### 4. rylan-homelab-iac/scripts/defense-tests.sh
**Purpose**: VLAN isolation + breach simulation verification
**Sacred Because**:
- Proves defenses hold under attack — proactive armor
- Validates Whitaker layer
- Confirms fortress integrity before production release
- Executable proof vs. theoretical design
**Validation**:
- Pre-deploy: Dry-run mode validates test logic
- Post-deploy: Full execution confirms defenses
- Operational: Continuous breach simulation

---
### 5. rylan-homelab-iac/backups/latest-config.json
**Purpose**: Latest UniFi controller backup
**Sacred Because**:
- Guarantees resurrection — rollback path always exists
- <15 min RTO validated
- Immutable copy (versioned + timestamped)
- Reversibility pillar enforced
**Validation**:
- Pre-deploy: Backup integrity verified
- Post-deploy: Backup created + validated
- Operational: Backup tested quarterly

---
### 6. rylan-canon-library/docs/
**Purpose**: All principles + glue documentation
**Sacred Because**:
- Eternal source of truth — lessons and standards preserved
- Single reference for all repos
- Prevents doctrine drift
- Junior-at-3-AM proof
**Validation**:
- Pre-commit: Documentation syntax valid
- CI: All links valid, no broken references
- Operational: Documentation reviewed quarterly

---
## Junior-at-3-AM Validation Checklist
When called to restore the fortress at 3 AM, confirm:
```bash
# 1. Are all 6 sacred artifacts present?
[ -d rylanlabs-private-vault ] && echo "✓ Vault present"
[ -f rylan-inventory/device-manifest.yml ] && echo "✓ Inventory present"
[ -f rylan-homelab-iac/playbooks/site.yml ] && echo "✓ Site playbook present"
[ -f rylan-homelab-iac/scripts/defense-tests.sh ] && echo "✓ Defense tests present"
[ -f rylan-homelab-iac/backups/latest-config.json ] && echo "✓ Backup present"
[ -d rylan-canon-library/docs ] && echo "✓ Documentation present"
# 2. Does site.yml --check pass?
ansible-playbook site.yml --check && echo "✓ Playbook check passes"
# 3. Does defense-tests.sh pass?
scripts/defense-tests.sh && echo "✓ Defense tests pass"
# 4. Is audit trail complete?
git log --oneline | head -5 && echo "✓ Audit trail present"
# 5. Can you execute this at 3 AM without help?
# If yes → fortress is healthy
# If no → review documentation + practice manually
```
**If all 5 checks pass**: Fortress is operational. Proceed with confidence.
**If any check fails**: Stop. Review documentation. Escalate to Trinity.

---
## How to Use Eternal Glue
### For New Repos
1. **Inherit these principles** — Copy them into CONTRIBUTING.md
2. **Implement validation gates** — Pre-commit, CI, operational
3. **Declare Trinity alignment** — Which agent(s) does this repo serve?
4. **Validate RTO** — Prove <15 minutes, don't assume
5. **Document in canon** — Add lessons learned to eternal-glue.md
### For Existing Repos
1. **Audit against principles** — Identify gaps
2. **Add validation gates** — Pre-commit, CI, post-deploy
3. **Implement Trinity order** — Refactor execution sequence
4. **Update documentation** — Runbooks must be junior-deployable
5. **Declare maturity level** — Be honest about current state
### For Operational Decisions
1. **No bypass culture** — If tempted to bypass, redesign instead
2. **IRL-first approach** — Learn manually, then automate
3. **Human gates** — All critical operations require confirmation
4. **Audit trails** — Every action traceable to git commit
5. **RTO validation** — Prove it works, don't assume

---
## Change Control (Trinity Consensus Required)
**To modify any principle**:
1. **Propose change** — Document rationale + impact
2. **Carter reviews** — Identity implications?
3. **Bauer reviews** — Verification implications?
4. **Beale reviews** — Hardening implications?
5. **All three approve** → Change accepted
6. **Document in eternal-glue.md** → Commit to canon
**No unilateral changes. The Trinity endures.**

---
## The Eternal Glue Promise
**Problem**: Organizations accumulate technical debt, inconsistent standards, and cultural drift.
**Solution**: Eternal glue — immutable principles extracted from battle-tested experience.
**How It Works**:
- Principles are sacred (Trinity consensus required for changes)
- Artifacts are minimal (6 sacred paths, no bloat)
- Validation is automatic (pre-commit, CI, operational)
- Culture is enforced (no bypass, IRL-first, human gates)
**The Result**:
- New repos inherit discipline from day one
- Mistakes are prevented, not repeated
- Standards scale across organization
- Junior operators can execute at 3 AM
**The Promise**:
- Production-grade code everywhere
- Zero drift, zero bypass
- Understanding over blind compliance
- Sustainable discipline through education
- RTO <15 minutes validated
- Fortress integrity guaranteed

---
## Sacred Oath
Every RylanLabs engineer commits to:
> I understand the Seven Pillars.
> I respect the Trinity execution order.
> I will not bypass validation gates.
> I will learn manually before automating.
> I will maintain audit trails.
> I will prove RTO before production.
> I will preserve the fortress.
>
> The Trinity endures.
> The fortress demands discipline.
> No shortcuts. No exceptions.

---
## Appendix: Quick Reference
### Trinity Agents
| Agent | Ministry | Responsibility | Validation |
|-------|----------|---|---|
| **Carter** | bootstrap | Identity provisioning | SSH keys, users, groups, sudo |
| **Bauer** | verification | Compliance & audit | Pre-flight checks, audit trails |
| **Beale** | hardening | Security enforcement | Firewall, SSH, service isolation |
| **Whitaker** | detection | Breach validation | Breach simulation, anomaly detection |
### Seven Pillars Checklist
- [ ] **Idempotency** — Safe to run multiple times
- [ ] **Error Handling** — Fail fast, fail loud, context provided
- [ ] **Audit Logging** — Timestamped, traceable to git
- [ ] **Documentation Clarity** — Junior-deployable at 3 AM
- [ ] **Validation** — Pre/post checks, security scans
- [ ] **Reversibility** — Rollback path tested + validated
- [ ] **Observability** — Real-time visibility into state
### Ministry Responsibilities
| Ministry | Purpose | Repos | RTO |
|----------|---------|-------|-----|
| bootstrap | Identity | vault, inventory, samba-ad | <5 min |
| verification | Compliance | homelab-iac, canon | <3 min |
| hardening | Security | homelab-iac, monitoring | <12 min |
| detection | Incident response | monitoring, osticket | <15 min |
### Maturity Levels (Homelab Current: v4-6)
- **v1-v3**: Basic awareness (scripts work)
- **v4-v6**: Systematic discipline (tools enforce) ← Current homelab target
- **v7-v9**: Holistic integration (agents coordinate — future)
- **v9.5+**: Production-grade (zero bypass, human gates, audit trails — aspirational)

---
## Related Documents
- [seven-pillars.md](seven-pillars.md) — Core principles
- [hellodeolu-v6.md](hellodeolu-v6.md) — Discipline evolution
- [no-bypass-culture.md](no-bypass-culture.md) — Cultural implementation
- [irl-first-approach.md](irl-first-approach.md) — Learning methodology
- [bash-discipline.md](bash-discipline.md) — Shell scripting standards
- [ansible-discipline.md](ansible-discipline.md) — Production-grade Ansible standards
- [RYLANLABS-INSTRUCTION-SET.md](../RYLANLABS-INSTRUCTION-SET.md) — Operational standards

---
## Final Word
The **Eternal Glue** is not a document. It is a **commitment**.
Every repo that inherits these principles commits to:
- Production-grade code
- Zero drift, zero bypass
- Understanding over blind compliance
- Sustainable discipline through education
The **6 sacred artifacts** are load-bearing. Touch them only with understanding.
The **Trinity execution order** is immutable. Skip any phase and the fortress is incomplete.
The **Seven Pillars** are non-negotiable. Remove one and the fortress crumbles.
The **No Bypass Culture** is absolute. One exception becomes precedent. Discipline requires saying "no" to shortcuts.

---
## The Fortress Endures
**Carter** authenticates identity.
**Bauer** verifies compliance.
**Beale** hardens execution.
**Whitaker** validates defenses.
The **Trinity** endures.
The **fortress** demands discipline.
**No shortcuts. No exceptions.**

---
**Document Status**: 🔒 Locked
**Last Updated**: December 20, 2025
**Next Review**: June 20, 2026 (6-month cycle)
**Change Control**: Trinity consensus required
**The Eternal Glue is eternal. The fortress is eternal. Discipline is eternal.**
