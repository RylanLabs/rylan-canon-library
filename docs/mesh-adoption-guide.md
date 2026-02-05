# RylanLabs Mesh Adoption Guide

Maturity: Level 5 (Autonomous)  
Agent: Carter (Bootstrap)

This guide outlines the steps to onboard an existing or new repository into the RylanLabs Mesh as a satellite.

## 1. Prerequisites

- `gh` CLI authenticated with `RylanLabs` organization.
- `git` configured with GPG/SSH signing.
- `pre-commit` installed locally.

## 2. Onboarding a New Repository

Use the `repo-init.sh` script from the Canon Library:

```bash
# From rylan-canon-library root
bash scripts/repo-init.sh <your-new-repo>
```

## 3. Onboarding an Existing Repository

If the repository already exists:

1. **Tag the Repository**:
   Add the `rylan-mesh-satellite` topic to the repo via GitHub UI or CLI:

   ```bash
   gh repo edit --add-topic rylan-mesh-satellite
   ```

2. **Initialize Substrate**:
   Copy `common.mk` and `.sops.yaml` from the Canon Library.

3. **Update Makefile**:
   Add the following line to the top of your `Makefile`:

   ```makefile
   -include .rylan/common.mk
   ```

4. **Install Hooks**:

   ```bash
   pre-commit install
   ```

## 4. Compliance Verification

Run the standard validation target:

```bash
make validate
```

## 5. Mesh Sentinel Integration

Once the topic is added, the **Sentinel Loop** (Whitaker agent) will automatically include the repository in its
nightly audit scans. Drift will be detected and remediation PRs (Lazarus agent) will be opened automatically.
