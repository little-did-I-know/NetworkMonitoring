#!/bin/bash

# Script to unwrap dashboard JSON files for file provisioning
# Grafana file provisioning expects the dashboard object directly, not wrapped

cd "$(dirname "$0")/grafana/provisioning/dashboards" || exit 1

for file in *.json; do
  echo "Fixing $file..."

  # Create backup
  cp "$file" "$file.bak"

  # Extract just the dashboard object using jq
  jq '.dashboard' "$file.bak" > "$file"

  echo "  ✓ Fixed $file"
done

echo ""
echo "All dashboards fixed! Backups saved as *.json.bak"
echo "You can now restart Grafana: docker-compose restart grafana"
