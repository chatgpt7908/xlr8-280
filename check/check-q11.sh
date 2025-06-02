#!/bin/bash

echo "=== EX280 - Secret Validation Script ==="

NAMESPACE="math"
SECRET_NAME="magic"
KEY="Decoder_Ring"
EXPECTED_VALUE="ASDA142hfh-gfrhhueo-erfdk345v"

echo "Checking if Secret '$SECRET_NAME' exists in namespace '$NAMESPACE'..."
if ! oc get secret "$SECRET_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "❌ Secret '$SECRET_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi
echo "✅ Found"

echo "Validating key '$KEY' with expected value..."
ACTUAL_VALUE=$(oc get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath="{.data.$KEY}" | base64 -d)

if [ "$ACTUAL_VALUE" == "$EXPECTED_VALUE" ]; then
  echo "✅ Key '$KEY' has the correct value."
else
  echo "❌ Key '$KEY' has incorrect value. Found: '$ACTUAL_VALUE'"
  exit 1
fi

echo "=== Validation Complete ==="

