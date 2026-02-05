# RylanLabs Repository Makefile
# Anchor: rylan-canon-library
# Guardian: Bauer | Ministry: Oversight
# Maturity: Level 5 (Autonomous)

-include common.mk

.PHONY: all help warm-session mesh-man repo-init reconcile clean test

all: help

warm-session: ## Establish 8-hour password-less GPG session (Asymmetric Warm)
	@chmod +x scripts/warm-session.sh
	@./scripts/warm-session.sh

mesh-man: ## Generate MESH-MAN.md coverage documentation
	@chmod +x scripts/generate-mesh-man.sh
	@./scripts/generate-mesh-man.sh

repo-init: ## Bootstrap new repositories to RylanLabs standards
	@chmod +x scripts/repo-init.sh
	@./scripts/repo-init.sh

reconcile: ## Meta-GitOps: Declarative state reconciliation
	@echo "Reconciling state via consensus engine..."
	@python3 scripts/audit-consensus-engine.py

clean: ## Clean local artifacts
	@rm -rf .cache/ .tmp/ .audit/*
