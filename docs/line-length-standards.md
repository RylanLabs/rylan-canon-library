# Line Length Standards

> RylanLabs Canonical Character Limits  
> Version: 4.5.1  
> Guardian: Bauer (Auditor)  
> Ministry: Configuration Management

---

## Overview

Different file types have different line length constraints based on content type and readability trade-offs.

## Standard Limits

| File Type | Max Chars | Guardian | Rationale |
|-----------|-----------|----------|-----------|
| **Python code** | 120 | Bauer | Balance density with readability; mypy + ruff enforce |
| **Bash scripts** | 120 | Carter | Readability; prevents deeply nested conditionals |
| **YAML (code)** | 120 | Bauer | Playbooks, workflows, configs |
| **YAML (inventory)** | 140 | Bauer | Device manifests need horizontal space for metadata |
| **Markdown** | 80 | Beale | Documentation; terminal pagers assume 80 chars |
| **Git commits** | 72 (title), unlimited (body) | Bauer | Git standard; titles fit in terminal logs |

---

## Rationale by File Type

### 120 Chars: Code Files (Python, Bash, YAML)

**Why 120?**

- **Readability**: Fits in full-screen IDE (13" laptop, 16:9 aspect ratio)
- **Density**: Improves over default 80 (saves ~33% vertical lines)
- **Debugging**: Error messages + line numbers still readable
- **CI/CD**: Log aggregators handle 120 char lines gracefully
- **Consistency**: Single standard across Python, Bash, YAML

**Example**:
```python
# ✓ GOOD: 120 char limit is acceptable
def validate_firewall_rules(rules: list[dict], max_rules: int = 10) -> bool:
    """Validate firewall rules against Hellodeolu v6 constraint."""
    if len(rules) > max_rules:
        raise ValueError(f"Rule count {len(rules)} exceeds limit {max_rules}")
    return True

# ✗ BAD: Exceeds 120 chars (135 chars)
def validate_firewall_rules(rules: list[dict], max_rules: int = 10) -> bool:
    """Validate firewall rules against Hellodeolu v6 constraint of maximum allowed rules."""
    if len(rules) > max_rules:
        raise ValueError(f"Firewall rule count {len(rules)} exceeds configured limit of {max_rules}")
    return True
```

---

### 140 Chars: Inventory Files (YAML)

**Why 140 for inventory?**

Device manifests carry inline metadata that needs horizontal space:

```yaml
# ✓ GOOD: 140 char limit allows full device metadata inline
devices:
  - hostname: usg-3p-01
    device_role: gateway
    tier: T1
    ansible_host: 192.168.1.1
    serial_number: "ABCD1234"
    firmware_version: "2.1.3"
    vlan_management_id: 100
    dns_servers: ["1.1.1.1", "8.8.8.8"]
    snmp_community: "public"
    monitoring_enabled: true
    backup_schedule: "0 2 * * *"  # Total: ~130 chars

# ✗ UGLY: 120 char limit forces line wrapping
devices:
  - hostname: usg-3p-01
    device_role: gateway
    tier: T1
    ansible_host: 192.168.1.1
    serial_number: "ABCD1234"
    firmware_version: "2.1.3"
    vlan_management_id: 100
    dns_servers:
      - "1.1.1.1"
      - "8.8.8.8"
    snmp_community: "public"
    monitoring_enabled: true
    backup_schedule: "0 2 * * *"  # Vertical bloat
```

**Override in CI/CD**:
```bash
# yamllint with inventory-specific rules
yamllint -d "{extends: default, rules: {line-length: {max: 140}}}" inventory/hosts.yml
```

---

### 80 Chars: Markdown Documentation

**Why 80?**

- **Terminal pagers**: `less`, `man` pages assume 80 cols
- **Git diffs**: Preserve readability in terminal + GitHub UI
- **Mobile**: Documentation readable on smaller screens
- **Accessibility**: Screen readers work better with narrower text

**Exception**: Code blocks and tables can exceed 80 if necessary

```markdown
# ✓ GOOD: Documentation wrapped at 80 chars
This is a documentation paragraph that explains the concept clearly
while maintaining readability on terminal pagers and mobile devices.

# ✗ BAD: Exceeds 80 chars (95 chars)
This is a documentation paragraph that tries to fit everything on one very long line but it exceeds the 80 character limit.

# ✓ EXCEPTION: Code blocks and tables can exceed
| Device | IP Address | Role | Status |
|--------|-----------|------|--------|
| usg-3p-01 | 192.168.1.1 | gateway | active |
```

---

### 72 Chars: Git Commit Messages

**Why 72?**

- **Git log --oneline**: Wraps at 80 chars on GitHub UI (72 + decoration)
- **Email**: Mailing lists wrap at ~72 chars
- **History**: Industry standard since early Git

**Format**:
```
<type>(<scope>): <subject (max 72 chars)>
<blank line>
<body (max 100 chars/line)>
<blank line>
<footer>
```

**Example**:
```
feat(ansible): add hybrid inventory with dynamic discovery

Implements dynamic inventory via UniFi Integration API v1 alongside
static device-manifest.yml. Merges runtime state (IP, status,
firmware) with static tier classification (T1-T4).

Resolves: #42
Reviewed-by: @reviewer
```

---

## Enforcement Tools

### Linting Configurations

All tools enforce these standards automatically:

| Tool | File | Config |
|------|------|--------|
| **ruff** | `*.py` | `configs/pyproject.toml` (`line-length = 120`) |
| **yamllint** | `*.yml`, `*.yaml` | `configs/.yamllint` (120 code, 140 inventory) |
| **markdownlint** | `*.md` | (to be added) line-length: 80 |
| **shellcheck** | `*.sh` | (implicit, via script length checks) |

### Local Validation

```bash
# Run all validators
bash scripts/validate-python.sh
bash scripts/validate-yaml.sh
bash scripts/validate-bash.sh
```

### CI/CD Validation

```yaml
# .github/workflows/trinity-ci.yml automatically enforces
validate-python:
  run: mypy --strict && ruff check && ruff format --check
  # Fails if ruff finds lines > 120

validate-yaml:
  run: yamllint .
  # Fails if any YAML exceeds limits
```

---

## Migration & Transition

### Existing Code Over Limits

If inheriting code with longer lines:

1. **Do not** retroactively reformat entire files (noisy git history)
2. **Do** enforce new code:
   - Pre-commit hooks reject new lines over limits
   - Code review: request line shortening for new contributions
3. **Gradual**: Refactor over time as code evolves

**Example pre-commit hook**:
```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit: Reject new lines over 120 chars

files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(py|sh|yml|yaml)$')
over_limit=0

for file in $files; do
  lines=$(git diff --cached "$file" | grep '^+' | awk 'length > 121 {print NR": "length" chars"}')
  if [[ -n "$lines" ]]; then
    echo "ERROR: $file has lines exceeding 120 chars:"
    echo "$lines"
    over_limit=1
  fi
done

exit $over_limit
```

---

## Exceptions & Rationale

### When to Exceed Limits

1. **URLs in documentation**:
   ```markdown
   See [RylanLabs Architecture](https://docs.rylanlabs.io/architecture/trinity-implementation-guide-for-network-infrastructure)
   # URL can't be split; link exceeds 80 chars
   ```

2. **Auto-generated code**:
   ```python
   # This file is auto-generated by tool-x
   # DO NOT MANUALLY EDIT
   # Line length constraints disabled for generated code
   ```

3. **Data tables**:
   ```markdown
   | Device | IP | Role | Status | Serial | Firmware | Uptime |
   |--------|----|----|--------|--------|----------|--------|
   ```

**Always document exceptions**:
```python
# noqa: E501  (line too long, URL can't be shortened)
url = "https://example.com/very-long-api-endpoint-that-cannot-be-split"
```

---

## References

- [Ruff Configuration](configs/pyproject.toml)
- [yamllint Configuration](configs/.yamllint)
- [Bash Discipline](bash-discipline.md)
- [Hellodeolu v6](hellodeolu-v6.md)
