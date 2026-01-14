# Markdown Discipline — RylanLabs Canon

> Canonical standard — Production-grade documentation
> Date: 2026-01-13
> Guardian: Bauer
> Author: rylanlab canonical
> Version: v2.0.0

**Status**: ✅ **PRODUCTION** — Bauer Ministry Canonical | Zero Drift | Aligned Formatting

---

## Purpose

Markdown Discipline ensures all RylanLabs documentation is readable, professional, and consistent. It enforces the **Bauer ministry** — verification of intent and adherence to standards.

**Objectives**:

- Prevent visual clutter through strict spacing rules.
- Enable high-velocity document updates (RTO < 15min).
- Ensure junior-at-3-AM readability.
- Automate remediation via pre-commit hooks.

---

## Standards (Non-Negotiable)

### 1. Heading Discipline (MD022/MD036)

- **Rules**: MD022, MD036
- **Requirement**: Surround all headings with exactly one blank line above and below.
- **Syntax**: Use `#` syntax only. Never use bold text as a pseudo-heading.

### 2. Spacing Standards (MD031/MD032/MD012)

- **Rules**: MD012, MD031, MD032
- **Requirement**: Fenced code blocks and lists must be preceded and followed by a blank line.
- **Avoidance**: No multiple consecutive blank lines. Maintain single-line separation for density.

### 3. Table Canon (MD060)

- **Rules**: MD060
- **Requirement**: Use **aligned column style**.
- **Formatting**: Always include a single space on the inner side of each pipe (`| content |`).

### 4. Security & Links (MD040/MD034)

- **Rules**: MD040, MD034
- **Code Fences**: All fenced code blocks **must** specify a language (e.g., ` ```bash `).
- **Links**: No bare URLs. Wrap all URLs in standard markdown syntax `[text](url)`.

---

## Validation & Tooling

### markdownlint

The primary tool for enforcement is `markdownlint`.

- **Audit**: `markdownlint docs/**/*.md`
- **Auto-Fix**: `markdownlint --fix docs/**/*.md`
- **Pre-Commit**: Integrated into `.pre-commit-config.yaml` to block non-compliant commits.

---

## Examples

### ❌ Non-Compliant

```markdown
#Heading
Here is a list:
- Item 1
- Item 2
```

### ✅ Compliant

```markdown
# Heading

Here is a list:

- Item 1
- Item 2
```
