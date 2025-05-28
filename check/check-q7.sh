#!/bin/bash

# === EX280 - Route Validation Script ===
echo "🔍 Checking Route: http://rocky.apps.ocp4.example.com"

URL="http://rocky.apps.ocp4.example.com"

# Perform a curl request and capture HTTP status code
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$STATUS_CODE" -eq 200 ]; then
  echo "✅ Route is reachable with HTTP 200 OK"
else
  echo "❌ Route check failed. HTTP status code: $STATUS_CODE"
  echo "⚠️  Please verify:"
  echo "  - The application 'rocky' is deployed"
  echo "  - The Route exists in project 'bluewills'"
  echo "  - The Route URL is correct and accessible"
fi

