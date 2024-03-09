# Configurations

Helms releases included:
- ingress-nginx
- cert-manager
- cert-manager-issuers
- loki
- promtail
- prometheus, grafana, alertmanager

Needs Dependencies:
- loki need ingress
- promtail need loki
- prometheus/grafana needs ingress, and loki


Environment Values Specifications:
  - common:
    - all default values for all releases 

  - default:
    - the default environment when helmfile cli is launched without arguments
    - all releases are disabled. Nothing deployed

  - local:
    - local environment used with KinD: configuration with ingress-nginx out of the box.
    - One default ingress-nginx, hosted on ctrl plane and local port exposed on 80/443

  - dev: (example)
    - dev environment used with KinD
    - no workload on ctrl plane
    - public ingress on one worker node (label: ingress-app): local port exposed on 80/443
    - private ingress on another worker node (label: ingress-admin): local port exposed on 81/444
    - all core workloads are hosted on admin worker node only

## Directory Structure
helmfile.yaml define:
- repositories
- releases values
- release dependencies order (needs)

Values releases can be defined as:
- raw values file : myrelease-values.yaml
- gotmpl template values:
  - myrelease-values.yaml.gotmpl : contains default values for helm charts
  - env/{{ environment }-myrelease-values.gotmpl: contains environments values for helmcharts

All environement values are defined in WORKDIR/helmfile.d/environments/ directory

## ingress-nginx specifications
- local environement: Values to work on local KinD configuration: https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/hack/manifest-templates/provider/kind/values.yaml
    In case, of default configuration local forwarded port hosted on ctrl plane (tolerations, and nodeSelector/labels must be provided)
    Ref: https://github.com/kubernetes-sigs/kind/issues/1693#issuecomment-1768116494

- Other configurations supported:
  - multiple separated ingress (example: public and private):
    specify ingressClass per ingress
