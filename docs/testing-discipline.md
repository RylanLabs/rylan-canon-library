# Testing Discipline

## Maturity: Level 5 (Autonomous)

## Guardian: Bauer (Verification)

This document outlines the testing architecture for the RylanLabs Mesh Substrate.

### 1. Three Pillars of Mesh Testing

1. Whitaker (Adversarial): Validation scripts that check for misconfiguration, hardcoded paths, and GPG signing.
2. Bauer (Verification): Pytest-based unit and integration tests that verify Makefile targets and script logic.
3. Sentinel (Drift): Continuous automated checking for drift between Tier 0 Canon and satellite implementations.

### 2. Test Suites

#### Unit Tests (Pytest)

Located in `tests/unit/`. These tests verify:

* Makefile target execution.
* Correct JSONL formatting of audit logs.
* Calculation logic in ML5 scorecard scripts.

#### Integration Tests

Located in `tests/integration/`. These tests verify:

* `make inject-canon` correctly bootstraps a fresh directory.
* `make resolve` correctly materializes logic from Tier 0.

#### Validation Drills

Located in `scripts/validate-*.sh`. These are system-level checks designed to run in both local
development and Trinity CI.

### 3. Execution

* **Local**: Run `make test` for unit tests and `make ml5-validate` for a full maturity drill.
* **CI**: Every push to `main` or `develop` triggers the Trinity CI pipeline, which executes all test
  suites and validation drills.

### 4. Zero-Failure Policy

At ML5, any test failure or validation warning results in a "CRITICAL" audit event and immediate blocking
of the CI/CD pipeline.
