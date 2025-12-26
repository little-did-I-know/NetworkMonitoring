# Alert Rules Reference

This document provides a complete reference of all configured alert rules for the Unraid monitoring stack.

## Alert Severity Levels

- **🔥 Critical**: Immediate attention required, potential data loss or hardware failure
- **⚠️ Warning**: Non-urgent issue that should be addressed soon

## All Alert Rules

### 1. SMART Health Check Failed

**Severity**: 🔥 Critical

**Trigger Condition**:
```
unraid_disk_smart_health < 1
```

**Threshold**: SMART health status = FAILED

**Wait Time**: 1 minute

**Repeat Interval**: Every 1 hour

**Description**: A disk has failed its SMART health check, indicating imminent hardware failure. Immediate backup and disk replacement recommended.

**Example Alert**:
```
[CRITICAL] SMART Health Check Failed
Disk sdb (disk2) has FAILED SMART health check!
Action Required: Back up data and replace disk immediately
```

---

### 2. Critical Disk Temperature

**Severity**: 🔥 Critical

**Trigger Condition**:
```
unraid_disk_smart_temperature_celsius > 60
```

**Threshold**: Temperature > 60°C (140°F)

**Wait Time**: 5 minutes

**Repeat Interval**: Every 1 hour

**Description**: Disk temperature is critically high. Prolonged exposure can cause permanent damage.

**Example Alert**:
```
[CRITICAL] Critical Disk Temperature
Disk disk1 temperature is 65°C (threshold: 60°C)
Action Required: Check cooling, reduce load, or shutdown
```

**Recommended Actions**:
- Check server airflow and fans
- Verify room temperature
- Consider additional cooling
- Reduce disk I/O temporarily

---

### 3. High Disk Temperature

**Severity**: ⚠️ Warning

**Trigger Condition**:
```
unraid_disk_smart_temperature_celsius > 50
```

**Threshold**: Temperature > 50°C (122°F)

**Wait Time**: 10 minutes

**Repeat Interval**: Every 4 hours

**Description**: Disk temperature is elevated but not yet critical. Monitor closely.

**Example Alert**:
```
[WARNING] High Disk Temperature
Disk disk3 temperature is 55°C (threshold: 50°C)
Action Recommended: Monitor temperature trends
```

---

### 4. Disk Space Critical

**Severity**: 🔥 Critical

**Trigger Condition**:
```
(unraid_disk_used_bytes / unraid_disk_size_bytes) * 100 > 95
```

**Threshold**: Disk usage > 95%

**Wait Time**: 5 minutes

**Repeat Interval**: Every 1 hour

**Description**: Disk is almost full. Write operations may fail soon.

**Example Alert**:
```
[CRITICAL] Disk Space Critical
Disk disk2 is 97.5% full (threshold: 95%)
Available: 125 GB of 5 TB
Action Required: Free up space immediately
```

**Recommended Actions**:
- Delete unnecessary files
- Move data to other disks
- Expand storage capacity

---

### 5. Disk Space Warning

**Severity**: ⚠️ Warning

**Trigger Condition**:
```
(unraid_disk_used_bytes / unraid_disk_size_bytes) * 100 > 85
```

**Threshold**: Disk usage > 85%

**Wait Time**: 15 minutes

**Repeat Interval**: Every 4 hours

**Description**: Disk is filling up. Plan for cleanup or expansion.

**Example Alert**:
```
[WARNING] Disk Space Warning
Disk disk1 is 88% full (threshold: 85%)
Available: 600 GB of 5 TB
Action Recommended: Plan for cleanup or expansion
```

---

### 6. Reallocated Sectors Detected

**Severity**: ⚠️ Warning

**Trigger Condition**:
```
unraid_disk_smart_reallocated_sectors > 0
```

**Threshold**: Reallocated sectors > 0

**Wait Time**: 5 minutes

**Repeat Interval**: Every 4 hours

**Description**: Disk has reallocated sectors, indicating physical damage. Early sign of disk failure.

**Example Alert**:
```
[WARNING] Reallocated Sectors Detected
Disk sdc has 5 reallocated sectors - disk may be failing
Action Recommended: Monitor closely, plan for replacement
```

**What are Reallocated Sectors?**
- Bad sectors that have been remapped to spare area
- Indicates physical damage to disk surface
- Increasing count = disk is degrading
- Any count > 0 = monitor closely
- Count > 10 = plan replacement
- Count > 50 = replace immediately

---

### 7. Unraid Array Stopped

**Severity**: 🔥 Critical

**Trigger Condition**:
```
unraid_array_state < 1
```

**Threshold**: Array state = Stopped

**Wait Time**: 2 minutes

**Repeat Interval**: Every 1 hour

**Description**: The Unraid array has stopped unexpectedly. All data is inaccessible.

**Example Alert**:
```
[CRITICAL] Unraid Array Stopped
Unraid array has stopped unexpectedly!
Action Required: Check Unraid UI and logs immediately
```

**Recommended Actions**:
- Check Unraid web UI
- Review system logs
- Check for disk failures
- Verify parity disk status
- Do not force-start if disk missing

---

### 8. Parity Errors Detected

**Severity**: 🔥 Critical

**Trigger Condition**:
```
unraid_parity_errors_total > 0
```

**Threshold**: Parity errors > 0

**Wait Time**: 1 minute

**Repeat Interval**: Every 1 hour

**Description**: Parity check found errors, indicating data corruption or disk sync issues.

