HELMFILE_ENVIRONMENT := local

lint:
	@helmfile -e $(HELMFILE_ENVIRONMENT) lint
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
