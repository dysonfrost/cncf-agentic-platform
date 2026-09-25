.DEFAULT_GOAL := help

CLUSTER_NAME   ?= cncf-agentic-platform
CLUSTER_CONFIG ?= bootstrap/k3d/cluster.yaml
KUBECTL        := kubectl --context k3d-$(CLUSTER_NAME)
ARGOCD_CHART_VERSION ?= 10.9.2

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: check-deps
check-deps: ## Verify required tools and Docker daemon are available
	@command -v k3d     >/dev/null || { echo "k3d is required"; exit 1; }
	@command -v kubectl >/dev/null || { echo "kubectl is required"; exit 1; }
	@command -v docker  >/dev/null || { echo "docker is required"; exit 1; }
	@command -v helm    >/dev/null || { echo "helm is required"; exit 1; }
	@command -v git     >/dev/null || { echo "git is required"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "Docker daemon is not reachable."; exit 1; }
	@echo "All prerequisites OK."

.PHONY: cluster-up
cluster-up: check-deps ## Create local k3d cluster
	@if k3d cluster list $(CLUSTER_NAME) >/dev/null 2>&1; then \
		echo "Cluster $(CLUSTER_NAME) already exists"; exit 1; \
	fi
	@k3d cluster create --config $(CLUSTER_CONFIG) --wait
	@$(KUBECTL) get nodes

.PHONY: cluster-down
cluster-down: ## Delete local k3d cluster
	@k3d cluster delete $(CLUSTER_NAME) 2>/dev/null || \
		echo "Cluster $(CLUSTER_NAME) not found, nothing to do"

.PHONY: cluster-status
cluster-status: ## Show cluster and node status
	@k3d cluster list
	@$(KUBECTL) get nodes -o wide

.PHONY: cluster-smoke-test
cluster-smoke-test: ## Run a smoke-test pod on each node
	@echo "Waiting for nodes to be Ready..."
	@$(KUBECTL) wait --for=condition=Ready nodes --all --timeout=120s
	@set -e; for node in $$($(KUBECTL) get nodes -o jsonpath='{.items[*].metadata.name}'); do \
		echo "  -> $$node"; \
		$(KUBECTL) run test-$$node \
			--image=busybox --restart=Never \
			--labels=app=cluster-smoke-test \
			--overrides="{\"spec\":{\"nodeName\":\"$$node\"}}" \
			--command -- sleep 3600; \
	done
	@$(KUBECTL) wait --for=condition=Ready pod -l app=cluster-smoke-test --timeout=60s
	@$(KUBECTL) get pods -o wide -l app=cluster-smoke-test
	@$(KUBECTL) delete pods -l app=cluster-smoke-test --wait=true

.PHONY: argocd-install
argocd-install: check-deps ## Install Argo CD via Helm (one-time bootstrap)
	@helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
	@helm repo update
	@helm upgrade --install argocd argo/argo-cd \
		--namespace argocd --create-namespace \
		--version $(ARGOCD_CHART_VERSION) \
		-f bootstrap/argocd/values.yaml \
		--rollback-on-failure --wait --timeout 5m
	@$(KUBECTL) get pods -n argocd

.PHONY: gitops-bootstrap
gitops-bootstrap: check-deps ## Apply the root Application to start GitOps reconciliation
	@$(KUBECTL) get crd applications.argoproj.io >/dev/null 2>&1 || \
		{ echo "Argo CD CRDs not found. Run 'make argocd-install' first."; exit 1; }
	@$(KUBECTL) apply -f gitops/argocd-apps/root-app.yaml
	@echo "Root Application applied. Argo CD will reconcile from Git."
	@$(MAKE) gitops-status

.PHONY: gitops-status
gitops-status: ## Show Argo CD Applications and sync status
	@$(KUBECTL) get applications -n argocd \
		-o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
	@echo ""
	@$(KUBECTL) get pods -n argocd

.PHONY: argocd-password
argocd-password: ## Print the Argo CD initial admin password
	@$(KUBECTL) -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo