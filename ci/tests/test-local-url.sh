#!/bin/bash
#
set -e -o pipefail

echo "Test local urls"
curl_args="--connect-timeout 30 --retry 300 --retry-delay 5"

timeout=180
test_result=1
echo "# https://prometheus.127.0.0.1.nip.io"
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
  ( curl -Lsv https://prometheus.127.0.0.1.nip.io  2>&1 |grep "<title>Prometheus Time Series Collection and Processing Server</title>" )
  test_result=$?
  if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
  fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: curl result: $test_result"
        exit $test_result
fi

timeout=180
test_result=1
echo "# https://alertmanager.127.0.0.1.nip.io"
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
  ( curl -Lsv https://alertmanager.127.0.0.1.nip.io 2>&1  |grep "<title>Alertmanager</title>" )
  test_result=$?
  if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
  fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: curl result: $test_result"
        exit $test_result
fi

timeout=180
test_result=1
echo "# https://grafana.127.0.0.1.nip.io"
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
  ( curl -Lsv https://grafana.127.0.0.1.nip.io 2>&1 |grep "<title>Grafana</title>" )
  test_result=$?
  if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
  fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: curl result: $test_result"
        exit $test_result
fi

timeout=180
test_result=1
echo "# https://argocd.127.0.0.1.nip.io"
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
  ( curl $curl_args  -Lsv https://argocd.127.0.0.1.nip.io  2>&1 |grep "<title>Argo CD</title>" )
  test_result=$?
  if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
  fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: curl result: $test_result"
        exit $test_result
fi

timeout=180
test_result=1
echo "# https://whoami.127.0.0.1.nip.io"
until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
  ( curl -Lsv https://whoami.127.0.0.1.nip.io  2>&1 |grep "^Hostname" )
  test_result=$?
  if [ "$test_result" -gt 0 ] ;then
     echo "Retry $timeout seconds: $test_result";
     (( timeout-- ))
     sleep 1
  fi
done
if [ "$test_result" -gt 0 ] ;then
        test_status=ERROR
        echo "$test_status: curl result: $test_result"
        exit $test_result
fi
