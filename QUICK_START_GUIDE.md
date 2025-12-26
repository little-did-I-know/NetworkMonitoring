# Quick Start Guide - Grafana for Beginners

Welcome! This guide will help you get started with your Unraid monitoring dashboards, even if you've never used Grafana before.

## First Login

1. **Open Grafana** in your browser:
   ```
   http://YOUR-UNRAID-IP:3000
   ```

2. **Login with default credentials:**
   - Username: `admin`
   - Password: `admin` (or what you set in `.env`)

3. **Change your password** when prompted (recommended!)

4. **You'll see the Home Dashboard automatically** - this is your starting point!

## Understanding the Home Dashboard

The home dashboard gives you an overview of everything:

### Top Section - Quick Status
- **Array Status**: Is your Unraid array running?
- **CPU Usage**: How much CPU is being used right now
- **Memory Usage**: How much RAM is being used
- **GPU Temperature**: Your NVIDIA GPU temperature
- **Running Containers**: How many Docker containers are active

### Middle Section - Dashboard Links
Quick links to all detailed dashboards:
- **System Overview**: Detailed CPU, RAM, network stats
- **Docker Containers**: All container metrics
- **Array Health**: Disk health and SMART data
- **GPU Monitoring**: Detailed GPU stats

### Charts Section
- **CPU & Memory Trends**: See usage over time
- **Network Traffic**: Upload/download speeds
- **Disk Temperatures**: Temperature for each disk
- **Disk Space Usage**: How full each disk is

### Bottom Section - Quick Stats
Summary of key server information

## Navigating Grafana

### Switching Dashboards

**Method 1: Dashboard Selector (Top-Left)**
1. Click the "📊" icon (top-left corner)
2. Click "Dashboards"
3. Select any dashboard from the list

**Method 2: Home Dashboard Links**
- Click the links in the dashboard navigation boxes

**Available Dashboards:**
- **Home** - Overview of everything (you start here)
- **Unraid System Overview** - CPU, RAM, disk, network
- **Docker Containers** - All container metrics
- **Hardware Sensors** - Temperatures and sensors
- **Unraid Array Health** - Disk health and SMART data
- **NVIDIA GPU Monitoring** - GPU stats

### Changing the Time Range

**Time Picker (Top-Right)**
1. Click the time range (e.g., "Last 1 hour")
2. Select a preset:
   - Last 5 minutes
   - Last 15 minutes
   - Last 1 hour
   - Last 6 hours
   - Last 24 hours
   - Last 7 days
   - Custom range

**Quick Tip:** Use "Last 1 hour" for real-time monitoring, "Last 24 hours" for daily trends

### Auto-Refresh

All dashboards automatically refresh every 30 seconds to show the latest data.

**To change refresh rate:**
1. Click the refresh dropdown (top-right, next to time picker)
2. Select: 5s, 10s, 30s, 1m, 5m, or Off

### Zooming In on Charts

**To zoom in on a specific time period:**
1. Click and drag across any chart
2. The chart will zoom to that timeframe
3. Click "Zoom out" (appears above chart) to reset

### Full Screen View

**To view a panel in full screen:**
1. Hover over any panel/chart
2. Click the title
3. Select "View" from the menu
4. Press `Esc` to exit full screen

## Understanding the Dashboards

### 1. System Overview Dashboard

**What to look for:**
- **CPU Usage**: Should be below 80% normally
  - Green: 0-70% (normal)
  - Yellow: 70-90% (busy)
  - Red: 90-100% (very busy)

- **Memory Usage**: Depends on your workload
  - Green: 0-70% (normal)
  - Yellow: 70-90% (high)
  - Red: 90-100% (critical - may cause issues)

- **Network Traffic**: Shows your upload/download speeds
  - Spikes are normal during file transfers
  - Consistent high usage may indicate issues

- **Disk I/O**: Read/write speeds
  - High during parity checks or large file operations

