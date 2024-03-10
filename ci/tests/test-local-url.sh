#!/bin/bash
#
set -e -o pipefail

echo "Test local urls"

echo "# https://whoami.127.0.0.1.nip.io"
curl -Lsv https://whoami.127.0.0.1.nip.io  2>&1 |grep "^Hostname"

echo "# https://grafana.127.0.0.1.nip.io"
curl -Lsv https://grafana.127.0.0.1.nip.io 2>&1 |grep "<title>Grafana</title>"
echo "# https://prometheus.127.0.0.1.nip.io"
curl -Lsv https://prometheus.127.0.0.1.nip.io  2>&1 |grep "<title>Prometheus Time Series Collection and Processing Server</title>"
echo "# https://alertmanager.127.0.0.1.nip.io"
curl -Lsv https://alertmanager.127.0.0.1.nip.io 2>&1  |grep "<title>Alertmanager</title>"

echo "# https://argocd.127.0.0.1.nip.io"
curl -Lsv https://argocd.127.0.0.1.nip.io  2>&1 |grep "<title>Argo CD</title>"
