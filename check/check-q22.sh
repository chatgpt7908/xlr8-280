#!/bin/bash

echo "=== EX280 - Question 22 Validation Script ==="

archive_path="/root/ex280-clusterdata.tar.gz"
deployment="gamma"
project="space"

echo -n "Checking must-gather archive at '$archive_path'... "
if [ -f "$archive_path" ]; then
  echo "✅ Archive found"
else
  echo "❌ Archive not found"
fi

echo -n "Checking liveness probe on deployment '$deployment' in project '$project'... "
probe=$(oc get deployment $deployment -n $project -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.tcpSocket.port}')
if [[ "$probe" == "8080" ]]; then
  echo "✅ Liveness probe on TCP 8080 found"
else
  echo "❌ Liveness probe missing or incorrect"
fi

echo "=== Validation Complete ==="
