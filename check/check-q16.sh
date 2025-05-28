#!/bin/bash

URL="http://voyager-path-finder.apps.ocp4.example.com"

echo -e "\n🔍 Checking URL: $URL\n"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ "$HTTP_CODE" -eq 200 ]; then
  echo -e "\e[32m✅ OK: Received HTTP 200 from $URL\e[0m"
else
  echo -e "\e[31m❌ Wrong: Received HTTP $HTTP_CODE from $URL\e[0m"
fi

echo ""

