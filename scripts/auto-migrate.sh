#!/usr/bin/env bash
# Script: auto-migrate.sh
# Purpose: Lazarus-class Autonomous Symlink Migrator
# Agent: Lazarus (Remediation)
# Ministry: Configuration Management
# Guardian: Beale (Enforcement)
# Maturity: v5.0.0 (ML5)
# Date: 2026-02-04

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================

CANON_ROOT=$(cd "$(dirname "$0")/.." && pwd)
REPOS_DIR=$(cd "$CANON_ROOT/.." && pwd)

# Sacred Scripts (Must be symlinked to Canon)
SACRED_SCRIPTS=(
  "validate.sh"
  "validate-yaml.sh"
  "validate-bash.sh"
  "validate-python.sh"
  "validate-ansible.sh"
  "validate-sops.sh"
  "whitaker-scan.sh"
  "sentinel-expiry.sh"
  "warm-session.sh"
  "playbook-structure-linter.py"
  "verify-workflows.sh"
)

# Sacred Configs (Must be symlinked to Shared-Configs if available, else Canon)
SACRED_CONFIGS=(
  ".yamllint"
  ".shellcheckrc"
  ".gitleaks.toml"
  ".editorconfig"
  ".markdownlint.json"
)

# Shared CI Workflows (Literal copies, but managed)
SACRED_WORKFLOWS=(
  "repo-governance.yml"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ============================================================================
# MIGRATION LOGIC
# ============================================================================

migrate_repo() {
  local target_repo=$1
  local repo_path="$REPOS_DIR/$target_repo"
  
  if [[ ! -d "$repo_path" ]]; then
    log_error "Repo not found: $target_repo"
    return 1
  fi

  if [[ "$repo_path" == "$CANON_ROOT" ]]; then
    log_info "Skipping Canon Hub: $target_repo"
    return 0
  fi

  log_info "----------------------------------------------------"
  log_info "Migrating $target_repo to Symlink SSOT architecture..."
  log_info "----------------------------------------------------"

  # 1. Migrate Scripts (Manifest Driven)
  mkdir -p "$repo_path/scripts"
  if [[ -f "$CANON_ROOT/canon-manifest.yaml" ]]; then
      # Dynamically extract immutable scripts from manifest
      # We look for scripts/ prefix in dest
      # Using Python-yq compatible filter
      readarray -t MANIFEST_SCRIPTS < <(yq -r '.sacred_files[] | .[] | select(.dest | startswith("scripts/")) | .src' "$CANON_ROOT/canon-manifest.yaml" | sed 's|^scripts/||' | sort -u || echo "${SACRED_SCRIPTS[@]}")
  else
      MANIFEST_SCRIPTS=("${SACRED_SCRIPTS[@]}")
  fi

  for script in "${MANIFEST_SCRIPTS[@]}"; do
    local src_script="$CANON_ROOT/scripts/$script"
    local dest_script="$repo_path/scripts/$script"
    
    if [[ -f "$src_script" ]]; then
      if [[ -f "$dest_script" && ! -L "$dest_script" ]]; then
        log_warn "  [SCR] Replacing literal $script with symlink..."
        rm "$dest_script"
      fi
      
      if [[ ! -L "$dest_script" ]]; then
        # Use relative path for maximum portability
        ln -sf "../../rylan-canon-library/scripts/$script" "$dest_script"
        log_info "  [SCR] ✅ $script -> Symlinked"
      else
        log_info "  [SCR] 🟢 $script already symlinked"
      fi
    fi
  done

  # 2. Migrate Configs (Shared-Configs Hub Priority)
  local shared_configs_path="$REPOS_DIR/rylan-labs-shared-configs"
  local config_source="$CANON_ROOT"
  local relative_config_path="../../rylan-canon-library"

  if [[ -d "$shared_configs_path" ]]; then
    config_source="$shared_configs_path"
    relative_config_path="../../rylan-labs-shared-configs"
  fi

  for config in "${SACRED_CONFIGS[@]}"; do
    local src_config="$config_source/$config"
    local current_rel_path="$relative_config_path"
    
    # Special case: .yamllint logic
    if [[ "$config" == ".yamllint" && "$config_source" == "$CANON_ROOT" ]]; then
      src_config="$CANON_ROOT/configs/.yamllint"
      current_rel_path="../../rylan-canon-library/configs"
    fi

    local dest_config="$repo_path/$config"
    
    if [[ -f "$src_config" ]]; then
      if [[ -f "$dest_config" && ! -L "$dest_config" ]]; then
        log_warn "  [CFG] Replacing literal $config with symlink..."
        rm "$dest_config"
      fi

      if [[ ! -L "$dest_config" ]]; then
        ln -sf "$current_rel_path/$config" "$dest_config"
        log_info "  [CFG] ✅ $config -> Symlinked"
      else
        log_info "  [CFG] 🟢 $config already symlinked"
      fi
    fi
  done

  # 3. Migrate Workflow Substrate
  mkdir -p "$repo_path/.github/workflows"
  for workflow in "${SACRED_WORKFLOWS[@]}"; do
    local src_wf="$CANON_ROOT/.github/workflows/$workflow"
    local dest_wf="$repo_path/.github/workflows/$workflow"
    
    if [[ -f "$src_wf" ]]; then
      if [[ ! -f "$dest_wf" ]]; then
         cp "$src_wf" "$dest_wf"
         log_info "  [WKF] ✅ $workflow -> Contextually Anchored"
      else
         # Check if different
         if ! diff -q "$src_wf" "$dest_wf" &>/dev/null; then
            cp "$src_wf" "$dest_wf"
            log_info "  [WKF] 🔄 $workflow -> Synchronized"
         else
            log_info "  [WKF] 🟢 $workflow already healthy"
         fi
      fi
    fi
  done
}

# ============================================================================
# MAIN
# ============================================================================

main() {
  log_info "========================================="
  log_info "Lazarus Symlink Migration Agent"
  log_info "========================================="

  # Discovery: Find all rylan-* repos in the parent directory
  local repos
  readarray -t repos < <(find "$REPOS_DIR" -maxdepth 1 -name "rylan*" -type d -exec basename {} \;)

  for repo in "${repos[@]}"; do
    migrate_repo "$repo"
  done

  log_info ""
  log_info "✅ Mesh consolidation complete."
  log_info "The Trinity endures. One Source, Infinite Reach. 🛡️"
}

main "$@"
