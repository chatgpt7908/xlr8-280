#!/bin/bash

echo "=== EX280 - ernie App Validation Script ==="

# Set variables
NAMESPACE="czech"
APP_NAME="ernie"
EXPECTED_IMAGE_PREFIX="quay.io/redhattraining/hello-openshift"
EXPECTED_RESPONSE="six czech cricket critics"
URL="http://ernie.apps.ocp4.example.com"

# Check Deployment
echo -n "Checking Deployment '$APP_NAME' in namespace '$NAMESPACE'... "
if oc get deploy "$APP_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "✅ Found"
else
  echo "❌ Not Found"
  exit 1
fi

# Validate Image
echo -n "Validating image is $EXPECTED_IMAGE_PREFIX... "
IMAGE=$(oc get deploy "$APP_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.template.spec.containers[0].image}")
if [[ "$IMAGE" == "$EXPECTED_IMAGE_PREFIX"* ]]; then
  echo "✅"
else
  echo "❌ (found: $IMAGE)"
fi

# Validate ConfigMap
echo -n "Validating ConfigMap 'ex280-cm' with key RESPONSE... "
RESPONSE=$(oc get cm ex280-cm -n "$NAMESPACE" -o jsonpath="{.data.RESPONSE}")
if [[ "$RESPONSE" == "$EXPECTED_RESPONSE" ]]; then
  echo "✅"
else
  echo "❌ (found: $RESPONSE)"
fi

# Check response from the app
echo -n "Checking app response from $URL... "
APP_RESPONSE=$(curl -s "$URL")
if [[ "$APP_RESPONSE" == *"$EXPECTED_RESPONSE"* ]]; then
  echo "✅ Response matched"
else
  echo "❌ Unexpected response: $APP_RESPONSE"
fi

echo "=== Validation Complete ==="

