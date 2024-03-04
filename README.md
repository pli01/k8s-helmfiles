# k8s-helmfiles

A monorepo for [Helm](https://helm.sh/) release configuration, managed by
[Helmfile](https://github.com/helmfile/helmfile).

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
values can to be declared at various levels (environments, services, role...), as template or raw values

## Repository Structure
### helmfile.d

A top-level helmfile directory, contains dependencies release files and directory.
All the yaml files under the specified directory are processed in the alphabetical order.
Each files defines an ordered list of  releases to deploy.

- 01-core-apps.yaml: for core applications (example ingress, observability, ...)
- 02-sample-apps.yaml: other applications

#### bases
This directory contains 2 files:
- `helmDefaults.yaml`, which directs `helmfile` on global configuration to pass to `helm`
- and `environments.yaml` wich defines defines various environments (define in environments directory)

#### environments
This directory contains values for each environments, and kubernetes target

Files are loaded in following order and the last override the first.
- `common.yaml`
- `{{ environment }}.yaml`

common.yaml: is the common file loaded in all environement
default.yaml: is the default use by helmfile without any argument
local.yaml: is a local environment, (based on KinD kubernetes target for example)

```
# example:  to deploy 'local' environement, use 
helmfile -e local  sync
```

#### releases
Each subdirectory of `releases` contains 1 (or sometimes more!) release.

Each helmfile in releases, define repository and releases dependencies, and values

`releases/01-core/`: contains minimal workload needed on default kubernetes target (ingress-nginx, observability stack)

## Run it

Prereq:
- helm
- helmfile (and dependencies)
- kubectl
- kubernetes target


helmfile steps:

This example, use local environment

First deployment (needed to load some CRDS)
```
# first deployment, needed to load CRDS
helmfile -e local sync
```

Deployment
```
helmfile -e local apply
```

Diff mode only
```
helmfile -e local diff
```

Lint files
```
helmfile -e local lint
```

Display templated files
```
helmfile -e local template
```

Destroy all resources
```
helmfile -e local destroy
```
