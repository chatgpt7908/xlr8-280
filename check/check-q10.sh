#!/bin/bash

echo "🔍 Validating configuration for 'scala' app in 'gru'..."

DEPLOYMENT=scala
NAMESPACE=gru

# Check if deployment exists
if ! oc get deploy $DEPLOYMENT -n $NAMESPACE >/dev/null 2>&1; then
  echo "❌ Deployment 'scala' not found in namespace 'gru'"
  exit 1
fi

# Validate HPA exists
if ! oc get hpa $DEPLOYMENT -n $NAMESPACE >/dev/null 2>&1; then
  echo "❌ HPA for 'scala' not found"
  exit 1
fi

# Validate HPA specs
MIN_REP=$(oc get hpa $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.minReplicas}')
MAX_REP=$(oc get hpa $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.maxReplicas}')
CPU_UTIL=$(oc get hpa $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}')

if [[ "$MIN_REP" == "6" && "$MAX_REP" == "40" && "$CPU_UTIL" == "60" ]]; then
  echo "✅ HPA correctly configured (min=6, max=40, CPU=60%)"
else
  echo "❌ HPA configuration incorrect:"
  echo "   minReplicas: $MIN_REP"
  echo "   maxReplicas: $MAX_REP"
  echo "   CPU Target: $CPU_UTIL"
fi

# Validate CPU request/limit
REQ_CPU=$(oc get deploy $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
LIM_CPU=$(oc get deploy $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}')

if [[ "$REQ_CPU" == "25m" && "$LIM_CPU" == "100m" ]]; then
  echo "✅ CPU resources set correctly (request=25m, limit=100m)"
else
  echo "❌ CPU resource misconfigured:"
  echo "   Request: $REQ_CPU"
  echo "   Limit: $LIM_CPU"
fi

