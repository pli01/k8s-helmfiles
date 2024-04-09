# k8s-helmfiles

[![[helmfiles releases]](https://github.com/pli01/k8s-helmfiles/actions/workflows/test.yaml/badge.svg?branch=main)](https://github.com/pli01/k8s-helmfiles/actions/workflows/test.yaml)

A monorepo for [Helm](https://helm.sh/) release configuration, managed by
[Helmfile](https://github.com/helmfile/helmfile) and [ArgoCD](https://github.com/argoproj/argo-cd)

Make the most of it:
- Employ Helmfile for generating values tailored to Helm charts
- Deploy ArgoCD Applications that leverage values rendered by Helmfile, allowing ArgoCD controllers to handle the deployment of Helm releases.

## Concepts:
- Helm is a templating system for Kubernetes resource manifests.

Helm uses a packaging format called charts. A chart is a collection of files that describe
a related set of Kubernetes resources.

Helm charts are distributed from Helm repositories

A Helm chart describes a paramaterized deployment configuration that is environment-agnostic.
An instantiated deployment of a Helm chart is called a Helm release

A release is a deployment of a Helm chart in an environment, where an environment is
the combination of a set of parameters ("values") and a Kubernetes target.

- Helmfile is a management system for Helm releases.
It allows the mapping of 'charts' to 'values' to be declared in files.
values can be declared at various levels (environments, services, role...), as template or raw values

- Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.
It use Git repositories as the source of truth for defining the desired application state. It also allows to deploy Helm charts or deploy with helmfile.

## Repository Structure
### helmfile.d

A top-level helmfile directory, contains dependencies release files and directory.
All the yaml files under the specified directory are processed in the alphabetical order.
Each files defines an ordered list of  releases to deploy.

- 01-core-apps.yaml: for core applications (example ingress,cert-manager,...)
- 02-argocd.yaml: argocd and app-of-apps
- 03-loki.yaml: logs aggregator
- 02-prometheus-stack.yaml: observability (grafana,prometheus)
- 03-promtail.yaml: logs shipping
- 02-sample-apps.yaml: other applications


#### bases
This directory contains 2 files:
- `helmDefaults.yaml`, which directs `helmfile` on global configuration to pass to `helm`
- and `environments.yaml` wich defines defines various environments (define in environments directory)

#### environments
This directory contains values for each environments, and kubernetes target

Files are loaded in following order and the last override the first.
- `common.yaml`: is the common file loaded in all environement
- `{{ environment }}.yaml`

Environments:
- `default.yaml`: is the default use by helmfile without any argument
- `local.yaml`: is a sample local environment, (based on KinD kubernetes target for example)
- `dev.yaml`: is an other sample dev environment

```
# example:  to deploy one environment, for example 'local' use:
helmfile -e local  sync
```

#### releases
Each subdirectory of `releases` contains 1 (or sometimes more!) release.

Each helmfile in releases, define helm repository and releases dependencies (helm charts), and values and secrets (for helm charts)

- `releases/01-core/`: contains minimal workload needed on kubernetes target (ingress-nginx, observability stack)
- `releases/argocd/`
- `releases/loki/`
- `releases/promtail/`
- `releases/prometheus-stack/`
- `releases/sample-whoami/`: contains sample app workload, whoami

#### Values

Values for releases can be defined in following order:
- lookup a value file named `Release_Name-values.gotmpl`
- lookup a value file named `env/Environment_Name/Release_Name-values.gotmpl`

```
  ...
  values:
    - "{{`{{ .Release.Name }}`}}-values.yaml.gotmpl"
    - "env/{{ .Environment.Name }}/{{`{{ .Release.Name }}`}}-values.yaml.gotmpl"

Secrets can be defined in the same way
```

### ArgoCD app of apps

ArgoCD can deploy helmfiles with the concept of app of apps

For this example:
- We define the git repository which contain the root apps (the apps of apps) in `helmfile.d/releases/argocd/env/local/extra-argocd-values.yaml.gotmpl`
  - in this demo: argocd watch this repo and is trigger on branch `test-argocd-helmfile`
- Then, we define all Argocd Application in `argocd-apps/app-helmfile*.yaml`
- Argocd will trigger all deployment on Every commit, on the branch

## Run it

Prereq:
- make
- helm
- helmfile (and dependencies)
- sops/age
- kubectl
- kubernetes target

You can install all requirements from the following script hosted on https://github.com/numerique-gouv/dk8s

```
# download  and install all binaries in /usr/local/bin  (need sudo access)
curl -Ls https://raw.githubusercontent.com/numerique-gouv/dk8s/main/scripts/install-prereq.sh | bash
```

### helmfile steps:

This example, deploy helmfile releases in a local kubernetes environment

If needed, a Makefile is available as a wrapper to helmfile and "local" environment config (can be overrided)

Some usefull targets of the Makefile:

Some targets of makefile:

- Lint files
```
make lint
# or
helmfile -e local lint
```
- Display templated files
```
make template
# or
helmfile -e local template
```

- Install local kind cluster
```
# kind cluster
make ci-bootstrap-local-cluster
# or kind cluster with local docker registry
make ci-bootstrap-local-cluster-with-registry
```

- (Local env): generate and import a local root CA, to generate TLS certificates for all applications
```
make local-root-ca
```

- First deployment (needed to load some CRDS)

```
# first deployment, needed to load CRDS
make sync
# or
helmfile -e local sync
```

- Deploy all helmfiles
```
make apply
# or
helmfile -e local apply
```
- Deployment of kind cluster with only core apps (ingres-nginx,cert-manager)
```
make boostrap-core
```

- Deployment of kind cluster with only core apps (ingres-nginx,cert-manager) + ArgoCD
```
make boostrap-argocd
```

- Diff mode only
```
make diff
# or
helmfile -e local diff
```

Destroy all resources
```
make destroy
# or
helmfile -e local destroy
```
