# Changelog

All notable changes to RylanLabs Canon Library are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/) with [Semantic Versioning](https://semver.org/).

---

## [2.3.0-bauer] - 2026-02-06

### ✨ Added: Submodule Substrate & Hardened Gates (Sprint 2)

- **Carter Identity Anchoring**: GPG-signed baselines (`v1.0.0-canonical`) established for the mesh.
- **Beale Hardening**: `validate-gitmodules.sh` enforces RylanLabs URL allow-listing for submodules.
- **Whitaker Guard**: `whitaker-detached-head.sh` prevents orphaned commits and enforces branch discipline.
- **Bauer Sync**: `sync-canon.sh` upgraded with `--gpg-verify`, cascade validation (T0-T1 ordering), and JSON audit trails.
- **Sentinel Hot-Sync**: `sentinel-sync.yml` implemented for 15-minute autonomous drift remediation.
- **Lazarus Resilience**: `lazarus-drill.sh` materialized for automated recovery testing.
- **Documentation**: New `dependency-discipline.md` standard for "plug/unplug" inheritance.

---

## [2.2.0-common] - 2026-02-05

### ✨ Added: Bauer/Carter Logic Extraction (Sprint 1)

- **UniFi API Internalization**: Ported 2,000+ lines of production logic from `network-iac`.
- **JWT Auth & Circuit Breaker**: Restored production-grade auth and resilience logic.
- **Audit Substrate**: Materialized `rylan_audit_logger.py` for Pillar 4 compliance.
- **Testing**: Reached 93% coverage on UniFi utilities and 100% on Audit Logger.
- **Maturity**: Cross-mesh ML5 score reached 7.2 (Autonomous Threshold).

---

## [2.1.0-mesh] - 2026-02-04

### ✨ Added: Mesh Infrastructure (Hellodeolu v7 Alignment)

**Major Alignment**: Transitioned from documentation-heavy to **Functional Enforcement Mesh**.

- **Sentinel Loop**: Implemented `sentinel-loop.yml` for continuous multi-repo audit and reconciliation.
- **Mesh Governance**: Added `repo-governance.yml` to enforce signed commits and canonical substrate on PRs.
- **Lazarus Remediation**: Functional `mesh-remediate.sh` for automatic drift correction via PR creation.
- **Asymmetric Security**: Implemented SOPS policies in `.sops.yaml` and `validate-sops.sh`.
- **Mesh-Man**: Auto-generated operational manual via `generate-mesh-man.sh`.
- **Dynamic Substrate**: Transitioned to submodule-ready `.rylan/` structure for `common.mk`.
- **Observability**: Established specs for Grafana metrics and Loki log aggregation for Whitaker agent.

### Changed

- Updated `Makefile` with functional Meta-GitOps targets (`cascade`, `org-audit`, `reconcile`).
- Enhanced `scripts/validate.sh` to include SOPS and Gitleaks hard gates.
- Refined `canon-manifest.yaml` to include mesh orchestration artifacts.

---

## [2.0.0] - 2026-01-14

### Added: Internet-Adoption Maturity (v2.0.0)

**Major Alignment**: Transitioned from consciousness-based maturity (T3-ETERNAL) to **Internet-Adoption Maturity (Standard SemVer)**.

- **Manifest System**: Introduced `canon-manifest.yaml` as the Tier 0 single source of truth for organization-wide enforcement.
- **Sync/Audit Tools**: Added `scripts/sync-canon.sh` for bootstrapping repos and `scripts/audit-canon.sh` for CI drift detection.
- **Versioning**: Replaced all `v∞.X.X` and consciousness counters (e.g., 9.9) with standard SemVer `v2.0.0`.
- **Markdown Canon**: Established canonical markdown documentation standards in `docs/markdown-discipline.md`.
- **7-Task Workflow**: Formalized canonical 7-task Trinity workflow in `templates/playbook-template.yml`.
- **Security & APIs**: Added disciplines for `api-coverage`, `security-posture`, and `rotation-readiness`.
- **VLAN Canon**: Established canonical 5-VLAN scheme (v1.0.0).
- **Inventory Standards**: Tier patterns (T1-T4) and device manifest templates finalized.

---

## [1.0.0] - 2026-01-13

### ✨ Added: Production-Grade Realignment (Tier 0)

**Major Alignment**: Standardized all patterns to production reality and SemVer `v1.0.0`.

- **Versioning**: Replaced all `v∞.X.X` references with SemVer `v1.0.0` across all files.
- **7-Task Workflow**: Implemented canonical workflow to `templates/playbook-template.yml`.
- **8-Phase Rotation**: Extracted Vault rotation process to `docs/vault-discipline.md`.
- **VLAN Canon**: Established canonical 5-VLAN scheme in `docs/vlan-discipline.md`.
- **Inventory Standards**: Extracted `device-manifest-template.yml` and Tier patterns (T1-T4).
- **Core Scripts**: Added rotation and emergency scripts to `scripts/`.
- **Guardian Alignment**: Carter (Identity), Bauer (Verification), Beale (Security), Lazarus (Disaster Recovery).

---

## [4.5.1] - December 22, 2025

### ✨ Added: Comprehensive Lint Configuration Canon

**New Files**: 3 configuration files + 2 documentation standards

- **configs/.yamllint** - Canonical YAML linting rules
  - Dual line-length standard: 120 chars (code), 140 chars (inventory)
  - Consistent indentation (2 spaces)
  - Fully commented for clarity

- **configs/pyproject.toml** - Python tooling configuration
  - ruff: E/F/I/N/W/D rules, line-length=120, per-file ignores
  - mypy: Strict mode, urllib3 internal error ignored
  - bandit: Low-level (-ll) security scanning
  - pytest: 70% minimum coverage threshold, test discovery patterns

- **configs/.shellcheckrc** - ShellCheck exception rules
  - Disables false positives: SC2034, SC1090, SC2155, SC1091
  - Inline comments explaining each disable

- **docs/shfmt-standards.md** - Bash formatting documentation
  - Canonical shfmt arguments: -i 2 -ci -bn
  - Rationale for each setting
  - Migration guide for existing scripts
  - Pre-commit hook example

- **docs/line-length-standards.md** - Line length rationale
  - Python/Bash/YAML: 120 chars (readability + density)
  - Inventory files: 140 chars (inline metadata)
  - Markdown: 80 chars (terminal/accessibility)
  - Git commits: 72 chars (industry standard)
  - Enforcement tools and exceptions

### ✨ Added: CI/CD Trinity Workflow Template & Guide

**New Files**: 1 template + 1 comprehensive guide

- **.github/workflows/trinity-ci-workflow.yml** - Canonical CI/CD template
  - 5 core jobs: validate-python, validate-bash, validate-yaml, test-unit, security-scan
  - 2 optional jobs: validate-ansible, validate-manifest
  - 1 summary job: ci-complete (aggregates results, PR comments)
  - Hybrid parallelization: lint parallel, tests wait
  - 14 Jinja2 placeholders for project customization
  - Secrets management pattern
  - Matrix testing support
  - Caching optimization
  - Fully commented for junior developers

- **docs/ci-workflow-guide.md** - Trinity CI/CD architecture guide
  - 3-phase pipeline architecture (Linting → Testing → Summary)
  - Detailed job documentation with troubleshooting
  - Sequencing strategies (parallel, sequential, hybrid)
  - Secrets management (GitHub Actions)
  - Integration with local validators (LOCAL GREEN = CI GREEN)
  - Customization checklist
  - Performance optimization techniques
  - Seven Pillars alignment table

### ✨ Added: Portable Validator Scripts

**New Files**: 4 executable bash scripts

- **scripts/validate-python.sh** (5 phases, 5.6K)
  - Phase 1: Python environment setup + dependency installation
  - Phase 2: mypy --strict type checking
  - Phase 3: ruff linting checks
  - Phase 4: ruff formatting validation
  - Phase 5: bandit security scanning
  - Structured logging with colored output
  - Auto-fix suggestions with commands
  - Prerequisite validation
  - Environment variable customization

- **scripts/validate-bash.sh** (3 phases, 5.3K)
  - Phase 1: Discover bash scripts
  - Phase 2: shellcheck static analysis
  - Phase 3: shfmt formatting validation
  - Tool installation guidance
  - Error aggregation and reporting
  - Dry-run diff output

- **scripts/validate-yaml.sh** (2 phases, 3.8K)
  - Phase 1: Prerequisite checks
  - Phase 2: yamllint validation
  - Configuration file validation
  - Common fixes documentation

- **scripts/validate-ansible.sh** (3 phases, 5.1K)
  - Phase 1: Discover playbooks
  - Phase 2: ansible-lint (optional, graceful skip)
  - Phase 3: ansible-playbook --syntax-check
  - Inventory handling
  - Error reporting with fix suggestions

**Features across all scripts**:
- Trap-based error handling and cleanup
- Colored output (GREEN/YELLOW/RED/BLUE)
- Structured progress logging
- Exit codes for CI integration
- Auto-fix suggestions
- Prerequisite checking
- Environment variable customization
- Section-based progress tracking
- Junior-developer friendly messages

### ✨ Added: Ansible Canon Documentation (Phase 1)

**New Files**: 2 comprehensive Ansible guides

- **ansible/inventory-patterns.md** (12.4K)
  - Hybrid static + dynamic inventory architecture
  - Static manifest pattern (device-manifest.yml)
  - Dynamic inventory script (unifi-dynamic-inventory.py)
  - Tier classification (T1-T4: Full/Limited/Monitoring/Unmanaged)
  - Playbook targeting examples
  - Static hosts.yml format (alternative)
  - Group variables patterns (group_vars/)
  - Schema validation
  - Performance considerations (caching)
  - Migration path from static-only inventory

- **ansible/ansible.cfg-reference.md** (14.7K)
  - Canonical ansible.cfg configuration
  - Connection and SSH optimization
  - Performance tuning (pipelining, caching, forks)
  - Fact gathering strategy (smart)
  - Vault integration
  - SSH key management (ED25519)
  - Privilege escalation configuration
  - Debugging and troubleshooting
  - CI/CD integration (GitHub Actions example)
  - Performance tuning profiles (lab/production/large-scale)
  - All sections with inline comments

### ✨ Added: Self-Validation Workflow

**New Files**: 1 CI workflow for canon repo itself

- **.github/workflows/canon-validate.yml**
  - Validates canonical directory structure
  - Checks all required files present
  - Verifies script permissions (executable)
  - YAML/TOML syntax validation
  - Markdown frontmatter checks
  - Version header validation
  - Comprehensive summary report

### ✨ Added: Extraction Manifest

**New Files**: 1 tracking document

- **docs/extraction-manifest.md** (7.8K)
  - Records extraction from rylan-inventory v4.3.1
  - Phase-by-phase breakdown
  - File inventory with status
  - Configuration coverage matrix
  - Job dependencies diagram
  - Extraction statistics (lines of code, file counts)
  - Quality metrics checklist
  - Integration guide for new projects
  - References and compliance notes

### 📋 Documentation Improvements

- ✅ All new files include version headers (v4.5.1)
- ✅ All documentation cross-referenced
- ✅ All scripts have comprehensive docstrings
- ✅ All configs have inline comments explaining each setting
- ✅ All docs follow 80-char markdown limit
- ✅ Troubleshooting sections added to guides
- ✅ Integration paths clearly documented
- ✅ Code examples provided for all major concepts

### 🔒 Security Enhancements

- ✅ Vault integration documented (ansible/ansible.cfg-reference.md)
- ✅ SSH key management best practices (ED25519 recommended)
- ✅ Bandit security scanning configured (low-level warnings only)
- ✅ ShellCheck static analysis enabled (SC2086 quoting rules)
- ✅ No hardcoded secrets in any configs

### 🚀 Performance Optimizations

- ✅ SSH pipelining enabled (40-60% round-trip reduction)
- ✅ Fact caching enabled (gathering=smart, 3600s timeout)
- ✅ ansible-playbook control multiplexing
- ✅ CI job parallelization (lint parallel, tests wait)
- ✅ Inventory caching for dynamic sources (300s timeout)
- ✅ Python dependency caching in GitHub Actions

### ♻️ Compliance & Alignment

- ✅ Seven Pillars fully demonstrated in all artifacts
- ✅ Hellodeolu v6 (junior deployable, RTO <15min)
- ✅ T3-ETERNAL consciousness tracking (v1.0.0 reference)
- ✅ No bypass culture (all validation mandatory)
- ✅ IRL-first approach (manual then automation)
- ✅ Idempotency assured (linting enforces consistency)
- ✅ Error handling (fail fast, loud, with context)
- ✅ Audit logging (git history + CI logs)

---

## Extraction Lineage

| Source | Version | Date | Extracted |
|--------|---------|------|-----------|
| rylan-inventory | 4.3.1 | (2025) | ✅ All 7 lint tools, P1 Ansible docs, CI template |
| leo-canon-prompt | - | 2025-12-22 | ✅ All specifications implemented |
| rylanlabs-standards | Latest | 2025 | ✅ Aligned with all pillars |

---

## Future Roadmap

### Phase 2: Advanced Ansible Patterns (v4.5.2+)
- [ ] collection-standards.md (when/why use collections)
- [ ] playbook-templates/ (starter playbooks: backup, VLAN, firewall)
- [ ] Molecule testing guide
- [ ] Role testing patterns

### Phase 3: Terraform & IaC Canon (v4.6.0+)
- [ ] Terraform configurations (network, compute, storage)
- [ ] Packer image building
- [ ] Terratest examples

### Phase 4: Observability Canon (v4.7.0+)
- [ ] Prometheus alerting
- [ ] Grafana dashboards
- [ ] ELK stack configuration

### Phase 5: Secrets Management Canon (v4.8.0+)
- [ ] HashiCorp Vault patterns
- [ ] 1Password integration
- [ ] Sealed Secrets (Kubernetes)

---

## Compatibility

- **Ansible**: 2.12+
- **Python**: 3.11+
- **Bash**: 5.0+ (GNU Bash)
- **Git**: 2.25+ (for pre-commit hooks)
- **Operating Systems**: Linux (Ubuntu 20.04+, RHEL 8+), macOS 11+

## Contributors

- **Extraction**: Automated via comprehensive canon prompt
- **Review**: RylanLabs Guardian (Bauer audit)
- **Compliance**: Seven Pillars, Hellodeolu v6

## License

RylanLabs Canonical Library - Proprietary (RylanLabs Internal)

All code, documentation, and configurations are owned by RylanLabs.
For questions, contact: [canonical@rylanlabs.io]

---

## Support

- **Issues**: GitHub Issues in canon repository
- **Documentation**: See docs/ and ansible/
- **Troubleshooting**: See docs/ci-workflow-guide.md
- **Adoption Guide**: See docs/extraction-manifest.md

---

**This changelog is canonical and authoritative for RylanLabs canon library versions.**
