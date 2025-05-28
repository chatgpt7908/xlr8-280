#!/bin/bash

NAMESPACE="math"
APP_NAME="qed"
SECRET_KEY_EXPECTED="ASDA142hfh-gfrhhueo-erfdk345v"

echo "[*] Checking pod status..."
oc rollout status deployment/$APP_NAME -n $NAMESPACE --timeout=30s || {
  echo "[❌] Deployment not ready!"
  exit 1
}

ROUTE=$(oc get route $APP_NAME -n $NAMESPACE -o jsonpath='{.spec.host}')
echo "[*] Testing app with curl..."
RESPONSE=$(curl -s --max-time 5 http://$ROUTE)

if [[ "$RESPONSE" == *"$SECRET_KEY_EXPECTED"* ]]; then
  echo -e "[✅] SUCCESS: App responded correctly!"
else
  echo -e "[❌] ERROR: App not responding correctly!"
  echo -e "Response:\n$RESPONSE"
  exit 2
fi

