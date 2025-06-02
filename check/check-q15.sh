#!/bin/bash

echo "=== EX280 - Route Validation Script ==="
ROUTE_URL="http://oranges.apps.ocp4.example.com"

echo "🔍 Checking route: $ROUTE_URL"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$ROUTE_URL")

if [ "$HTTP_STATUS" == "200" ]; then
  echo "✅ Route is reachable and returned HTTP 200 OK"
else
  echo "❌ Route is not valid or not returning 200 OK (Got: $HTTP_STATUS)"
fi

echo "=== Validation Complete ==="

