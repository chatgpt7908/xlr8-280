#!/bin/bash

echo "=== EX280 - Question 14 Validation Script ==="

NAMESPACE="apples"
SA_NAME="ex-280-sa"

echo -n "Checking service account '$SA_NAME' in project '$NAMESPACE'... "
if oc get sa "$SA_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "✅ ServiceAccount found"
else
  echo "❌ Not Found"
  exit 1
fi

echo -n "Checking if '$SA_NAME' is bound to anyuid SCC... "
if oc get clusterrolebinding system:openshift:scc:anyuid -o json | jq -e \
  --arg sa "$SA_NAME" \
  --arg ns "$NAMESPACE" \
  '.subjects[] | select(.kind=="ServiceAccount" and .name==$sa and .namespace==$ns)' >/dev/null; then
  echo "✅ Bound to anyuid SCC"
else
  echo "❌ Not bound to anyuid SCC"
fi

echo "=== Validation Complete ==="