### 2. Docker Containers Dashboard

**What to look for:**
- **Running Containers**: Total active containers
- **CPU per Container**: Which containers use the most CPU
- **Memory per Container**: Which containers use the most RAM
- **Network per Container**: Which containers transfer the most data

**Use this to:**
- Identify resource-heavy containers
- Spot containers with memory leaks (continuously growing memory)
- Monitor container health

### 3. Unraid Array Health Dashboard

**What to look for:**
- **Array Status**: MUST be "STARTED" (green)
  - Red = Array stopped (problem!)

- **Parity Check Status**:
  - Idle (green) = no check running
  - Running (yellow) = parity check in progress

- **Disk Temperatures**:
  - Green: 0-40°C (cool)
  - Yellow: 40-50°C (warm)
  - Orange: 50-60°C (hot)
  - Red: 60°C+ (too hot! check cooling)

- **SMART Health**: MUST be "PASSED" (green)
  - Failed = Disk is failing! Back up data immediately!

- **Disk Space Usage**:
  - Green: 0-70% (plenty of space)
  - Yellow: 70-85% (getting full)
  - Orange: 85-95% (almost full)
  - Red: 95-100% (critical - free up space!)

- **Reallocated Sectors**:
  - 0 = Healthy (green)
  - 1-10 = Monitor (yellow)
  - 10+ = Plan replacement (orange)
  - 50+ = Replace immediately (red)

### 4. GPU Monitoring Dashboard

**What to look for:**
- **GPU Temperature**:
  - Green: 0-70°C (normal)
  - Yellow: 70-80°C (warm)
  - Orange: 80-90°C (hot)
  - Red: 90°C+ (too hot!)

- **GPU Utilization**: How much GPU is being used
  - 0-10%: Idle
  - 10-60%: Light usage (video playback, basic encoding)
  - 60-100%: Heavy usage (gaming, AI, intense encoding)

- **VRAM Usage**: GPU memory usage
  - Depends on workload
  - 95%+ may cause performance issues

- **Power Consumption**: Current power draw
  - Varies by GPU model and load

### 5. Hardware Sensors Dashboard

**What to look for:**
- **CPU Temperature**: Should stay below 80°C
- **Disk Temperatures**: See Array Health section above
- **Fan Speeds**: Should increase with temperature
- **Power/Voltage**: Informational

## Email Alerts

You'll receive automatic email alerts for:

**Critical Issues** (immediate):
- SMART health failed
- Array stopped
- Temperature too high (disk/GPU)
- Disk almost full (95%+)
- Parity errors

**Warnings** (less urgent):
- High temperatures
- Disk getting full (85%+)
- Reallocated sectors detected

**To view alert rules:**
1. Click "Alerting" (left sidebar, bell icon)
2. Click "Alert rules"
3. See all configured alerts and their status

**To check alert history:**
1. Alerting → Alert rules
2. Click on any alert
3. See when it triggered and resolved

## Customizing Your View

### Changing Dashboard Theme

**Switch between Light and Dark themes:**
1. Click your profile icon (bottom-left)
2. Click "Preferences"
3. Select "Dark" or "Light" under Theme
4. Click "Save"

### Favoriting Dashboards

**To quickly access your favorite dashboards:**
1. Open any dashboard
2. Click the ⭐ (star) icon next to the dashboard name
3. Your favorites appear in the dashboard selector

### Creating Custom Time Ranges

**For specific date ranges:**
1. Click time picker (top-right)
2. Select "Custom time range"
3. Choose start and end dates
4. Click "Apply time range"

## Tips for Monitoring

### Daily Monitoring (Quick Check)

Use the **Home Dashboard**:
1. Check all gauges are green
2. Ensure Array Status = STARTED
3. Verify no unusual spikes in charts
4. Takes ~30 seconds

### Weekly Monitoring (Detailed)

