HELMFILE_ENVIRONMENT := local
K8S_VERSION=v1.29.2

lint: repos
	@helmfile -e $(HELMFILE_ENVIRONMENT) lint
repos:
	@helmfile -e $(HELMFILE_ENVIRONMENT) repos
template:
	@helmfile -e $(HELMFILE_ENVIRONMENT) template
diff:
	@helmfile -e $(HELMFILE_ENVIRONMENT) diff
sync:
	helmfile -e $(HELMFILE_ENVIRONMENT) sync
apply:
	helmfile -e $(HELMFILE_ENVIRONMENT) apply
destroy:
	helmfile -e $(HELMFILE_ENVIRONMENT) destroy

local-root-ca:
	@echo "# import local root CA"
	mkcert -install
	./scripts/local-ca-root-issuer.sh

ci-local-tests:
	@./ci/tests/test-local-url.sh
ci-bootstrap-local-cluster:
	kind create cluster -n local-$(K8S_VERSION) --config ci/kind/local.yaml  --image=kindest/node:$(K8S_VERSION)
ci-delete-local-cluster:
	kind delete cluster -n local-$(K8S_VERSION)
