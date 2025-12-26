#!/bin/bash

# Complete fix for Grafana provisioning issues
# This script fixes dashboard format and datasource issues

echo "==========================================="
echo "Grafana Monitoring Stack - Complete Fix"
echo "==========================================="
echo ""

cd "$(dirname "$0")" || exit 1

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq is not installed. Installing it now..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y jq
    elif command -v apk &> /dev/null; then
        apk add jq
    else
        echo "❌ Cannot install jq automatically. Please install it manually:"
        echo "   Unraid: Install 'Nerd Tools' plugin and enable jq"
        echo "   Or run: wget https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -O /usr/local/bin/jq && chmod +x /usr/local/bin/jq"
        exit 1
    fi
fi

echo "Step 1: Stopping Grafana..."
docker-compose stop grafana

echo ""
echo "Step 2: Fixing dashboard JSON format..."
cd grafana/provisioning/dashboards || exit 1

for file in *.json; do
  if [ -f "$file" ]; then
    echo "  Fixing $file..."

    # Create backup
    cp "$file" "$file.bak"

    # Extract just the dashboard object
    if jq -e '.dashboard' "$file.bak" > /dev/null 2>&1; then
      jq '.dashboard' "$file.bak" > "$file"
      echo "    ✓ Fixed $file"
    else
      echo "    ⚠️  $file is already in correct format or has errors"
      mv "$file.bak" "$file"  # Restore if there was an issue
    fi
  fi
done

cd ../../..

echo ""
echo "Step 3: Removing Grafana database to force clean provisioning..."
rm -f grafana/data/grafana.db
rm -f grafana/data/grafana.db-shm
rm -f grafana/data/grafana.db-wal

echo ""
echo "Step 4: Ensuring correct permissions..."
chmod -R 777 grafana/data prometheus/data

echo ""
echo "Step 5: Starting all services..."
docker-compose up -d

echo ""
echo "Step 6: Waiting for services to initialize (30 seconds)..."
sleep 30

echo ""
echo "Step 7: Checking service status..."
docker-compose ps

echo ""
echo "==========================================="
echo "Fix Complete!"
echo "==========================================="
echo ""
echo "Next steps:"
echo "1. Open Grafana: http://$(hostname -I | awk '{print $1}'):3000"
echo "2. Login with: admin / admin (or your configured password)"
echo "3. Dashboards should now load correctly"
echo "4. Check for errors: docker-compose logs grafana | grep -i error"
echo ""
echo "Dashboard backups saved in: grafana/provisioning/dashboards/*.json.bak"
