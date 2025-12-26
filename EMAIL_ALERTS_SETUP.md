# Email Alerts Setup Guide

This guide will walk you through setting up email alerts for critical disk issues on your Unraid monitoring stack.

## Overview

The monitoring stack includes automatic email alerts for:
- Disk failures (SMART health)
- High temperatures
- Low disk space
- Array issues
- Parity errors
- Reallocated sectors

## Quick Start

### 1. Edit Environment File

Copy and edit your `.env` file:

```bash
cp .env.example .env
nano .env
```

### 2. Configure Email Settings

Update these critical values in `.env`:

```bash
# Enable alerts
SMTP_ENABLED=true

# Your email provider settings
SMTP_HOST=smtp.gmail.com:587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Alert recipient
ALERT_EMAIL_TO=admin@yourdomain.com
```

### 3. Restart Grafana

```bash
docker-compose restart grafana
```

### 4. Test Alerts

1. Open Grafana: `http://YOUR-UNRAID-IP:3000`
2. Go to **Alerting** → **Contact points**
3. Click **Email Alerts** → **Test**
4. Check your email!

## Provider-Specific Setup

### Gmail

Gmail requires an "App Password" instead of your regular password.

**Step-by-step:**

1. **Enable 2-Step Verification:**
   - Go to [Google Account Security](https://myaccount.google.com/security)
   - Enable 2-Step Verification if not already enabled

2. **Generate App Password:**
   - Visit [App Passwords](https://myaccount.google.com/apppasswords)
   - Select "Mail" and "Other (Custom name)"
   - Enter "Unraid Monitoring"
   - Click **Generate**
   - Copy the 16-character password

3. **Configure `.env`:**
   ```bash
   SMTP_ENABLED=true
   SMTP_HOST=smtp.gmail.com:587
   SMTP_USER=yourusername@gmail.com
   SMTP_PASSWORD=abcd efgh ijkl mnop  # The 16-char app password
   SMTP_FROM_ADDRESS=yourusername@gmail.com
   SMTP_FROM_NAME=Unraid Monitoring
   ALERT_EMAIL_TO=admin@gmail.com
   ```

4. **Restart and Test:**
   ```bash
   docker-compose restart grafana
   ```

### Outlook / Hotmail

**Configuration:**

```bash
SMTP_ENABLED=true
SMTP_HOST=smtp-mail.outlook.com:587
SMTP_USER=yourusername@outlook.com
SMTP_PASSWORD=your-password
SMTP_FROM_ADDRESS=yourusername@outlook.com
SMTP_FROM_NAME=Unraid Monitoring
ALERT_EMAIL_TO=admin@outlook.com
```

**Notes:**
- Use your regular Outlook password
- If you have 2FA enabled, you may need an app password
- Generate app password at: [Microsoft Account Security](https://account.microsoft.com/security)

### Office 365

**Configuration:**

```bash
SMTP_ENABLED=true
SMTP_HOST=smtp.office365.com:587
SMTP_USER=your.name@company.com
SMTP_PASSWORD=your-password
SMTP_FROM_ADDRESS=alerts@company.com
SMTP_FROM_NAME=Unraid Monitoring
ALERT_EMAIL_TO=admin@company.com
```

**Notes:**
- Contact your IT department if you have issues
- Some organizations block external SMTP
- May require app password or OAuth

### Yahoo Mail

**Configuration:**

```bash
SMTP_ENABLED=true
SMTP_HOST=smtp.mail.yahoo.com:587
SMTP_USER=yourusername@yahoo.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_ADDRESS=yourusername@yahoo.com
SMTP_FROM_NAME=Unraid Monitoring
ALERT_EMAIL_TO=admin@yahoo.com
```

**Generate App Password:**
1. Go to [Yahoo Account Security](https://login.yahoo.com/account/security)
2. Click **Generate app password**
3. Select "Other App" and enter "Unraid Monitoring"
4. Use the generated password

### ProtonMail

ProtonMail requires the ProtonMail Bridge for SMTP access.

**Configuration:**

```bash
SMTP_ENABLED=true
SMTP_HOST=127.0.0.1:1025  # Default Bridge port
SMTP_USER=yourusername@protonmail.com
SMTP_PASSWORD=bridge-password
SMTP_FROM_ADDRESS=yourusername@protonmail.com
SMTP_FROM_NAME=Unraid Monitoring
SMTP_SKIP_VERIFY=true
ALERT_EMAIL_TO=admin@protonmail.com
```

### Custom SMTP Server

For self-hosted or corporate email servers:

```bash
SMTP_ENABLED=true
SMTP_HOST=mail.yourdomain.com:587
SMTP_USER=alerts@yourdomain.com
SMTP_PASSWORD=your-password
SMTP_FROM_ADDRESS=unraid@yourdomain.com
SMTP_FROM_NAME=Unraid Monitoring
SMTP_SKIP_VERIFY=false  # Set to true for self-signed certs
ALERT_EMAIL_TO=admin@yourdomain.com
```

**Common SMTP Ports:**
- **587**: STARTTLS (most common, recommended)
- **465**: SSL/TLS
- **25**: Unencrypted (not recommended)

## Alert Configuration

### All Configured Alerts

| Alert Name | Severity | Threshold | Wait Time | Description |
|-----------|----------|-----------|-----------|-------------|
| SMART Health Failed | Critical | Health = FAILED | 1 minute | Disk failed SMART check |
| Critical Disk Temperature | Critical | > 60°C | 5 minutes | Disk dangerously hot |
| High Disk Temperature | Warning | > 50°C | 10 minutes | Disk temperature elevated |
| Disk Space Critical | Critical | > 95% | 5 minutes | Disk almost full |
| Disk Space Warning | Warning | > 85% | 15 minutes | Disk filling up |
| Reallocated Sectors | Warning | > 0 | 5 minutes | Disk showing degradation |
| Array Stopped | Critical | State = Stopped | 2 minutes | Array not running |
| Parity Errors | Critical | Errors > 0 | 1 minute | Data corruption detected |

### Notification Timing

**Critical Alerts:**
- Initial notification: After condition persists for specified time
- Repeat interval: Every 1 hour
- Group wait: 10 seconds (to batch similar alerts)

**Warning Alerts:**
- Initial notification: After condition persists for specified time
- Repeat interval: Every 4 hours
- Group wait: 30 seconds

### Alert Email Format

Emails include:
- **Subject**: `[CRITICAL]` or `[WARNING]` + Alert title
- **Disk/Device**: Which disk is affected
- **Current Value**: Temperature, percentage, etc.
- **Threshold**: What triggered the alert
- **Timestamp**: When the alert fired
- **Dashboard Link**: Direct link to relevant Grafana dashboard

## Testing Alerts

### Method 1: Test from Grafana UI

1. Navigate to Grafana: `http://YOUR-UNRAID-IP:3000`
2. Go to **Alerting** → **Contact points**
3. Find **Email Alerts** in the list
4. Click the **Test** button
5. Check your inbox for test email

### Method 2: Trigger a Real Alert (Temperature)

Create a temporary high temperature alert:

1. Edit `grafana/provisioning/alerting/rules.yml`
2. Change temperature threshold to 1°C (to trigger immediately):
   ```yaml
   params:
     - 1  # Temporarily lowered from 60
   ```
3. Restart Grafana: `docker-compose restart grafana`
4. Wait 5 minutes for alert to trigger
5. Check your email
6. **Remember to change the threshold back!**

### Method 3: Check Alert Status

View current alert states:
```bash
# Check if alerts are firing
docker-compose logs grafana | grep -i alert

# View Prometheus alerts
curl http://localhost:9090/api/v1/alerts | jq
```

## Multiple Recipients

To send alerts to multiple people:

```bash
# Comma-separated list
ALERT_EMAIL_TO=admin@company.com,backup-admin@company.com,oncall@company.com
```

Each recipient will receive individual emails.

## Customizing Alerts

### Change Temperature Thresholds

Edit `grafana/provisioning/alerting/rules.yml`:

```yaml
# Find the disk_temp_critical rule
- uid: disk_temp_critical
  title: Critical Disk Temperature
  # ... other config ...
  - refId: C
    model:
      conditions:
        - evaluator:
            params:
              - 65  # Changed from 60°C to 65°C
```

### Change Disk Space Thresholds

```yaml
# Find the disk_space_critical rule
- evaluator:
    params:
      - 98  # Changed from 95% to 98%
    type: gt
```

### Add New Alert Rule

Create a new rule in `grafana/provisioning/alerting/rules.yml`:

```yaml
- uid: disk_temp_very_high
  title: Extreme Disk Temperature
  condition: C
  data:
    - refId: A
      datasourceUid: prometheus
      model:
        expr: unraid_disk_smart_temperature_celsius
  # ... similar structure to other alerts ...
  for: 2m
  annotations:
    description: 'Disk {{ $labels.disk }} is at EXTREME temperature!'
  labels:
    severity: critical
```

### Change Alert Repeat Interval

Edit `grafana/provisioning/alerting/policies.yml`:

```yaml
# Critical alerts every 30 minutes instead of 1 hour
- receiver: Email Alerts
  object_matchers:
    - ['severity', '=', 'critical']
  repeat_interval: 30m  # Changed from 1h
```

## Silencing Alerts

### Temporary Silence (Maintenance Mode)

During maintenance, silence all alerts:

1. Grafana → **Alerting** → **Silences**
2. Click **Add silence**
3. Configure:
   - **Matchers**: Leave empty to silence all, or add specific labels
   - **Duration**: How long to silence (e.g., 2 hours)
   - **Comment**: "Scheduled maintenance"
4. Click **Create**

### Silence Specific Disk

To silence alerts for a specific disk:

1. Create silence with matcher:
   - Label: `disk`
   - Operator: `=`
   - Value: `disk1` (or your disk name)

### Disable Specific Alert

Comment out the alert in `grafana/provisioning/alerting/rules.yml`:

```yaml
# Disabled temperature warning alert
# - uid: disk_temp_warning
#   title: High Disk Temperature
#   ...
```

Then restart Grafana.

## Troubleshooting

### Not Receiving Emails

**Check SMTP connection:**
```bash
# View Grafana SMTP logs
docker-compose logs grafana | grep -i smtp

# Common error messages:
# "authentication failed" = wrong password
# "connection refused" = wrong host/port
# "tls handshake timeout" = firewall blocking
```

**Test SMTP manually:**
```bash
# Install swaks (SMTP testing tool)
docker run --rm -it jthomerson/swaks \
  --to admin@yourdomain.com \
  --from unraid@yourdomain.com \
  --server smtp.gmail.com:587 \
  --auth LOGIN \
  --auth-user your-email@gmail.com \
  --auth-password "your-app-password" \
  --tls
```

### Gmail "Less Secure Apps"

Gmail no longer supports "less secure apps". You **must** use:
1. 2-Step Verification enabled
2. App-specific password

### Firewall Blocking SMTP

Check if port 587 is accessible:

```bash
# Test SMTP port connectivity
telnet smtp.gmail.com 587

# Or use nc (netcat)
nc -zv smtp.gmail.com 587
```

### Alert Not Triggering

**Verify the condition is met:**
```bash
# Check current disk temperature
curl -s http://localhost:9101/metrics | grep temperature

# Check Prometheus query
curl -s 'http://localhost:9090/api/v1/query?query=unraid_disk_smart_temperature_celsius' | jq
```

**Check alert state in Grafana:**
1. Alerting → Alert rules
2. Find your alert
3. Check state: Normal, Pending, Alerting, Error

### Emails Going to Spam

**Solutions:**
1. Add sender to safe senders list
2. Configure SPF/DKIM records (for custom domains)
3. Use authenticated SMTP (not anonymous)
4. Check spam folder and mark as "Not Spam"

## Advanced Configuration

### Webhook Integration

To send alerts to Slack, Discord, or webhook:

Edit `grafana/provisioning/alerting/contactpoints.yml`:

```yaml
contactPoints:
  - orgId: 1
    name: Slack Alerts
    receivers:
      - uid: slack-webhook
        type: slack
        settings:
          url: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
          text: '{{ template "slack.default.text" . }}'
```

### Multiple Notification Channels

Route different alerts to different channels:

```yaml
policies:
  - orgId: 1
    receiver: Email Alerts
    routes:
      # Critical to email AND Slack
      - receiver: Email Alerts
        continue: true
        object_matchers:
          - ['severity', '=', 'critical']
      - receiver: Slack Alerts
        object_matchers:
          - ['severity', '=', 'critical']
      # Warnings only to email
      - receiver: Email Alerts
        object_matchers:
          - ['severity', '=', 'warning']
```

## Best Practices

1. **Test alerts regularly** - Don't wait for a real emergency
2. **Use app passwords** - Never use your main email password
3. **Monitor multiple channels** - Email + SMS/Slack for critical
4. **Set appropriate thresholds** - Avoid alert fatigue
5. **Document your setup** - Save SMTP config securely
6. **Regular maintenance** - Review and update alert rules
7. **Silence during maintenance** - Prevent false alarms

## Security Considerations

- **Never commit `.env` to git** - Contains passwords
- **Use environment variables** - Don't hardcode credentials
- **Rotate passwords regularly** - Update SMTP passwords
- **Limit SMTP permissions** - Use dedicated account for alerts
- **Enable TLS** - Always use encrypted SMTP (port 587/465)
- **Monitor alert logs** - Check for unauthorized access

## Support

For issues with email alerts:

1. Check [Troubleshooting](#troubleshooting) section
2. Review Grafana logs: `docker-compose logs grafana`
3. Test SMTP manually with swaks
4. Verify alert rules in Grafana UI
5. Check firewall and network settings

## References

- [Grafana Alerting Documentation](https://grafana.com/docs/grafana/latest/alerting/)
- [Prometheus Alerting](https://prometheus.io/docs/alerting/latest/)
- [Gmail SMTP Settings](https://support.google.com/mail/answer/7126229)
- [Outlook SMTP Settings](https://support.microsoft.com/en-us/office/pop-imap-and-smtp-settings-8361e398-8af4-4e97-b147-6c6c4ac95353)
