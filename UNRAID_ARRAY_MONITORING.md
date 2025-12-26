# Unraid Array Health Monitoring

This document provides detailed information about the custom Unraid Array Health monitoring feature.

## Overview

The Unraid Exporter is a custom Python-based Prometheus exporter specifically designed to monitor Unraid array health, disk status, and SMART data. It provides insights that are critical for maintaining the health and reliability of your Unraid server.

## Architecture

```
┌─────────────────┐
│  Unraid Host    │
│  - /proc/mdstat │
│  - /dev/sd*     │
│  - /mnt/disk*   │
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│ Unraid Exporter     │
│ (Python Container)  │
│ - Reads mdstat      │
│ - Runs smartctl     │
│ - Parses df output  │
│ Port: 9101          │
└────────┬────────────┘
         │
         ▼
┌─────────────────┐
│  Prometheus     │
│  (Scrapes :9101)│
│  Every 30s      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Grafana      │
│  (Visualizes)   │
└─────────────────┘
```

## Metrics Collected

### Array Status Metrics

| Metric Name | Type | Description | Labels |
|------------|------|-------------|--------|
| `unraid_array_state` | Gauge | Array state (1=started, 0=stopped) | `array` |
| `unraid_array_disks_total` | Gauge | Total number of disks in array | `array` |
| `unraid_parity_check_running` | Gauge | Parity check status (1=running, 0=idle) | `array` |
| `unraid_parity_check_progress_percent` | Gauge | Parity check progress (0-100) | `array` |
| `unraid_parity_errors_total` | Gauge | Total parity errors detected | `array` |

### Disk Metrics

| Metric Name | Type | Description | Labels |
|------------|------|-------------|--------|
| `unraid_disk_status` | Gauge | Disk status (1=active, 0=standby, -1=disabled) | `disk`, `device` |
| `unraid_disk_size_bytes` | Gauge | Total disk size in bytes | `disk`, `device` |
| `unraid_disk_used_bytes` | Gauge | Used disk space in bytes | `disk`, `device` |

### SMART Metrics

| Metric Name | Type | Description | Labels |
|------------|------|-------------|--------|
| `unraid_disk_smart_temperature_celsius` | Gauge | Disk temperature from SMART | `disk`, `device` |
| `unraid_disk_smart_power_on_hours` | Gauge | Total power-on hours | `disk`, `device` |
| `unraid_disk_smart_reallocated_sectors` | Gauge | Count of reallocated sectors | `disk`, `device` |
| `unraid_disk_smart_health` | Gauge | SMART health (1=PASSED, 0=FAILED) | `disk`, `device` |

## Dashboard Panels

The **Unraid Array Health** dashboard includes:

1. **Array Status** - Shows if the array is started or stopped
2. **Total Disks** - Number of disks in the array
3. **Parity Check Status** - Current parity check state
4. **Parity Progress** - Gauge showing parity check completion
5. **Disk Space Usage** - Bar gauge with color-coded warnings
6. **Disk Temperatures** - Current temperatures with thresholds
7. **Temperature Trends** - Historical temperature graphs
8. **SMART Health** - Health status for all disks
9. **Space Available** - Time series of available space
10. **Space Used** - Time series of used space
11. **Power On Hours** - Disk age indicator
12. **Reallocated Sectors** - Disk degradation indicator
13. **Parity Errors** - Total errors found
14. **Disk Status** - Active/Standby/Disabled states

## Alert Thresholds

The dashboard uses the following color-coded thresholds:

### Disk Space Usage
- **Green**: 0-70%
- **Yellow**: 70-85%
- **Orange**: 85-95%
- **Red**: 95-100%

### Temperature
- **Green**: 0-40°C
- **Yellow**: 40-50°C
- **Orange**: 50-60°C
- **Red**: 60°C+

### Reallocated Sectors
- **Green**: 0
- **Yellow**: 1-10
- **Orange**: 10-50
- **Red**: 50+

### Power On Hours
- **Green**: 0-2 years (17,520 hours)
- **Yellow**: 2-5 years (43,800 hours)
- **Orange**: 5-8 years (70,080 hours)
- **Red**: 8+ years

## Customization

### Adding New SMART Attributes

Edit `unraid-exporter/unraid_exporter.py` and add to the `collect_smart_metrics()` method:

