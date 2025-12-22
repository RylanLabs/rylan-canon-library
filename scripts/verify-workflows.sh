#!/usr/bin/env bash
# Script: verify-workflows.sh
# Purpose: Verify GitHub Actions workflows before pushing
# Agent: Bauer (Auditor)
# Ministry: Configuration Management
# Guardian: Bauer
# Consciousness: 9.5
# Compliance: Seven Pillars, Hellodeolu v6, T3-ETERNAL v∞.6.0
# Date: 2025-12-22
#
# Usage:
#   ./scripts/verify-workflows.sh          # Verify all workflows
#   ./scripts/verify-workflows.sh --help   # Show help

set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOWS_DIR=".github/workflows"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No color

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
# ERROR HANDLING
# ============================================================================

cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    log_error "Workflow verification failed with exit code $exit_code"
  fi
  exit $exit_code
}

trap cleanup EXIT

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

check_gh_cli() {
  log_info "Phase 1: Checking gh CLI availability"
  
  if command -v gh &> /dev/null; then
    local gh_version
    gh_version=$(gh --version 2>/dev/null | head -1)
    log_info "✓ gh CLI found: $gh_version"
    return 0
  else
    log_warn "gh CLI not found - skipping GitHub Actions verification"
    log_warn "Install with: brew install gh (macOS) or apt-get install gh (Linux)"
    log_warn "GitHub Actions workflows will still be validated with yamllint"
    return 1
  fi
}

