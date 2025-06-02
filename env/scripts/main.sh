#!/bin/bash

echo "=== 🚀 EX280 Environment Setup - Main Script ==="
echo "Running all setup scripts..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Loop through all q*.sh scripts in sorted order
for script in "$SCRIPT_DIR"/q*.sh; do
  echo ""
  echo "▶️ Running script: $(basename "$script")"
  echo "=============================="
  
  # Execute the script
  bash "$script"
  
  STATUS=$?
  if [ $STATUS -eq 0 ]; then
    echo "✅ $(basename "$script") completed successfully"
  else
    echo "❌ $(basename "$script") failed with status $STATUS"
  fi
done

echo ""
echo "=== ✅ All Scripts Executed ==="

