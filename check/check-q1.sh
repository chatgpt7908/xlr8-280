#!/bin/bash

echo "=== EX280 - Question 1 Validation Script ==="

# --- Check Identity Provider ---
echo -n "Step 1: Identity Provider 'htpass-ex280'... "
if oc get oauth cluster -o jsonpath="{.spec.identityProviders[*].name}" | grep -qw "htpass-ex280"; then
  echo "✅ Found"
else
  echo "❌ Not Found"
fi

# --- Check Secret ---
echo -n "Step 2: Secret 'htpass-idp-ex280' in openshift-config... "
if oc get secret htpass-idp-ex280 -n openshift-config &> /dev/null; then
  echo "✅ Found"
else
  echo "❌ Not Found"
fi

# --- Check Users ---
users=("jobs" "wozniak" "collins" "adlerin" "armstrong")
for user in "${users[@]}"; do
  echo -n "Step 3: User '$user'... "
  if oc get user $user &> /dev/null; then
    echo "✅ Exists"
  else
    echo "❌ Not Found"
  fi
done

echo "=== Validation Complete ==="
