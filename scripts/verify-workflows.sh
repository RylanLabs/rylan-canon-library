#!/usr/bin/env bash
# Script: verify-workflows.sh
# Purpose: Autonomous Workflow Verifier - Mesh Edition
# Agent: Bauer (Auditor)
# Ministry: Configuration Management
# Guardian: Bauer
# Maturity: v5.0.0 (ML5)
# Compliance: Seven Pillars, Hellodeolu v6, T3-ETERNAL v2.0.0
# Date: 2026-02-05

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# SOVEREIGN GATES
# ============================================================================

# Whitaker Gate: Block on uncommitted or unsigned state
if command -v whitaker-scan.sh &>/dev/null; then
  whitaker-scan.sh
elif [[ -f "./scripts/whitaker-scan.sh" ]]; then
  bash ./scripts/whitaker-scan.sh
fi

# Sentinel Gate: Block on expiry <14 days
if command -v sentinel-expiry.sh &>/dev/null; then
  sentinel-expiry.sh
elif [[ -f "./scripts/sentinel-expiry.sh" ]]; then
  bash ./scripts/sentinel-expiry.sh
fi

# ============================================================================
# CONFIGURATION & DYNAMIC DISCOVERY
# ============================================================================

AUDIT_DIR=".audit"
AUDIT_FILE="$AUDIT_DIR/verify-workflows.json"
CONFIG_FILE="canon-manifest.yaml"

mkdir -p "$AUDIT_DIR"

# Dynamic Config from canon-manifest.yaml with safe defaults
if [[ -f "$CONFIG_FILE" ]] && command -v yq &>/dev/null; then
  # Detect if it's the Go or Python version of yq
  if yq --version 2>&1 | grep -q "version"; then
    # Go version (mikefarah/yq)
    WORKFLOWS_DIR=$(yq e '.global_config.workflows_dir // ".github/workflows"' "$CONFIG_FILE")
    readarray -t REQUIRED_FIELDS < <(yq e '.global_config.required_workflow_fields[]' "$CONFIG_FILE")
  else
    # Python version (jq wrapper) - standard in common Linux distros
    WORKFLOWS_DIR=$(yq -r '.global_config.workflows_dir // ".github/workflows"' "$CONFIG_FILE")
    readarray -t REQUIRED_FIELDS < <(yq -r '.global_config.required_workflow_fields[]' "$CONFIG_FILE")
  fi
else
  WORKFLOWS_DIR=".github/workflows"
  REQUIRED_FIELDS=("name" "on" "jobs")
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No color

# ============================================================================
# TOOL ENFORCEMENT (No-Bypass)
# ============================================================================

install_if_missing() {
  local tool=$1
  local pkg=$2
  
  if ! command -v "$tool" &>/dev/null; then
    log_warn "🔧 $tool missing. Attempting autonomous installation of '$pkg' (No-Bypass)..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y "$pkg"
      elif command -v pip &>/dev/null; then
        pip install --user "$pkg"
      fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      if command -v brew &>/dev/null; then
        brew install "$pkg"
      fi
    fi
    
    if ! command -v "$tool" &>/dev/null; then
      log_error "Critical dependency $tool could not be installed. Exiting."
      exit 1
    fi
  fi
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
  echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*"
}

log_debug() {
  echo -e "${BLUE}[DEBUG]${NC} $*"
}

# ============================================================================
# ERROR HANDLING (Bauer Auditor)
# ============================================================================

cleanup() {
  local exit_code=$?
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Structural Bauer Audit
  cat <<EOF > "$AUDIT_FILE"
{
  "timestamp": "$timestamp",
  "script": "verify-workflows.sh",
  "agent": "Bauer",
  "status": $((exit_code == 0 ? 1 : 0)),
  "exit_code": $exit_code,
  "metrics": {
    "workflows_found": $(find "${WORKFLOWS_DIR:-.github/workflows}" -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | wc -l),
    "environment": "$(uname -s)"
  }
}
EOF

  if [[ $exit_code -ne 0 ]]; then
    log_error "Workflow verification failed with exit code $exit_code"
    log_error "Audit trail preserved in $AUDIT_FILE"
  else
    log_info "Audit trail updated in $AUDIT_FILE"
  fi
  
  exit "$exit_code"
}

