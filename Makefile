# RylanLabs Canonical Makefile
# Version: 4.5.2
# Purpose: Convenience targets for local development & validation
# Usage: make help (show all targets)
#        make validate (run all validators)
#        make format (auto-fix formatting)

.PHONY: help validate validate-python validate-bash validate-yaml validate-ansible \
        ci-local lint-quick format clean

# Default target
help:
	@echo "RylanLabs Canon Library - Make Targets"
	@echo "======================================"
	@echo ""
	@echo "Validation Targets:"
	@echo "  make validate            - Run ALL validators (python, bash, yaml, ansible)"
	@echo "  make validate-python     - Python validation only (mypy + ruff + bandit)"
	@echo "  make validate-bash       - Bash validation only (shellcheck + shfmt)"
	@echo "  make validate-yaml       - YAML validation only (yamllint)"
	@echo "  make validate-ansible    - Ansible validation only (ansible-lint + syntax)"
	@echo ""
	@echo "Development Targets:"
	@echo "  make ci-local            - Simulate full CI: validators + pytest + coverage"
	@echo "  make lint-quick          - Fast linting (ruff only, no mypy strict)"
	@echo "  make format              - Auto-fix formatting (ruff + shfmt -i 2)"
	@echo "  make clean               - Remove cache files (.venv, __pycache__, etc)"
	@echo ""
	@echo "Environment Variables:"
	@echo "  PYTHON_VERSION=3.12      - Override Python version (default: 3)"
	@echo "  VENV_DIR=.venv           - Override venv directory (default: .venv)"
	@echo ""
	@echo "Examples:"
	@echo "  make validate"
	@echo "  make format && git add . && git commit"
	@echo "  make ci-local"

# Validate all (run all 4 validators sequentially)
validate: validate-python validate-bash validate-yaml validate-ansible
	@echo ""
	@echo "✅ All validations passed"

# Python validation
validate-python:
	@echo "Running Python validation..."
	@bash scripts/validate-python.sh

# Bash validation
validate-bash:
	@echo "Running Bash validation..."
	@bash scripts/validate-bash.sh

# YAML validation
validate-yaml:
	@echo "Running YAML validation..."
	@bash scripts/validate-yaml.sh

# Ansible validation (optional - skip if no playbooks/)
validate-ansible:
	@if [ -d "playbooks" ]; then \
		echo "Running Ansible validation..."; \
		bash scripts/validate-ansible.sh; \
	else \
		echo "⊘ Ansible validation skipped (no playbooks/ directory)"; \
	fi

# CI simulation (validators + tests)
ci-local: validate
	@echo ""
	@echo "Running pytest with coverage..."
	@if [ -d "tests" ]; then \
		python3 -m pip install pytest pytest-cov >/dev/null 2>&1; \
		python3 -m pytest tests/ --cov=scripts --cov-fail-under=70 --cov-report=term-missing; \
	else \
		echo "⊘ Pytest skipped (no tests/ directory)"; \
	fi
	@echo ""
	@echo "✅ CI simulation complete"

# Quick lint (no strict mypy)
lint-quick:
	@echo "Running quick linting (ruff only, no mypy strict)..."
	@python3 -m pip install ruff >/dev/null 2>&1
	@python3 -m ruff check .
	@python3 -m ruff format --check .

# Auto-fix formatting
format:
	@echo "Auto-fixing formatting..."
	@python3 -m pip install ruff >/dev/null 2>&1 || true
	@python3 -m ruff format . 2>&1 | grep -v "^warning:" || true
	@find scripts -name "*.sh" -exec shfmt -i 2 -ci -bn -w {} \; 2>/dev/null || true
	@echo "✅ Formatting complete"

# Clean cache
clean:
	@echo "Cleaning cache files..."
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete
	@rm -rf .pytest_cache .mypy_cache .ruff_cache 2>/dev/null || true
	@rm -rf .venv venv 2>/dev/null || true
	@echo "✅ Cleanup complete"
