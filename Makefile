HELMFILE_ENVIRONMENT := local
K8S_VERSION=v1.29.2
export

lint: repos
	@helmfile -e $(HELMFILE_ENVIRONMENT) lint
repos:
	@helmfile -e $(HELMFILE_ENVIRONMENT) repos
template:
	@helmfile -e $(HELMFILE_ENVIRONMENT) template --include-crds  --include-needs  --include-transitive-needs -q
diff:
	@helmfile -e $(HELMFILE_ENVIRONMENT) diff
sync:
	helmfile -e $(HELMFILE_ENVIRONMENT) sync
apply:
	helmfile -e $(HELMFILE_ENVIRONMENT) apply --skip-diff-on-install
destroy:
	helmfile -e $(HELMFILE_ENVIRONMENT) destroy

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
HELMFILE_FILE_CORE=helmfile.d/01-core-apps.yaml
HELMFILE_FILE_ARGOCD=helmfile.d/02-argocd.yaml

boostrap-core:
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE_CORE) apply --skip-diff-on-install
boostrap-argocd: boostrap-core
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE_ARGOCD) apply --skip-diff-on-install
destroy-core:
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE_CORE) destroy
destroy-argocd: destroy-core
	helmfile -e $(HELMFILE_ENVIRONMENT) -f $(HELMFILE_FILE_ARGOCD) destroy
