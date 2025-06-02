#!/bin/bash

echo "=== 🚀 Starting All EX280 Validation Scripts ==="

for script in check-*.sh; do
  if [[ -x "$script" ]]; then
    echo -e "\n=============================="
    echo "▶ Running script: $script"
    echo "=============================="
    ./"$script"
  else
    echo "⚠️  Skipping $script (not executable)"
  fi
done

echo -e "\n=== ✅ All Scripts Executed ==="