1. **Check Array Health Dashboard:**
   - Verify all SMART statuses = PASSED
   - Check disk temperatures are normal
   - Ensure no reallocated sectors

2. **Check Docker Containers:**
   - Look for memory leaks (continuously growing memory)
   - Identify resource-heavy containers

3. **Review Alerts:**
   - Alerting → Alert rules
   - Check if any warnings need attention

### Monthly Monitoring

1. **Review trends over 30 days:**
   - Set time range to "Last 30 days"
   - Look for gradual changes in:
     - Disk space consumption
     - Temperature trends
     - Resource usage patterns

2. **Check Power-On Hours:**
   - Array Health → Power On Hours panel
   - Track disk age

## Common Questions

### Q: Why is my dashboard empty/showing "No data"?

**Possible causes:**
1. **Services not running:**
   ```bash
   docker-compose ps
   ```
   All should show "Up"

2. **Prometheus not scraping:**
   - Go to http://YOUR-IP:9090/targets
   - All targets should be "UP"

3. **Wrong time range:**
   - Try changing to "Last 5 minutes"

### Q: How do I see older data?

Change the time range (top-right):
- Last 24 hours: Yesterday's data
- Last 7 days: Weekly trends
- Custom range: Specific dates

**Note:** Data is kept for 30 days by default (configurable in prometheus.yml)

### Q: Can I export/download charts?

**Yes!** For any panel:
1. Click panel title
2. Select "More..." → "Inspect" → "Data"
3. Click "Download CSV"

Or:
1. Click "Share" icon (top-right of dashboard)
2. Select "Export" → "Save to file"

### Q: How do I add more panels?

The dashboards are pre-configured, but you can:
1. Click "Dashboard settings" (gear icon, top-right)
2. Select "Make editable"
3. Click "Add" → "Visualization"
4. Select metric and configure

**Caution:** Custom changes may be overwritten on updates

### Q: What if I break something?

**Dashboards:** They're provisioned from files, so:
```bash
docker-compose restart grafana
```
This reloads all dashboards from configuration files.

**Can't login?** Reset password:
```bash
docker exec -it grafana grafana-cli admin reset-admin-password admin
```

## Keyboard Shortcuts

- **`d` + `h`**: Go to home dashboard
- **`d` + `s`**: Open dashboard selector
- **`t` + `z`**: Zoom out (reset time range)
- **`Esc`**: Exit full screen
- **`?`**: Show all keyboard shortcuts

## Getting Help

**Resources:**
- README.md - Complete documentation
- EMAIL_ALERTS_SETUP.md - Email configuration
- ALERT_RULES.md - All alert rules explained
- UNRAID_ARRAY_MONITORING.md - Disk health details

**Troubleshooting:**
1. Check README.md "Troubleshooting" section
2. View logs: `docker-compose logs grafana`
3. Check Prometheus targets: http://YOUR-IP:9090/targets

## Next Steps

Now that you know the basics:

1. ✅ **Explore each dashboard** - Click through and see what's available
2. ✅ **Set up email alerts** - See EMAIL_ALERTS_SETUP.md
3. ✅ **Check alerts daily** - Use the Home dashboard
4. ✅ **Review trends weekly** - Look for patterns
5. ✅ **Customize time ranges** - Find what works for you

**Remember:** The dashboards auto-refresh every 30 seconds, so you always see current data!

## Pro Tips

1. **Bookmark the Home Dashboard:**
   `http://YOUR-IP:3000/d/home-dashboard`

2. **Use multiple screens:**
   - Home Dashboard on one screen
   - Detailed dashboard on another

3. **Mobile Access:**
   - Grafana works on mobile browsers
   - Use landscape mode for best view

4. **Set browser to auto-refresh:**
   - Keep dashboard open 24/7
   - Use dark theme to save power

5. **Learn by exploring:**
   - Click everything!
   - You can't break anything
   - Restart Grafana to reset

Happy Monitoring! 📊
