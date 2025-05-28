#!/bin/bash
echo "=== EX280 - Project Template Validation ==="

# Step 1: Check default project template set in cluster
echo "Checking default projectRequestTemplate..."
template_name=$(oc get project.config.openshift.io/cluster -o jsonpath='{.spec.projectRequestTemplate.name}')
if [[ -z "$template_name" ]]; then
  echo "❌ No default projectRequestTemplate set"
  exit 1
fi
echo "✅ Found default template: $template_name"

# Step 2: Get LimitRange and ResourceQuota object names from template
echo "Fetching objects from template $template_name..."
objects=$(oc get template "$template_name" -n openshift-config -o json)

limitrange_name=$(echo "$objects" | jq -r '.objects[] | select(.kind=="LimitRange") | .metadata.name')
resourcequota_name=$(echo "$objects" | jq -r '.objects[] | select(.kind=="ResourceQuota") | .metadata.name')

if [[ -z "$limitrange_name" || -z "$resourcequota_name" ]]; then
  echo "❌ LimitRange or ResourceQuota missing in template"
  exit 1
fi
echo "✅ Found LimitRange: $limitrange_name"
echo "✅ Found ResourceQuota: $resourcequota_name"

# Step 3: Create a test project to verify objects are applied
test_project="projtest-$(date +%s)"
echo "Creating test project: $test_project"
oc new-project "$test_project" >/dev/null 2>&1

# Wait for some seconds to allow template objects to apply
echo "Waiting 10 seconds for objects to be created in $test_project..."
sleep 10

# Step 4: Validate LimitRange exists in the test project
echo "Checking LimitRange in $test_project..."
if oc get limitrange "$limitrange_name" -n "$test_project" >/dev/null 2>&1; then
  echo "✅ LimitRange $limitrange_name found"
else
  echo "❌ LimitRange $limitrange_name NOT found"
fi

# Step 5: Validate ResourceQuota exists in the test project
echo "Checking ResourceQuota in $test_project..."
if oc get resourcequota "$resourcequota_name" -n "$test_project" >/dev/null 2>&1; then
  echo "✅ ResourceQuota $resourcequota_name found"
else
  echo "❌ ResourceQuota $resourcequota_name NOT found"
fi

# Step 6: Cleanup test project
echo "Cleaning up test project..."
oc delete project "$test_project" --wait=true >/dev/null 2>&1

echo "=== Validation Complete ==="

