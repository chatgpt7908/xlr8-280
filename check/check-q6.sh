#!/bin/bash

echo "=== EX280 - LimitRange Validation Script ==="

NAMESPACE="bluebook"
LR_NAME="ex280-limits"

echo "Checking if LimitRange '$LR_NAME' exists in namespace '$NAMESPACE'..."
if ! oc get limitrange "$LR_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "❌ LimitRange not found"
  exit 1
else
  echo "✅ Found"
fi

lr_json=$(oc get limitrange "$LR_NAME" -n "$NAMESPACE" -o json)

# Extracting limits
get_limit() {
  echo "$lr_json" | jq -r ".spec.limits[] | select(.type==\"$1\") | $2"
}

# Pod limits
pod_min_mem=$(get_limit "Pod" '.min.memory')
pod_max_mem=$(get_limit "Pod" '.max.memory')
pod_min_cpu=$(get_limit "Pod" '.min.cpu')
pod_max_cpu=$(get_limit "Pod" '.max.cpu')

# Container limits
container_min_mem=$(get_limit "Container" '.min.memory')
container_max_mem=$(get_limit "Container" '.max.memory')
container_min_cpu=$(get_limit "Container" '.min.cpu')
container_max_cpu=$(get_limit "Container" '.max.cpu')
container_default_req_cpu=$(get_limit "Container" '.defaultRequest.cpu')
container_default_req_mem=$(get_limit "Container" '.defaultRequest.memory')

# Pod memory check
echo -n "Validating Pod memory (100Mi - 300Mi)... "
[[ "$pod_min_mem" == "100Mi" && "$pod_max_mem" == "300Mi" ]] && echo "✅" || echo "❌ (found: $pod_min_mem - $pod_max_mem)"

# Pod CPU check
echo -n "Validating Pod CPU (10m - 500m)... "
[[ "$pod_min_cpu" == "10m" && "$pod_max_cpu" == "500m" ]] && echo "✅" || echo "❌ (found: $pod_min_cpu - $pod_max_cpu)"

# Container CPU limits + default request
echo -n "Validating Container CPU (10m - 500m, defaultRequest: 100m)... "
if [[ "$container_min_cpu" == "10m" && "$container_max_cpu" == "500m" && "$container_default_req_cpu" == "100m" ]]; then
  echo "✅"
else
  echo "❌ (found: $container_min_cpu - $container_max_cpu, defaultRequest: $container_default_req_cpu)"
fi

# Container memory limits + default request
echo -n "Validating Container memory (100Mi - 300Mi, defaultRequest: 100Mi)... "
if [[ "$container_min_mem" == "100Mi" && "$container_max_mem" == "300Mi" && "$container_default_req_mem" == "100Mi" ]]; then
  echo "✅"
else
  echo "❌ (found: $container_min_mem - $container_max_mem, defaultRequest: $container_default_req_mem)"
fi

echo "=== Validation Complete ==="

