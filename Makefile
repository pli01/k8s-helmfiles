HELMFILE_ENVIRONMENT := local
HELMFILE_FILE := helmfile.d
K8S_VERSION=v1.29.4
export

lint: repos
	@helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE) lint
repos:
	@helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE) repos
template:
	@helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE) template --include-crds  --include-needs  --include-transitive-needs
diff:
	@helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE) diff
sync:
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE) sync
apply:
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE) apply --skip-diff-on-install
destroy:
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE) destroy

local-root-ca:
	@echo "# import local root CA"
	mkcert -install
	./scripts/local-ca-root-issuer.sh

ci-local-tests:
	@./ci/tests/test-local-url.sh

# Create cluster with local docker registry
ci-bootstrap-local-cluster-with-registry: ci-create-docker-registry ci-create-cluster-with-registry ci-configure-docker-registry
ci-create-cluster-with-registry:
	kind create cluster -n local-$(K8S_VERSION) --config ci/kind/local-registry.yaml --image=kindest/node:$(K8S_VERSION)

ci-create-docker-registry:
	./ci/scripts/create-docker-registry.sh
ci-configure-docker-registry:
	./ci/scripts/configure-docker-registry.sh

# Create cluster without local docker registry
ci-bootstrap-local-cluster: ci-create-cluster
ci-create-cluster:
	kind create cluster -n local-$(K8S_VERSION) --config ci/kind/local.yaml --image=kindest/node:$(K8S_VERSION)

ci-delete-local-cluster: ci-delete-docker-registry
	kind delete cluster -n local-$(K8S_VERSION)
ci-delete-docker-registry:
	docker rm -f  kind-registry || true

# Boostrap minimal core apps (argocd) and app-of-apps
HELMFILE_FILE_CORE=helmfile.d/cluster-configure-core
HELMFILE_FILE_ARGOCD=helmfile.d/cluster-workload/10-argocd.yaml
export HELMFILE_FILE_CORE

bootstrap-core: HELMFILE_FILE=$(HELMFILE_FILE_CORE)
bootstrap-core:
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE_CORE) apply --skip-diff-on-install
bootstrap-argocd: HELMFILE_FILE=$(HELMFILE_FILE_ARGOCD)
bootstrap-argocd: bootstrap-core
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE_ARGOCD) apply --skip-diff-on-install
