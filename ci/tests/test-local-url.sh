#!/bin/bash
#
set -e -o pipefail

echo "Test local urls"
curl_args="--connect-timeout 30 --retry 300 --retry-delay 5"

function test_url() {
    url="$1"
    message="$2"
    timeout="$3"
    interval="$4"
    test_result=1
    until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
      ( curl $curl_args -Lsv "$url" 2>&1 |grep "$message" )
      test_result=$?
      if [ "$test_result" -gt 0 ] ;then
         echo "URL $url is not accessible yet. Retrying in $timeout seconds: $test_result";
         (( timeout-- ))
         sleep $interval
      fi
    done
    if [ "$test_result" -gt 0 ] ;then
            test_status=ERROR
            echo "$test_status: Timeout reached. URL $url is not accessible. result: $test_result"
            return $test_result
    fi
    echo "URL $url is accessible."
}

timeout=180

test_url "https://alertmanager.127.0.0.1.nip.io" "<title>Alertmanager</title>" $timeout 1 || exit $?
test_url "https://prometheus.127.0.0.1.nip.io" "<title>Prometheus Time Series Collection and Processing Server</title>" $timeout 1 || exit $?
test_url "https://grafana.127.0.0.1.nip.io" "<title>Grafana</title>" $timeout 1 || exit $?
test_url "https://argocd.127.0.0.1.nip.io" "<title>Argo CD</title>" $timeout 1 || exit $?
test_url "https://whoami.127.0.0.1.nip.io" "^Hostname" $timeout 1 || exit $?
