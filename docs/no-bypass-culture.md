```markdown
# No Bypass Culture

> Canonical principle — RylanLabs standard  
> Extracted from: rylan-unifi-case-study v5.2.0-production-archive  
> Source: https://github.com/RylanLabs/rylan-unifi-case-study  
> Date: 19/12/2025   
> Agent: Bauer (Verification) | Domain: Audit

---

## Principle

**No bypasses. Ever.**

Shortcuts, `--no-verify`, `[ci skip]`, manual overrides, or "just this once" exceptions are forbidden.

**Why**: Every bypass creates debt. Debt compounds. One bypass teaches the team that rules are optional. Optional rules become ignored rules. Ignored rules become drift. Drift becomes breach.

Hellodeolu v6 outcome: **Pre-commit 100% green** — achieved only when bypass is impossible.

---

## Core Tenets (Locked Forever)

### 1. Make the Right Way the Only Way
- Gatekeeper blocks merge on violation.
- No flag to disable critical checks.
- Local pre-commit mirrors remote CI exactly.

### 2. Fail Loudly on Attempted Bypass
- `git commit --no-verify` → blocked by alias or hook.
- Attempt → loud warning + exit 1.
- Message: "Bypass denied. Fix the issue or open discussion."

### 3. Document Why, Not Just What
- Every rule has rationale in docs/.
- Commit messages explain context + impact.
- Juniors learn *why* compliance matters.

### 4. Provide Accountable Escape Hatches (Rare)
- Emergency only.
- Requires:
  - Issue filed
  - Approval from 2 agents
  - Temporary branch
  - Auto-revert after fix
- Never permanent.

### 5. Lead by Example
- Maintainers never bypass.
- Violations → public correction, never silent merge.

---

## Anti-Patterns (Never Tolerate)

| Anti-Pattern               | Symptom                          | Consequence                     |
|----------------------------|----------------------------------|---------------------------------|
| The "Just This Once"       | Single `--no-verify` commit      | Teaches rules are negotiable    |
| The Hidden Override        | Undocumented flag to skip checks | Drift accumulates silently      |
| The Blame Shift            | "CI is flaky" excuse             | Standards erode                 |
| The Hero Merge             | Maintainer bypasses for "speed"  | Juniors copy behaviour          |

---

## Building No Bypass Culture

1. **Clarity**  
   Document every rule + rationale.

2. **Friction for Wrong Path**  
   Make bypass impossible or painful.

3. **Ease for Right Path**  
   Auto-fix where safe (ruff --fix, pre-commit).

4. **Education**  
   Onboarding includes "why no bypass".

5. **Accountability**  
   Public dashboard of violations (zero tolerance).

6. **Iteration**  
   If rule causes constant pain → fix rule, never bypass.

---

## Enforcement in Fortress

- `.githooks/pre-commit` → exact CI mirror.
- Gatekeeper → rejects bypass attempts.
- Commit message canon → requires rationale.
- Compliance metric → drops on bypass.

---

**Outcome**:  
Team internalises discipline. Automation becomes trustworthy. Fortress remains eternal.

**Trinity Alignment**:  
- Bauer verifies no exceptions.  
- Beale hardens the process.  
- Carter authenticates intent.

No bypasses. No exceptions. No debt.
