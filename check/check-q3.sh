#!/bin/bash

echo "=== EX280 - Question 3 Validation Script ==="

# 1. Check projects existence
projects=(apollo titan gemini bluebook apache)
for proj in "${projects[@]}"; do
  echo -n "Checking if project '$proj' exists... "
  if oc get project "$proj" &> /dev/null; then
    echo "✅ Exists"
  else
    echo "❌ Missing"
  fi
done

# 2. Check if armstrong is admin in apollo and titan
for proj in apollo titan; do
  echo -n "Checking if 'armstrong' is admin in project '$proj'... "
  # Get rolebindings in project with subject armstrong and role admin (admin ClusterRole)
  if oc get rolebindings -n "$proj" -o json | jq -e \
    --arg user "armstrong" \
    '.items[] | select(.subjects[]?.name == $user and (.roleRef.name == "admin" or .roleRef.name == "admin"))' &> /dev/null; then
    echo "✅ Yes"
  else
    echo "❌ No"
  fi
done

# 3. Check if collins has view role in apollo project
echo -n "Checking if 'collins' has view role in project 'apollo'... "
if oc get rolebindings -n apollo -o json | jq -e \
  '.items[] | select(.subjects[]?.name=="collins" and .roleRef.name=="view")' &> /dev/null; then
  echo "✅ Yes"
else
  echo "❌ No"
fi

echo "=== Validation Complete ==="

