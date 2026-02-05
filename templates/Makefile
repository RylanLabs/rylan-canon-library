# RylanLabs Satellite Makefile
# Anchor: <repo-name>
# Guardian: Bauer | Ministry: Oversight

-include .rylan/common.mk

.PHONY: help validate clean publish cascade

help: ## Show this help
@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

validate: ## Locally executable gate (Whitaker)
@chmod +x scripts/validate.sh
@./scripts/validate.sh

publish: validate ## Heartbeat: Sign, Tag, and Push (Carter)
@git add .
@read -p "Commit message: " msg; \
git commit -S -m "$$msg"
@git tag -s v\$(date +%G.%V.%u) -m "Mesh heartbeat"
@git push origin main --tags

clean: ## Clean local artifacts
@rm -rf .cache/ .tmp/ .audit/*
