HELMFILE_ENVIRONMENT := local

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