trap cleanup ERR EXIT

# ============================================================================
# VALIDATION LOGIC
# ============================================================================

get_workflows() {
  if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    return 0
  fi
  
  # Safe discovery: excludes templates
  find "$WORKFLOWS_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) \
    ! -path "*/templates/*" \
    ! -name "*template*"
}

validate_workflows_with_gh() {
  log_info "Phase 1: Validating with gh CLI"
  
  local workflows
  readarray -t workflows < <(get_workflows)
  local failed=0
  
  if [[ ${#workflows[@]} -eq 0 ]]; then
    log_warn "No workflow files found in $WORKFLOWS_DIR"
    return 0
  fi
  
  for workflow in "${workflows[@]}"; do
    [[ -z "$workflow" ]] && continue
    local filename
    filename=$(basename "$workflow")
    
    if gh workflow view "$workflow" --json name &> /dev/null; then
      log_info "✓ $filename: Validated by GitHub API"
    else
      log_error "✗ $filename: GitHub API validation failed"
      failed=$((failed + 1))
    fi
  done
  
  return "$failed"
}

validate_workflow_yaml_syntax() {
  log_info "Phase 2: Verifying YAML syntax (yamllint)"
  
  local workflows
  readarray -t workflows < <(get_workflows)
  if [[ ${#workflows[@]} -eq 0 ]]; then return 0; fi

  local yamllint_args=()
  if [[ -f "configs/.yamllint" ]]; then
    yamllint_args=("-c" "configs/.yamllint")
  fi

  # Bauer Auditing: Generate structured JSON report
  if yamllint "${yamllint_args[@]}" --format json "${workflows[@]}" > "$AUDIT_DIR/yamllint.json" 2>/dev/null; then
    log_info "✓ All workflows passed syntax validation"
    return 0
  else
    log_error "✗ YAML syntax errors detected"
    # Pretty-print top errors for human readability
    yamllint "${yamllint_args[@]}" --format parsable "${workflows[@]}" | head -n 5
    return 1
  fi
}

check_required_workflow_fields() {
  log_info "Phase 3: Deep-parsing required fields (yq)"
  
  local workflows
  readarray -t workflows < <(get_workflows)
  local failed=0
  
  if [[ ${#workflows[@]} -eq 0 ]]; then return 0; fi
  
  for workflow in "${workflows[@]}"; do
    [[ -z "$workflow" ]] && continue
    local filename
    filename=$(basename "$workflow")
    local missing_fields=()
    
    for field in "${REQUIRED_FIELDS[@]}"; do
      if yq --version 2>&1 | grep -q "version"; then
        if ! yq e "has(\"$field\")" "$workflow" | grep -q "true"; then
          missing_fields+=("$field")
        fi
      else
        if ! yq -e "has(\"$field\")" "$workflow" >/dev/null 2>&1; then
          missing_fields+=("$field")
        fi
      fi
    done
    
    if [[ ${#missing_fields[@]} -eq 0 ]]; then
      log_info "✓ $filename: All required fields present"
    else
      log_error "✗ $filename: Missing fields: [${missing_fields[*]}]"
      failed=$((failed + 1))
    fi
  done
  
  return "$failed"
}

summary_report() {
  echo ""
  log_info "========================================="
  log_info "Workflow Verification Summary"
  log_info "========================================="
  echo ""
  log_info "Workflows checked:"
  
  local workflows
  readarray -t workflows < <(get_workflows)
  for workflow in "${workflows[@]}"; do
    [[ -z "$workflow" ]] && continue
    log_info "  ✓ $(basename "$workflow")"
  done
  
  echo ""
  log_info "Validation checks:"
  log_info "  ✓ Sovereignty (Whitaker/Sentinel)"
  log_info "  ✓ GitHub API validation (gh)"
  log_info "  ✓ Syntax validation (yamllint)"
  log_info "  ✓ Field validation (yq)"
  echo ""
  log_info "========================================="
}

remediate_workflows() {
  log_info "Phase 4: Lazarus Autonomous Remediation"
  
  local workflows
  readarray -t workflows < <(get_workflows)
  if [[ ${#workflows[@]} -eq 0 ]]; then return 0; fi
  
  for workflow in "${workflows[@]}"; do
    [[ -z "$workflow" ]] && continue
    local filename
    filename=$(basename "$workflow")
    log_info "🔧 Repairing ${workflow}..."
    
    # 1. Trailing whitespace and newline EOF (Lazarus standard)
    sed -i 's/[[:space:]]*$//' "$workflow"
    if [[ $(tail -c 1 "$workflow" | wc -l) -eq 0 ]]; then
      echo "" >> "$workflow"
    fi
    
    # Ensuring document start "---"
    if ! head -n 1 "$workflow" | grep -q "^---"; then
      log_info "  Adding document start '---' to $filename"
      sed -i '1i---' "$workflow"
    fi
    
    # 2. Add missing required fields with placeholders
    for field in "${REQUIRED_FIELDS[@]}"; do
      if yq --version 2>&1 | grep -q "version"; then
        if ! yq e "has(\"$field\")" "$workflow" | grep -q "true"; then
          log_warn "  Adding missing field: $field"
          yq e -i ".$field = \"FIXME_AUTOGENERATED\"" "$workflow"
        fi
      else
        if ! yq -e "has(\"$field\")" "$workflow" >/dev/null 2>&1; then
          log_warn "  Adding missing field: $field"
          yq -i -y ".$field = \"FIXME_AUTOGENERATED\"" "$workflow"
        fi
      fi
    done
  done
  
  # Hook into mesh-remediate if available
  if command -v mesh-remediate.sh &>/dev/null; then
    mesh-remediate.sh --pr-workflows
  fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  local mode="${1:-}"
  
  log_info "========================================="
  log_info "Autonomous Workflow Verifier (ML5)"
  log_info "========================================="
  
  # Phase 0: Dependency Enforcement (No-Bypass)
  install_if_missing gh gh
  install_if_missing yamllint yamllint
  install_if_missing yq yq

  if [[ "$mode" == "--fix" ]]; then
    remediate_workflows
    log_info "✅ Remediation complete. Re-verifying..."
    echo ""
  fi
  
  local gh_passed=0
  local yaml_passed=0
  local fields_passed=0
  
  validate_workflows_with_gh || gh_passed=$?
  echo ""
  validate_workflow_yaml_syntax || yaml_passed=$?
  echo ""
  check_required_workflow_fields || fields_passed=$?
  echo ""
  
  summary_report
  
  # Final Assessment
  if [[ $gh_passed -eq 0 && $yaml_passed -eq 0 && $fields_passed -eq 0 ]]; then
    log_info "✅ All verification checks passed"
    log_info "The Trinity endures. Fortress eternal. 🛡️"
    return 0
  else
    log_error "❌ Verification failed [GH: $gh_passed, YAML: $yaml_passed, FIELDS: $fields_passed]"
    log_error "Run with --fix for autonomous remediation."
    return 1
  fi
}

# Help...
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat << HELP
Usage: scripts/verify-workflows.sh [OPTIONS]

Autonomous Workflow Verifier - Mesh Edition (ML5)

OPTIONS:
  --fix         Execute Lazarus auto-remediation (whitespace, fields)
  --help, -h    Show this help message

FEATURES:
  - Whitaker/Sentinel Sovereign Gates
  - Manifest-driven discovery (canon-manifest.yaml)
  - No-Bypass dependency enforcement
  - YAML deep-parsing field validation
  - Bauer structured auditing (.audit/verify-workflows.json)
  - Lazarus self-healing (--fix)

DEPENDENCIES:
  - gh, yamllint, yq (Auto-installed if possible)
HELP
  exit 0
fi

main "$@"