**Example Alert**:
```
[CRITICAL] Parity Errors Detected
Parity check found 3 errors - data corruption detected!
Action Required: Check disk health and run parity check
```

**What to Do**:
1. Note the number of errors
2. Check SMART data for all disks
3. Review Unraid logs
4. Run another parity check to verify
5. If errors persist, investigate disk health
6. Consider rebuilding parity if needed

---

## Alert States

Each alert can be in one of these states:

| State | Description |
|-------|-------------|
| **Normal** | Condition is not met, no alert |
| **Pending** | Condition met, waiting for "Wait Time" to elapse |
| **Alerting** | Condition persists beyond wait time, alert sent |
| **NoData** | No metrics available (exporter down) |
| **Error** | Error evaluating alert rule |

## Notification Timing

### Critical Alerts (🔥)
- **Initial Wait**: 1-5 minutes (depending on alert)
- **Repeat Interval**: Every 1 hour
- **Group Wait**: 10 seconds (batches similar alerts)

### Warning Alerts (⚠️)
- **Initial Wait**: 10-15 minutes (depending on alert)
- **Repeat Interval**: Every 4 hours
- **Group Wait**: 30 seconds

## Alert Email Format

### Subject Line
```
[CRITICAL] Alert Title
[WARNING] Alert Title
```

### Email Body
```
Alert: Critical Disk Temperature
Status: Alerting
Severity: critical

Disk: disk1
Device: /dev/sdb
Current Temperature: 65°C
Threshold: 60°C

Time: 2024-01-15 14:32:15 UTC

Dashboard: http://YOUR-IP:3000/d/unraid-array-health
```

## Silencing Alerts

### During Maintenance

To silence all alerts during planned maintenance:

1. Grafana → Alerting → Silences
2. Create new silence
3. Duration: 2 hours (or as needed)
4. Comment: "Scheduled maintenance"

### For Specific Disk

Create a silence with matcher:
- **Label**: `disk`
- **Operator**: `=`
- **Value**: `disk1`

### For Specific Alert

Create a silence with matcher:
- **Label**: `alertname`
- **Operator**: `=`
- **Value**: `High Disk Temperature`

## Modifying Alert Rules

### Change Temperature Threshold

Edit `grafana/provisioning/alerting/rules.yml`:

```yaml
# Find disk_temp_critical
- evaluator:
    params:
      - 65  # Change from 60 to 65°C
    type: gt
```

### Change Wait Time

```yaml
for: 10m  # Change from 5m to 10 minutes
```

### Change Severity

```yaml
labels:
  severity: warning  # Change from critical to warning
```

### Disable an Alert

Comment out the entire rule:

```yaml
# - uid: disk_temp_warning
#   title: High Disk Temperature
#   ... entire rule ...
```

After changes:
```bash
docker-compose restart grafana
```

## Alert Dependencies

Some alerts depend on the Unraid Exporter:

| Alert | Requires | Port |
|-------|----------|------|
| SMART Health Failed | unraid-exporter | 9101 |
| Disk Temperature | unraid-exporter | 9101 |
| Disk Space | unraid-exporter | 9101 |
| Reallocated Sectors | unraid-exporter | 9101 |
| Array Stopped | unraid-exporter | 9101 |
| Parity Errors | unraid-exporter | 9101 |

If Unraid Exporter is down, alerts will show "NoData" state.

## Testing Alert Rules

### Manual Test via Prometheus Query

```bash
# Check if condition would trigger
curl -s 'http://localhost:9090/api/v1/query?query=unraid_disk_smart_temperature_celsius>60' | jq

# View all disk temperatures
curl -s 'http://localhost:9090/api/v1/query?query=unraid_disk_smart_temperature_celsius' | jq
```

### Force Alert Trigger (Testing)

Temporarily lower threshold to force trigger:

1. Edit `rules.yml`
2. Change threshold to guaranteed-to-trigger value
3. Restart Grafana
4. Wait for alert
5. **Restore original threshold**

## Best Practices

1. **Don't ignore warnings** - They're early indicators of problems
2. **Test alerts regularly** - Verify email delivery works
3. **Document customizations** - Track changes to thresholds
4. **Monitor alert fatigue** - Adjust thresholds if too noisy
5. **Use silences wisely** - Don't permanently disable important alerts
6. **Review alert history** - Learn from past incidents
7. **Keep contact info updated** - Ensure alerts reach the right people

## Alert Priority Matrix

| Issue | Severity | Time Sensitivity | Impact |
|-------|----------|------------------|--------|
| SMART Failed | Critical | Hours | Data loss imminent |
| Parity Errors | Critical | Days | Data integrity compromised |
| Array Stopped | Critical | Minutes | Complete data unavailability |
| Temp > 60°C | Critical | Hours | Hardware damage risk |
| Space > 95% | Critical | Hours | Write failures |
| Reallocated Sectors | Warning | Weeks | Early failure sign |
| Temp > 50°C | Warning | Days | Reduced lifespan |
| Space > 85% | Warning | Weeks | Plan capacity |

## Further Reading

- [Grafana Alerting Rules](https://grafana.com/docs/grafana/latest/alerting/alerting-rules/)
- [Prometheus Alerting](https://prometheus.io/docs/alerting/latest/)
- [SMART Attribute Reference](https://en.wikipedia.org/wiki/S.M.A.R.T.)
- [Unraid Array Management](https://wiki.unraid.net/UnRAID_Manual)
