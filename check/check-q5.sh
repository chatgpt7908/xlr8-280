#!/bin/bash

echo "=== EX280 - ResourceQuota Validation Script ==="

NAMESPACE="apache"
RQ_NAME="ex280-quota"

echo "Checking if ResourceQuota '$RQ_NAME' exists in namespace '$NAMESPACE'..."
if ! oc get resourcequota "$RQ_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "❌ ResourceQuota not found"
  exit 1
else
  echo "✅ Found"
fi

expected_cpu="2"
expected_memory="1Gi"
expected_rc="3"
expected_pods="3"
expected_svc="6"

actual_cpu=$(oc get resourcequota "$RQ_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.hard['limits\.cpu']}")
actual_memory=$(oc get resourcequota "$RQ_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.hard['limits\.memory']}")
actual_rc=$(oc get resourcequota "$RQ_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.hard['replicationcontrollers']}")
actual_pods=$(oc get resourcequota "$RQ_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.hard['pods']}")
actual_svc=$(oc get resourcequota "$RQ_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.hard['services']}")

echo -n "Validating limits.memory (expected: $expected_memory)... "
[[ "$actual_memory" == "$expected_memory" ]] && echo "✅" || echo "❌ (found: $actual_memory)"

echo -n "Validating limits.cpu (expected: $expected_cpu)... "
[[ "$actual_cpu" == "$expected_cpu" ]] && echo "✅" || echo "❌ (found: $actual_cpu)"

echo -n "Validating replicationcontrollers (expected: $expected_rc)... "
[[ "$actual_rc" == "$expected_rc" ]] && echo "✅" || echo "❌ (found: $actual_rc)"

echo -n "Validating pods (expected: $expected_pods)... "
[[ "$actual_pods" == "$expected_pods" ]] && echo "✅" || echo "❌ (found: $actual_pods)"

echo -n "Validating services (expected: $expected_svc)... "
[[ "$actual_svc" == "$expected_svc" ]] && echo "✅" || echo "❌ (found: $actual_svc)"

echo "=== Validation Complete ==="

