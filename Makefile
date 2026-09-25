.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: bootstrap
bootstrap: ## Bootstrap local prerequisites (to be implemented)
	@echo "TODO: bootstrap"

.PHONY: cluster-up
cluster-up: ## Create local k3d cluster (to be implemented)
	@echo "TODO: cluster-up"

.PHONY: cluster-down
cluster-down: ## Delete local k3d cluster (to be implemented)
	@echo "TODO: cluster-down"