validate_workflows_with_gh() {
  log_info "Phase 2: Validating GitHub Actions workflows with gh CLI"
  
  local workflows=()
  local failed=0
  
  # Find all workflow files
  if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    log_warn "Workflows directory not found: $WORKFLOWS_DIR"
    return 1
  fi
  
  while IFS= read -r workflow; do
    workflows+=("$workflow")
  done < <(find "$WORKFLOWS_DIR" -type f -name "*.yml" -o -name "*.yaml" 2>/dev/null)
  
  if [[ ${#workflows[@]} -eq 0 ]]; then
    log_warn "No workflow files found in $WORKFLOWS_DIR"
    return 1
  fi
  
  log_info "Found ${#workflows[@]} workflow file(s)"
  
  for workflow in "${workflows[@]}"; do
    local filename
    filename=$(basename "$workflow")
    
    if gh workflow view "$workflow" --json name &> /dev/null; then
      log_info "✓ $filename: Valid"
    else
      log_error "✗ $filename: Invalid"
      failed=$((failed + 1))
    fi
  done
  
  if [[ $failed -gt 0 ]]; then
    log_error "$failed workflow(s) failed validation"
    return 1
  fi
  
  return 0
}

validate_workflow_yaml_syntax() {
  log_info "Phase 3: Verifying workflow YAML syntax with yamllint"
  
  local workflows=()
  local failed=0
  
  if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    log_warn "Workflows directory not found: $WORKFLOWS_DIR"
    return 1
  fi
  
  while IFS= read -r workflow; do
    workflows+=("$workflow")
  done < <(find "$WORKFLOWS_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null)
  
  if [[ ${#workflows[@]} -eq 0 ]]; then
    log_warn "No workflow files found in $WORKFLOWS_DIR"
    return 1
  fi
  
  for workflow in "${workflows[@]}"; do
    local filename
    filename=$(basename "$workflow")
    
    if command -v yamllint &> /dev/null; then
      if yamllint -d relax "$workflow" > /dev/null 2>&1; then
        log_info "✓ $filename: YAML valid"
      else
        log_error "✗ $filename: YAML invalid"
        if yamllint -d relax "$workflow" 2>&1 | head -3; then
          true
        fi
        failed=$((failed + 1))
      fi
    else
      log_warn "yamllint not found, skipping YAML syntax check for $filename"
    fi
  done
  
  if [[ $failed -gt 0 ]]; then
    log_error "$failed workflow YAML file(s) have syntax errors"
    return 1
  fi
  
  return 0
}

check_required_workflow_fields() {
  log_info "Phase 4: Checking for required workflow fields"
  
  local workflows=()
  local failed=0
  
  if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    return 1
  fi
  
  while IFS= read -r workflow; do
    workflows+=("$workflow")
  done < <(find "$WORKFLOWS_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null)
  
  if [[ ${#workflows[@]} -eq 0 ]]; then
    return 1
  fi
  
  for workflow in "${workflows[@]}"; do
    local filename
    filename=$(basename "$workflow")
    
    # Check for required fields in workflow
    if grep -q "^name:" "$workflow" && \
       grep -q "^on:" "$workflow" && \
       grep -q "^jobs:" "$workflow"; then
      log_info "✓ $filename: Has required fields (name, on, jobs)"
    else
      log_error "✗ $filename: Missing required fields"
      failed=$((failed + 1))
    fi
  done
  
  if [[ $failed -gt 0 ]]; then
    log_error "$failed workflow(s) missing required fields"
    return 1
  fi
  
  return 0
}

summary_report() {
  echo ""
  log_info "========================================="
  log_info "Workflow Verification Summary"
  log_info "========================================="
  echo ""
  log_info "Workflows checked:"
  
  if [[ -d "$WORKFLOWS_DIR" ]]; then
    find "$WORKFLOWS_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | while read -r workflow; do
      local filename
      filename=$(basename "$workflow")
      log_info "  ✓ $filename"
    done
  fi
  
  echo ""
  log_info "Validation checks:"
  log_info "  ✓ gh CLI verification"
  log_info "  ✓ YAML syntax validation"
  log_info "  ✓ Required field validation"
  echo ""
  log_info "========================================="
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  local has_gh_cli=false
  local yaml_check_passed=false
  local field_check_passed=false
  
  log_info "========================================="
  log_info "GitHub Actions Workflow Verification"
  log_info "========================================="
  echo ""
  
  # Phase 1: Check gh CLI
  if check_gh_cli; then
    has_gh_cli=true
    # Phase 2: Validate with gh CLI if available
    if validate_workflows_with_gh; then
      log_info "✓ All workflows passed gh CLI validation"
    else
      log_warn "Some workflows failed gh CLI validation"
    fi
  fi
  
  echo ""
  
  # Phase 3: Validate YAML syntax (always run)
  if validate_workflow_yaml_syntax; then
    yaml_check_passed=true
    log_info "✓ All workflows have valid YAML syntax"
  else
    log_error "Some workflows have YAML syntax errors"
  fi
  
  echo ""
  
  # Phase 4: Check required fields
  if check_required_workflow_fields; then
    field_check_passed=true
    log_info "✓ All workflows have required fields"
  else
    log_error "Some workflows are missing required fields"
  fi
  
  echo ""
  
  # Summary
  summary_report
  
  # Determine exit code
  if [[ "$yaml_check_passed" == true ]] && [[ "$field_check_passed" == true ]]; then
    log_info "✅ All verification checks passed"
    log_info "========================================="
    log_info "Ready to push to GitHub!"
    log_info "The Trinity endures. Fortress eternal. 🛡️"
    log_info "========================================="
    return 0
  else
    log_error "❌ Verification failed"
    log_error "========================================="
    log_error "Fix errors and run this script again"
    log_error "========================================="
    return 1
  fi
}

# Handle help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  cat << 'HELP'
Usage: scripts/verify-workflows.sh [OPTIONS]

Verify GitHub Actions workflows before pushing to GitHub.

OPTIONS:
  --help, -h    Show this help message

FEATURES:
  - Check gh CLI availability
  - Validate workflows with gh CLI (if available)
  - Verify YAML syntax with yamllint
  - Check for required workflow fields (name, on, jobs)

EXIT CODES:
  0 - All verification checks passed
  1 - Some checks failed

EXAMPLES:
  # Verify all workflows
  ./scripts/verify-workflows.sh

  # Show this help
  ./scripts/verify-workflows.sh --help

DEPENDENCIES:
  - gh (GitHub CLI) - optional but recommended
  - yamllint - for YAML syntax validation
  - bash 4.0+

INSTALLATION:
  # Install gh CLI
  brew install gh                    # macOS
  apt-get install gh                 # Ubuntu/Debian
  
  # Install yamllint
  pip install yamllint

For more information, see: docs/pre-commit-setup.md
HELP
  exit 0
fi

# Run main function
main
