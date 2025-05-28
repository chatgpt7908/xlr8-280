#!/bin/bash

REPLICAS=$(oc get deployment hydra -n lerna -o jsonpath='{.spec.replicas}')

if [ "$REPLICAS" -eq 5 ]; then
  echo "✅ Validation Passed: hydra is scaled to 5 replicas"
else
  echo "❌ Validation Failed: Expected 5 replicas but found $REPLICAS"
fi

