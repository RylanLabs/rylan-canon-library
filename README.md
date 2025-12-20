# RylanLabs Pattern Library

> **Reusable discipline patterns for production-grade infrastructure**

**Status**: 🚧 Content extraction in progress  
**Extracted**: December 19, 2025  
**Source**: [rylan-unifi-case-study v5.2.0-production-archive](https://github.com/RylanLabs/rylan-unifi-case-study)

---

## Purpose

This repository is a **reference library** of reusable patterns, validators, and principles extracted from the production-grade [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study) (344 commits, v5.2.0-production-archive).

**This is NOT a production repository.** It's a template source for future projects, containing:

- **Discipline patterns**: Proven approaches to infrastructure scripting
- **Validators**: Manual validation scripts for code quality
- **Principles**: Seven Pillars, Hellodeolu v6, No Bypass Culture, IRL-First
- **Templates**: Starting points for new repositories and scripts

## What's Included

### 📚 Documentation (`docs/`)
- **Seven Pillars**: Core principles for production infrastructure
- **Hellodeolu v6**: Discipline architecture and framework
- **No Bypass Culture**: Why manual discipline precedes automation
- **IRL-First Approach**: Human validation before automated enforcement
- **Bash Discipline**: Standards for production-grade shell scripting

### ✅ Validators (`validators/`)
Manual validation scripts to run before commits:
- Bash header validation
- Seven Pillars compliance checking
- ShellCheck wrapper with custom rules

### 📋 Templates (`templates/`)
Starting templates for new projects:
- Script templates with proper headers and error handling
- README templates with attribution
- CONTRIBUTING guidelines

### 🔧 Patterns (`patterns/`)
Reusable bash patterns demonstrating best practices:
- Error handling and exit codes
- Audit logging and observability
- Idempotency and state management

## How to Use

This library is designed for **manual reference and extraction**, not as a package or framework:

1. **Browse patterns** in `patterns/` for implementation examples
2. **Copy templates** from `templates/` as starting points
3. **Run validators** from `validators/` manually before commits
4. **Study principles** in `docs/` to understand the "why"

**Philosophy**: Manual discipline before automation. These tools are meant to be run by humans who understand them, not as automated gates (yet).

## Source Attribution

All content extracted from:
- **Repository**: [rylan-unifi-case-study](https://github.com/RylanLabs/rylan-unifi-case-study)
- **Version**: v5.2.0-production-archive
- **Commit count**: 344 commits over production lifecycle
- **Extraction date**: December 19, 2025

The original repository included CI workflows (32 automated checks), Gatekeeper automation, and Trinity agent systems. These are intentionally **not included** here—this library focuses on the underlying patterns and principles, not the enforcement automation.

## Next Steps

1. Extract Seven Pillars documentation from source
2. Extract and adapt validator scripts
3. Create comprehensive script templates
4. Document reusable bash patterns
5. Add usage examples and tutorials

---

**Carter Lab — Identity Systems**  
*"Discipline first, automation later."*
