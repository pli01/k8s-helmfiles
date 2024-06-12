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
It allows the mapping of 'charts' to 'values' and 'secrets' to be declared in files.
values can be declared at various levels (environments, services, role...), as template or raw values

- Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.
It use Git repositories as the source of truth for defining the desired application state. It also allows to deploy Helm charts or deploy with helmfile.

Note:
argocd run the helmfile plugin. In this context, helmfile generate template to output.
Rendered ressources are send to kubernetes cluster in stream
helmfile is not executed directly in argocd

## Repository Structure
It is organized as followed
- apps: argocd app per cluster and steps for cluster
- helmfile.d: helmfile releases to create and configure cluster. generic helmfile and helm charts with default configuration
- environments: per environment and cluster configuration and secrets (can be hosted on private repo)

A local environment is provided to develop on local machine

### helmfile.d

A top-level helmfile directory, contains directories and dependencies release files
All the yaml files under the specified directory are processed in the alphabetical order.
Each files defines an ordered list of  releases to deploy.

- cluster-bootstrap: cluster-api
  - 01-create-cluster.yaml : create kubernetes cluster with cluster-api

- cluster-configure-core: core applications (ingress,cert-manager,...)
  - 00-namespaces.yaml
  - 01-cert-manager.yaml
  - 02-ingress-nginx.yaml

- cluster-workload: addons workload applications (argocd,prometheus,loki,...)
  - 00-namespaces-workload.yaml
  - 10-argocd.yaml
  - 30-loki.yaml
  - 31-prometheus-stack.yaml
  - 32-promtail.yaml
  - 80-whoami.yaml

#### bases
This directory contains 2 files:
- `helmDefaults.yaml`, which directs `helmfile` on global configuration to pass to `helm`
- and `environments.yaml` wich defines defines various environments (define in environments directory)

#### base/environments
This directory contains default values for all environments, and local target

Files are loaded in following order and the last override the first.

Environments:
- `default.yaml`: is the default use by helmfile without any argument
- `local.yaml`: is a sample local environment, (based on KinD kubernetes target for development)


#### releases
Each subdirectory of `releases` contains 1 (or sometimes more!) release.

Each helmfile in releases, define helm repository and releases dependencies (helm charts), and values and secrets (for helm charts)

- `releases/cert-manager/`
- `releases/ingress-nginx/`
- `releases/argocd/`
- `releases/loki/`
- `releases/promtail/`
- `releases/prometheus-stack/`
- `releases/whoami/`: contains sample app workload, whoami

#### Values and Secrets

Values for releases can be defined in following order:
- lookup a value file named `releases/Relase_name/Release_Name-values.gotmpl`
- lookup a value file named `../environnements/Environment_Name/Release_name/values.gotmpl`

```
  ...
  values:
    - "{{`{{ .Release.Name }}`}}-values.yaml.gotmpl"
    - "env/{{ .Environment.Name }}/{{`{{ .Release.Name }}`}}/values.yaml.gotmpl"

Secrets can be defined in the same way
```

### environments
This directory contains least values loaded for all environments

environments:
  - ENV.yaml
  - ENV/{releases}/values.yaml
  - ENV/{releases}/secrets.enc.yaml

### ArgoCD app of apps

ArgoCD can deploy helmfiles with the concept of app of apps

For this example:
- We define the git repository which contain the root apps (the apps of apps) in `environments/local/extra-argocd/values.yaml.gotmpl`
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

- Lint files
```
make lint HELMFILE_FILE=helmfile.d/cluster-configure-core
```
- Display templated files
```
make template HELMFILE_FILE=helmfile.d/cluster-configure-core
```

- First deployment (needed to load some CRDS)
```
# first deployment, needed to load CRDS
make sync HELMFILE_FILE=helmfile.d/cluster-configure-core
```

- Deploy all helmfiles
```
make apply HELMFILE_FILE=helmfile.d/cluster-configure-core
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
```

Destroy all resources
```
make destroy
```

### test helmfile for another environment: lint and template

```
# lint file
( export CLUSTER_NAME=c1-demo ; make  HELMFILE_ENVIRONMENT=${CLUSTER_NAME}  HELMFILE_FILE=helmfile.d/cluster-configure-core lint )

# generate template
( export CLUSTER_NAME=c1-demo ; make  HELMFILE_ENVIRONMENT=${CLUSTER_NAME}  HELMFILE_FILE=helmfile.d/cluster-configure-core template )

# test template in dry run on antoher real cluster
( export CLUSTER_NAME=c1-demo ; export KUBECONFIG=$HOME/.kube/${CLUSTER_NAME}.kubeconfig ; make  HELMFILE_ENVIRONMENT=${CLUSTER_NAME}  HELMFILE_FILE=helmfile.d/workload-cluster/  KUBECONFIG=$KUBECONFIG template | kubectl apply -f e --dry-run=client )
```