```python
# Example: Add SMART attribute for pending sectors
pending_sectors = GaugeMetricFamily(
    'unraid_disk_smart_pending_sectors',
    'Current pending sectors count',
    labels=['disk', 'device']
)

# Parse the attribute
pending_match = re.search(r'Current_Pending_Sector.*?(\d+)', result.stdout)
if pending_match:
    pending_sectors.add_metric([disk_name, device], float(pending_match.group(1)))

yield pending_sectors
```

### Adjusting Scrape Interval

Edit `prometheus/prometheus.yml`:

```yaml
- job_name: 'unraid-exporter'
  scrape_interval: 60s  # Change from 30s to 60s
  static_configs:
    - targets: ['unraid-exporter:9101']
```

### Custom Alerts

Create alert rules in Prometheus for critical conditions:

```yaml
groups:
  - name: unraid_alerts
    rules:
      - alert: HighDiskTemperature
        expr: unraid_disk_smart_temperature_celsius > 55
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk {{ $labels.disk }} temperature is high"

      - alert: SMARTHealthFailed
        expr: unraid_disk_smart_health == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Disk {{ $labels.disk }} SMART health check FAILED"

      - alert: DiskSpaceHigh
        expr: (unraid_disk_used_bytes / unraid_disk_size_bytes) * 100 > 90
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Disk {{ $labels.disk }} is over 90% full"
```

## Troubleshooting

### No SMART Data Showing

**Problem**: SMART metrics are not appearing in Grafana

**Solutions**:
1. Verify smartmontools is installed:
   ```bash
   docker exec unraid-exporter smartctl --version
   ```

2. Check exporter logs:
   ```bash
   docker-compose logs unraid-exporter
   ```

3. Verify disk access:
   ```bash
   docker exec unraid-exporter ls -la /dev/sd*
   ```

4. Test SMART manually:
   ```bash
   docker exec unraid-exporter smartctl -A /dev/sda
   ```

### Array Status Always Shows 0

**Problem**: Array state metric shows stopped even when array is running

**Solutions**:
1. Check if mdstat is accessible:
   ```bash
   docker exec unraid-exporter cat /host/proc/mdstat
   ```

2. Verify array is actually started in Unraid UI

3. Check exporter logs for parsing errors

### Parity Check Not Detected

**Problem**: Parity check running but dashboard shows idle

**Solutions**:
1. Verify mdstat shows the check:
   ```bash
   cat /proc/mdstat
   ```

2. Check if the exporter can read mdstat:
   ```bash
   docker exec unraid-exporter cat /host/proc/mdstat
   ```

3. Look for parsing errors in logs

## Performance Considerations

- **CPU Usage**: Minimal (~1-2% during SMART collection)
- **Memory**: ~30-50 MB
- **Disk I/O**: SMART queries cause brief disk activity every 30s
- **Network**: ~5-10 KB/s to Prometheus

### Reducing Load

If SMART collection causes issues with disk spin-down:

1. Increase scrape interval to 5 minutes:
   ```yaml
   scrape_interval: 300s
   ```

2. Disable SMART for specific disks by modifying the exporter code

3. Only query SMART during active hours using Prometheus recording rules

## Security Considerations

The Unraid Exporter runs with `privileged: true` because it needs:
- Raw disk access for SMART data
- Access to /proc/mdstat
- Access to /dev devices

**Best Practices**:
- Keep the exporter on an isolated Docker network
- Don't expose port 9101 to the internet
- Regularly update the container for security patches
- Monitor exporter logs for unusual activity

## Future Enhancements

Potential additions to the exporter:

- [ ] UPS status monitoring (if NUT is installed)
- [ ] Disk spin-up/spin-down events
- [ ] Array rebuild progress
- [ ] Cache pool statistics
- [ ] Docker volume usage
- [ ] VM disk usage
- [ ] User share statistics
- [ ] Network share connections
- [ ] Parity history and trends

## Contributing

To contribute improvements to the Unraid Exporter:

1. Edit `unraid-exporter/unraid_exporter.py`
2. Test your changes locally
3. Rebuild the container: `docker-compose build unraid-exporter`
4. Verify metrics: `curl http://localhost:9101/metrics`
5. Update this documentation

## References

- [Prometheus Python Client](https://github.com/prometheus/client_python)
- [smartmontools Documentation](https://www.smartmontools.org/)
- [Linux MD RAID](https://raid.wiki.kernel.org/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
