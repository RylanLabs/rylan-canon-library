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

mesh-man: ## Regenerate MESH-MAN.md operational manual | guardian: Carter | timing: 10s
	@$(call log_info, Regenerating MESH-MAN.md)
	@START=$$(date +%s%3N); \
	chmod +x scripts/generate-mesh-man.sh; \
	./scripts/generate-mesh-man.sh && STATUS="PASS" || STATUS="FAIL"; \
	END=$$(date +%s%3N); \
	$(call log_audit,mesh-man,Carter,$$STATUS,$$((END-START)),MESH-MAN manual updated); \
	if [ "$$STATUS" = "FAIL" ]; then exit 1; fi

repo-init: ## Bootstrap new repositories to RylanLabs standards | guardian: Lazarus | timing: 2m
	@$(call log_info, Bootstrapping new repository)
	@START=$$(date +%s%3N); \
	chmod +x scripts/repo-init.sh; \
	./scripts/repo-init.sh && STATUS="PASS" || STATUS="FAIL"; \
	END=$$(date +%s%3N); \
	$(call log_audit,repo-init,Lazarus,$$STATUS,$$((END-START)),Repo scaffolded); \
	if [ "$$STATUS" = "FAIL" ]; then exit 1; fi

clean: ## Remove temporary audit files and logs | guardian: Lazarus | timing: 5s
	@$(call log_info, Cleaning temporary files)
	@START=$$(date +%s%3N); \
	rm -rf .audit/*.tmp .audit/audit-trail.jsonl && STATUS="PASS" || STATUS="FAIL"; \
	END=$$(date +%s%3N); \
	$(call log_audit,clean,Lazarus,$$STATUS,$$((END-START)),Cleanup completed); \
	if [ "$$STATUS" = "FAIL" ]; then exit 1; fi
