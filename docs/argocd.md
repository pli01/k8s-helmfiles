# argocd

## bootstrap

A local ready to run argocd and app-of-apps steps:
- bootstrap a minimal argocd+ingress+cert-manager with helmfile.d/01-core-apps.yaml
- argocd automatically deploy the root app-of-apps: helmfile.d/release/01-core/env/local/extra-argocd-values.yaml.gotmpl
- argocd automatically deploy all helmfiles apps define in argocd-apps dir

```
# minimal bootstrap argocd+ingress+cert-manager (with local env config)
 helmfile -e local -f helmfile.d/01-core-apps.yaml apply --skip-diff-on-install
```

## Tips:

To generate password:
```
argocdServerAdminPassword: htpasswd -bnBC 10 "" _REPLACE_WITH_PWD | tr -d ':\n' | sed 's/$2y/$2b/
```
