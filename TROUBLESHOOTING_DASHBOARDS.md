# Dashboard Troubleshooting Guide

## Why Are My Dashboards Empty?

If you're seeing dashboards but no data, follow these steps to diagnose and fix the issue.

## Step 1: Verify All Services Are Running

First, check if all containers are running:

```bash
cd /path/to/NetworkMonitoring
docker-compose ps
```

**Expected output:** All services should show "Up"

```
NAME                    STATUS
grafana                 Up
prometheus              Up
node-exporter           Up
cadvisor                Up
unraid-exporter         Up
nvidia-gpu-exporter     Up
```

**If any service shows "Exit" or is missing:**

```bash
# View logs for the failed service
docker-compose logs [service-name]

# Restart all services
docker-compose restart

# Or rebuild and restart
docker-compose up -d --build
```

## Step 2: Check Prometheus is Collecting Data

Open Prometheus in your browser:

```
http://YOUR-UNRAID-IP:9090
```

### Check Targets

1. Click **Status** → **Targets** (top menu)
2. You should see:
   - prometheus (UP)
   - node-exporter (UP)
   - cadvisor (UP)
   - unraid-exporter (UP)
   - nvidia-gpu (UP)

**If any target shows "DOWN":**

- **Red/DOWN status** = Service not reachable
- Check the service is running: `docker-compose ps`
- Check logs: `docker-compose logs [service-name]`
- Verify port is correct in `prometheus/prometheus.yml`

**Common issues:**
- **cAdvisor DOWN** - Check port is 8070 (not 8080) in `prometheus.yml`
- **Unraid Exporter DOWN** - May need to rebuild: `docker-compose up -d --build unraid-exporter`
- **GPU Exporter DOWN** - Verify nvidia-smi works: `nvidia-smi`

### Test a Query

In Prometheus:

1. Go to **Graph** tab
2. Enter this query: `up`
3. Click **Execute**

**Expected:** You should see `up{instance="...", job="..."}` with value `1` for each service

**Try more queries:**
```
# Check CPU metrics
node_cpu_seconds_total

# Check memory metrics
node_memory_MemTotal_bytes

# Check disk metrics
unraid_disk_smart_temperature_celsius

# Check GPU metrics
nvidia_gpu_temperature_celsius
```

**If queries return "No data":**
- The exporter isn't collecting metrics
- Check the specific service logs

## Step 3: Check Grafana Datasource

Open Grafana:

```
http://YOUR-UNRAID-IP:3000
```

### Verify Prometheus Datasource

1. Click **⚙️ Configuration** (gear icon, left sidebar)
2. Click **Data sources**
3. Click **Prometheus**

**Check settings:**
- **URL:** Should be `http://prometheus:9090`
- **Access:** Should be `Server (default)`

**Test the connection:**
1. Scroll down to bottom of page
2. Click **Save & test**
3. Should show: ✅ "Data source is working"

**If datasource test fails:**

```bash
# Restart Grafana
docker-compose restart grafana

# Check if Prometheus is accessible from Grafana
docker exec grafana wget -O- http://prometheus:9090/api/v1/query?query=up
```

## Step 4: Check Dashboard Time Range

**This is the most common issue!**

The dashboards might be looking at a time when no data exists yet.

### Fix the Time Range:

1. Look at **top-right** corner of dashboard
2. Click the time range (e.g., "Last 1 hour")
3. Select **Last 5 minutes** or **Last 15 minutes**
4. Click **Apply**

**Why this happens:**
- If you just started the stack, there's no data from 1 hour ago
- Metrics collection started only a few minutes ago

### Set Default Time Range:

To avoid this in the future:
1. Set time range to "Last 5 minutes"
2. Click ⭐ (star) icon to save as default

## Step 5: Verify Dashboard Datasource

If dashboards are still empty:

1. Open any dashboard
2. Click any panel title
3. Select **Edit**
4. Check **Queries** section at bottom
5. Verify **Data source** dropdown shows "Prometheus"

**If datasource is wrong or missing:**
1. Click **Data source** dropdown
2. Select **Prometheus**
3. Click **Apply** (top-right)

## Step 6: Check for Specific Metric Issues

### No System Metrics (CPU, Memory, Disk)

**Check Node Exporter:**

```bash
# Test node-exporter directly
curl http://localhost:9100/metrics | grep node_cpu

# Check container logs
docker-compose logs node-exporter
```

**If no output:**
- Node exporter isn't running or accessible
- Restart: `docker-compose restart node-exporter`

### No Docker Container Metrics

**Check cAdvisor:**

```bash
# Test cAdvisor directly
curl http://localhost:8070/metrics | grep container_

# Check logs
docker-compose logs cadvisor
```

**Common issue:** Port conflict
- In `docker-compose.yml`, cAdvisor should use port 8070
- In `prometheus.yml`, target should be `cadvisor:8070`

### No Unraid Array Metrics

**Check Unraid Exporter:**

```bash
# Test exporter directly
curl http://localhost:9101/metrics | grep unraid_

# Check logs
docker-compose logs unraid-exporter
```

**If exporter fails to start:**

```bash
# Rebuild the container
docker-compose up -d --build unraid-exporter

# Check for errors
docker-compose logs unraid-exporter
```

**Common issues:**
- Missing smartmontools: Exporter includes it, should work
- Permission issues: Container runs as privileged
- /dev access: Verify volumes are mounted correctly

### No GPU Metrics

**Check nvidia-smi on host:**

```bash
nvidia-smi
```

**If this doesn't work:**
- NVIDIA drivers not installed
- GPU not detected by system

