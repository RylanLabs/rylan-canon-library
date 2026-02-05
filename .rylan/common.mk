# rylan-labs-common/common.mk
# Guardian: Bauer | Ministry: Oversight
# Shared logic for the RylanLabs Mesh Substrate

# --- Constants ---
DOMAIN_NAME := rylanlabs.io
GPG_KEY_ID  := F5FFF5CB35A8B1F38304FC28AC4A4D261FD62D75

# --- Terminal Styling ---
B_CYAN  := \033[1;36m
B_GREEN := \033[1;32m
B_RED   := \033[1;31m
NC      := \033[0m

# --- Shared Helpers ---
define log_info
	@echo "$(B_CYAN)[INFO]$(NC) $(1)"
endef

define log_success
	@echo "$(B_GREEN)[OK]$(NC) $(1)"
endef

define log_error
	@echo "$(B_RED)[FAIL]$(NC) $(1)"
endef

# --- Common Targets ---
.PHONY: help-common validate publish cascade org-audit mesh-remediate resolve re-init

help: ## Show shared targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(lastword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

resolve: ## Materialize symlinks for Windows/WSL/CI compatibility (Agnosticism Pattern)
	@$(call log_info, "Materializing symlinks to literal files...")
	@find . -type l -not -path '*/.*' -exec bash -c 'target=$$(readlink -f "{}"); rm "{}"; cp -r "$$target" "{}"' \;
	@$(call log_success, "Symlinks materialized.")

re-init: ## Re-sync repository with Canon Hub symlinks (Lazarus)
	@$(call log_info, "Re-syncing with Canon Hub...")
	@../rylan-canon-library/scripts/auto-migrate.sh

validate: ## Run standard Whitaker gates
	@$(call log_info, "Checking mandatory files...")
	@for file in Makefile README.md .gitleaks.toml; do \
		if [ ! -f "$$file" ]; then \
			$(call log_error, "Missing $$file"); \
			exit 1; \
		fi; \
	done
	@$(call log_success, "Basic scaffolding valid.")

publish: ## Sync state to mesh (Carter)
	@$(call log_info, "Publishing state to mesh...")
	@./scripts/publish-cascade.sh

cascade: ## Distribute secrets/state through mesh (Beale)
	@$(call log_info, "Cascading mesh updates...")
	@./scripts/publish-cascade.sh --cascade

org-audit: ## Multi-repo compliance scan (Whitaker)
	@$(call log_info, "Starting organizational audit...")
	@./scripts/org-audit.sh

mesh-remediate: ## Force drift back to green (Lazarus)
	@$(call log_info, "Remediating mesh drift...")
	@./scripts/mesh-remediate.sh
