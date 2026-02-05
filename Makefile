# RylanLabs Repository Makefile
# Anchor: rylan-canon-library
# Guardian: Bauer | Ministry: Oversight
# Maturity: Level 5 (Autonomous)

-include common.mk

.PHONY: all help validate clean warm-session org-audit mesh-man mesh-remediate repo-init cascade publish fetch reconcile

all: help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

warm-session: ## Establish 8-hour password-less GPG session (Asymmetric Warm)
	@chmod +x scripts/warm-session.sh
	@./scripts/warm-session.sh

validate: ## Run Whitaker/Sentinel compliance gates (Security/Linter)
	@chmod +x scripts/validate.sh
	@./scripts/validate.sh

org-audit: ## Multi-repo compliance scan (Whitaker)
	@chmod +x scripts/org-audit.sh
	@./scripts/org-audit.sh

mesh-man: ## Generate MESH-MAN.md coverage documentation
	@chmod +x scripts/generate-mesh-man.sh
	@./scripts/generate-mesh-man.sh

mesh-remediate: ## Force drift back to green (Lazarus)
	@chmod +x scripts/mesh-remediate.sh
	@./scripts/mesh-remediate.sh

repo-init: ## Bootstrap new repositories to RylanLabs standards
	@chmod +x scripts/repo-init.sh
	@./scripts/repo-init.sh

cascade: ## Topic-driven secret distribution (Beale)
	@chmod +x scripts/publish-cascade.sh
	@./scripts/publish-cascade.sh --cascade

reconcile: ## Meta-GitOps: Declarative state reconciliation
	@echo "Reconciling state via consensus engine..."
	@python3 scripts/audit-consensus-engine.py

publish: validate ## Heartbeat: Sign, Tag, and Push (Carter)
	@git add .
	@read -p "Commit message: " msg; \
	git commit -S -m "$$msg"
	@git tag -s v$$(date +%G.%V.%u) -m "Mesh heartbeat"
	@git push origin main --tags

clean: ## Clean local artifacts
	@rm -rf .cache/ .tmp/ .audit/*
