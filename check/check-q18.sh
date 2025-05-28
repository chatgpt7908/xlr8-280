#!/bin/bash

echo "=== EX280 - Question 15 Validation Script ==="

# Namespace & Deployment Check
echo -n "Checking deployment 'gamma' in namespace 'space'... "
if oc get deployment gamma -n space &>/dev/null; then
  echo "✅ Found"
else
  echo "❌ Not Found"
  exit 1
fi

# PVC Mount Check in deployment
echo -n "Checking if 'gammapvc' PVC is mounted at /srv... "
VOLUME_MOUNTED=$(oc get deployment gamma -n space -o json | jq -r '.spec.template.spec.containers[].volumeMounts[]? | select(.mountPath=="/srv") | .name')

if [ -n "$VOLUME_MOUNTED" ]; then
  VOLUME_LINKED=$(oc get deployment gamma -n space -o json | jq -r --arg vol "$VOLUME_MOUNTED" '.spec.template.spec.volumes[]? | select(.name==$vol) | .persistentVolumeClaim.claimName')
  if [ "$VOLUME_LINKED" == "gammapvc" ]; then
    echo "✅ Mounted"
  else
    echo "❌ PVC mismatch (found: $VOLUME_LINKED)"
  fi
else
  echo "❌ Volume not mounted at /srv"
fi

echo "=== Validation Complete ==="