**Check GPU exporter:**

```bash
# Test exporter
curl http://localhost:9835/metrics | grep nvidia_gpu

# Check logs
docker-compose logs nvidia-gpu-exporter
```

**If GPU exporter fails:**
- Verify nvidia-smi path: `/usr/bin/nvidia-smi`
- Check device access in docker-compose.yml
- May need to adjust device paths for your system

## Step 7: Dashboard Auto-Provisioning Issues

**Problem:** Dashboards don't appear at all

**Solution:**

Check if dashboards are provisioned:

```bash
# List dashboard files
ls -la grafana/provisioning/dashboards/

# Should show:
# - default.yml
# - home-dashboard.json
# - unraid-system-overview.json
# - docker-containers.json
# - hardware-sensors.json
# - unraid-array-health.json
# - nvidia-gpu-monitoring.json
```

**If files are missing:**
- Re-download/clone the repository
- Verify you're in the correct directory

**Restart Grafana to reload:**

```bash
docker-compose restart grafana

# Wait 30 seconds, then refresh browser
```

## Step 8: Manual Dashboard Check

If auto-provisioning isn't working, verify manually:

1. In Grafana, click **📊 Dashboards** (left sidebar)
2. Click **Browse**
3. You should see all dashboards listed

**If no dashboards appear:**

```bash
# Check Grafana logs
docker-compose logs grafana | grep -i dashboard
docker-compose logs grafana | grep -i provision

# Look for errors like:
# - "Failed to load dashboard"
# - "Invalid JSON"
# - "Datasource not found"
```

## Step 9: Reset and Start Fresh

If nothing works, reset everything:

### Option 1: Restart Stack

```bash
# Stop everything
docker-compose down

# Clear Grafana data (keeps configuration)
rm -rf grafana/data/*

# Restart
docker-compose up -d

# Wait 1 minute for services to start
sleep 60
```

### Option 2: Complete Reset

```bash
# Stop and remove everything
docker-compose down -v

# Remove data directories
rm -rf grafana/data/* prometheus/data/*

# Recreate and set permissions
mkdir -p grafana/data prometheus/data
chmod -R 777 grafana/data prometheus/data

# Start fresh
docker-compose up -d
```

## Step 10: Verify Specific Dashboard Queries

Test each dashboard type:

### Test System Metrics:

In Grafana, create a new panel:
1. Click **+ Create** → **Dashboard**
2. Click **Add visualization**
3. Select **Prometheus** datasource
4. Enter query: `100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
5. Click **Run query**

**Should show:** CPU usage percentage

### Test Unraid Metrics:

Query: `unraid_array_state`

**Should show:** 1 (if array is started) or 0 (if stopped)

### Test Docker Metrics:

Query: `count(container_last_seen{name!=""})`

**Should show:** Number of running containers

### Test GPU Metrics:

Query: `nvidia_gpu_temperature_celsius`

**Should show:** GPU temperature

## Common Error Messages

### "Datasource not found"

**Fix:**
1. Go to Configuration → Data sources
2. Add Prometheus datasource
3. URL: `http://prometheus:9090`
4. Click "Save & test"

### "No data" in panels

**Causes:**
- Wrong time range (see Step 4)
- Service not running (see Step 1)
- Prometheus not scraping (see Step 2)

### "Query error: context deadline exceeded"

**Causes:**
- Prometheus overloaded
- Query too complex
- Time range too large

**Fix:**
- Reduce time range
- Restart Prometheus: `docker-compose restart prometheus`

### "Cannot read property of undefined"

**Causes:**
- Metric doesn't exist
- Typo in query
- Service not providing metric

**Fix:**
- Check Prometheus → Graph tab
- Verify metric exists with: `{__name__=~"metric_prefix.*"}`

## Getting Help

If you're still stuck, gather this info:

```bash
# Check all container status
docker-compose ps

# Get logs from all services
docker-compose logs > logs.txt

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq . > targets.json

# Test metrics endpoints
curl http://localhost:9100/metrics | head -20 > node-exporter-test.txt
curl http://localhost:9101/metrics | head -20 > unraid-exporter-test.txt
curl http://localhost:8070/metrics | head -20 > cadvisor-test.txt
curl http://localhost:9835/metrics | head -20 > gpu-exporter-test.txt
```

## Quick Diagnostic Script

Save this as `diagnose.sh` and run it:

```bash
#!/bin/bash

echo "=== Unraid Monitoring Diagnostics ==="
echo ""

echo "1. Container Status:"
docker-compose ps
echo ""

echo "2. Prometheus Targets:"
curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | "\(.labels.job): \(.health)"'
echo ""

echo "3. Testing Metrics Endpoints:"
echo -n "  Node Exporter: "
curl -s http://localhost:9100/metrics | grep -c "node_" && echo "OK" || echo "FAIL"

echo -n "  Unraid Exporter: "
curl -s http://localhost:9101/metrics | grep -c "unraid_" && echo "OK" || echo "FAIL"

echo -n "  cAdvisor: "
curl -s http://localhost:8070/metrics | grep -c "container_" && echo "OK" || echo "FAIL"

echo -n "  GPU Exporter: "
curl -s http://localhost:9835/metrics | grep -c "nvidia_gpu_" && echo "OK" || echo "FAIL"

echo ""
echo "4. Sample Metrics:"
curl -s http://localhost:9101/metrics | grep "unraid_array_state" | head -1

echo ""
echo "=== Diagnostics Complete ==="
```

Run it:
```bash
chmod +x diagnose.sh
./diagnose.sh
```

This will show you exactly what's working and what's not!
