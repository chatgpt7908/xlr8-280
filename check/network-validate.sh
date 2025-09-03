#!/bin/bash

set -e

echo "🔍 Validating OpenShift network setup and connectivity"

# 1️⃣ Check 'deny-all-traffic' NetworkPolicy in 'mercury'
echo
echo "1️⃣ Checking 'deny-all-traffic' policy in 'mercury'..."
if oc get networkpolicy deny-all-traffic -n mercury &>/dev/null; then
  echo "✅ 'deny-all-traffic' exists in namespace 'mercury'"
else
  echo "❌ 'deny-all-traffic' MISSING in namespace 'mercury'"
fi

# 2️⃣ Check 'allow-only-webapp' NetworkPolicy in 'mercury'
echo
echo "2️⃣ Checking 'allow-only-webapp' policy in 'mercury'..."
if oc get networkpolicy allow-only-webapp -n mercury &>/dev/null; then
  echo "✅ 'allow-only-webapp' exists in namespace 'mercury'"
else
  echo "❌ 'allow-only-webapp' MISSING in namespace 'mercury'"
fi

# 3️⃣ Check that namespace 'sun' has label name=sun
echo
echo "3️⃣ Checking 'sun' namespace label name=sun..."
if oc get ns sun --show-labels | grep -qw 'name=sun'; then
  echo "✅ Namespace 'sun' has label name=sun"
else
  echo "❌ Namespace 'sun' is missing label 'name=sun'"
fi

# 4️⃣ Check that 'webapp' pod in 'sun' is Running
echo
echo "4️⃣ Checking that 'webapp' pod in 'sun' is Running..."
POD=$(oc get pods -n sun -l app=webapp -o jsonpath='{.items[0].metadata.name}')
STATUS=$(oc get pod "$POD" -n sun -o jsonpath='{.status.phase}')
if [[ "$STATUS" == "Running" ]]; then
  echo "✅ Pod '$POD' is Running"
else
  echo "❌ Pod '$POD' is not Running (status: $STATUS)"
fi

# 5️⃣ Test MySQL connectivity from 'webapp' pod to 'database' service under allow-only policy
echo
echo "5️⃣ Testing MySQL connection from 'webapp' ➝ 'database' (should succeed)..."
if oc exec -n sun pod/"$POD" -- bash -c "MYSQL_PWD=password123 mysql -h database.mercury.svc.cluster.local -u dbuser -D mydb -e 'SELECT 1;'"; then
  echo "✅ MySQL connection SUCCESSFUL"
else
  echo "❌ MySQL connection FAILED under allow-only policy"
fi

# 6️⃣ Verify block under deny-all policy by temporarily removing allow-only-webapp
echo
echo "6️⃣ Verifying connection blocked when only 'deny-all-traffic' is active..."
echo "   Temporarily deleting allow-only-webapp policy..."
oc delete networkpolicy allow-only-webapp -n mercury

# Give a moment for policy to take effect
sleep 5

if oc exec -n sun pod/"$POD" -- bash -c "MYSQL_PWD=password123 mysql --connect-timeout=5 -h database.mercury.svc.cluster.local -u dbuser -D mydb -e 'SELECT 1;'"; then
  echo "❌ MySQL connection SUCCEEDED unexpectedly under deny-all only"
else
  echo "✅ MySQL connection BLOCKED as expected under deny-all policy"
fi

# Recreate allow-only-webapp policy
echo "   Recreating allow-only-webapp policy..."
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-only-webapp
  namespace: mercury
spec:
  podSelector:
    matchLabels:
      deployment: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: sun
      podSelector:
        matchLabels:
          app: webapp
    ports:
    - protocol: TCP
      port: 3306
EOF

echo
echo "🔚 Validation complete."

