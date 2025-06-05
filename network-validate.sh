#!/bin/bash

echo "🔍 Switching to 'atlas' namespace..."
oc project atlas &>/dev/null

echo "1️⃣ Checking 'deny-all' NetworkPolicy in 'atlas'..."
if oc get networkpolicy deny-all -n atlas &>/dev/null; then
  echo "✅ 'deny-all' policy exists in atlas"
else
  echo "❌ 'deny-all' policy MISSING in atlas"
fi

echo "2️⃣ Checking 'allow' NetworkPolicy in 'atlas'..."
if oc get networkpolicy allow -n atlas &>/dev/null; then
  echo "✅ 'allow' policy exists in atlas"
else
  echo "❌ 'allow' policy MISSING in atlas"
fi

echo "3️⃣ Checking if 'bluewills' namespace has label name=bluewills..."
LABEL=$(oc get ns bluewills --show-labels | grep 'name=bluewills')
if [[ -n "$LABEL" ]]; then
  echo "✅ 'bluewills' namespace has correct label"
else
  echo "❌ 'bluewills' namespace is missing label 'name=bluewills'"
fi

echo "4️⃣ Curl test from 'rocky' pod in 'bluewills' to 'mercury' pod in 'atlas'..."
oc exec -n bluewills pod/rocky -- curl -s --connect-timeout 3 mercury.atlas.svc.cluster.local:8080 &>/dev/null
if [ $? -eq 0 ]; then
  echo "✅ Connection SUCCESSFUL from 'rocky' ➝ 'mercury'"
else
  echo "❌ Connection FAILED from 'rocky' ➝ 'mercury'"
fi

