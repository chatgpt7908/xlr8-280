#!/bin/bash

echo "=== EX280 - Question 2 Validation Script ==="

# 1. Check if jobs has cluster-admin role
echo -n "Checking if 'jobs' has cluster-admin role... "
if oc get clusterrolebindings -o json | jq -e '.items[] | select(.subjects[]?.name=="jobs" and .roleRef.name=="cluster-admin")' &> /dev/null; then
  echo "✅ Yes"
else
  echo "❌ No"
fi

# 2. Check if wozniak can create projects (self-provisioner)
echo -n "Checking if 'wozniak' can self-provision projects... "
if oc get clusterrolebindings -o json | jq -e '.items[] | select(.subjects[]?.name=="wozniak" and .roleRef.name=="self-provisioner")' &> /dev/null; then
  echo "✅ Yes"
else
  echo "❌ No"
fi

# 3. Check if armstrong is prevented from creating projects (self-provisioner removed)
echo -n "Checking if 'armstrong' is restricted from self-provisioning... "
if oc get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name=="self-provisioner") | .subjects[]?.name' | grep -qw "armstrong"; then
  echo "❌ armstrong still has self-provisioner"
else
  echo "✅ armstrong cannot self-provision"
fi

# 4. Check if wozniak is NOT cluster-admin
echo -n "Checking if 'wozniak' is NOT cluster-admin... "
if oc get clusterrolebindings -o json | jq -e '.items[] | select(.subjects[]?.name=="wozniak" and .roleRef.name=="cluster-admin")' &> /dev/null; then
  echo "❌ wozniak should not be cluster-admin"
else
  echo "✅ Correct, wozniak is not cluster-admin"
fi

# 5. Check if kubeadmin user is removed
echo -n "Checking if 'kubeadmin' is removed... "
if oc get user kubeadmin &> /dev/null; then
  echo "❌ kubeadmin still exists"
else
  echo "✅ kubeadmin removed"
fi

echo "=== Validation Complete ==="

