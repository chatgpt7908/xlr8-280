#!/bin/bash

echo "=== EX280 - Question 4 Validation Script ==="

# Function to check if a group exists
check_group() {
    group="$1"
    if oc get group "$group" &>/dev/null; then
        echo "Checking group '$group'... ✅ Exists"
    else
        echo "Checking group '$group'... ❌ Not found"
    fi
}

# Function to check if user is in a group
check_user_in_group() {
    user="$1"
    group="$2"
    if oc get group "$group" -o jsonpath="{.users[*]}" | grep -qw "$user"; then
        echo "Checking if user '$user' is in group '$group'... ✅ Yes"
    else
        echo "Checking if user '$user' is in group '$group'... ❌ No"
    fi
}

# Function to check if group has a role in a namespace
check_rolebinding() {
    group="$1"
    role="$2"
    namespace="$3"
    if oc get rolebinding -n "$namespace" -o json | jq -e \
        ".items[] | select(.roleRef.name==\"$role\") | select(.subjects[]? | select(.kind==\"Group\" and .name==\"$group\"))" &>/dev/null; then
        echo "Checking if group '$group' has $role role in project '$namespace'... ✅ Yes"
    else
        echo "Checking if group '$group' has $role role in project '$namespace'... ❌ No"
    fi
}

# Actual checks
check_group "commander"
check_group "pilot"

check_user_in_group "wozniak" "commander"
check_user_in_group "adlerin" "pilot"

check_rolebinding "commander" "edit" "apache"
check_rolebinding "commander" "edit" "gemini"
check_rolebinding "pilot" "view" "apache"

echo "=== Validation Complete ==="

