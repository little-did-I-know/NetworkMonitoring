# Unraid Server Monitoring with Grafana

A comprehensive Docker-based monitoring solution for Unraid servers, featuring Grafana dashboards for real-time visualization of system health, performance metrics, and container statistics.

## Features

- **System Resources Monitoring**: CPU, RAM, Disk I/O, and Network statistics
- **NVIDIA GPU Monitoring**: GPU temperature, utilization, memory usage, power consumption, and clock speeds via nvidia-smi
- **Unraid Array Health**: Array status, parity checks, disk health, and SMART data monitoring
- **Email Alerts**: Automatic notifications for critical disk and GPU issues (temperature, SMART failures, disk space, parity errors)
- **Storage & Array Health**: Filesystem usage, disk space, and array status
- **Docker Container Metrics**: Resource usage per container, network, and disk I/O
- **Hardware Sensors**: CPU/GPU temperatures, fan speeds, and power consumption
- **Network Traffic**: Real-time bandwidth monitoring and traffic analysis
- **Pre-configured Dashboards**: Ready-to-use Grafana dashboards for all metrics

## Architecture

This monitoring stack consists of:

- **Grafana**: Visualization and dashboard platform (Port 3000)
- **Prometheus**: Time-series metrics database (Port 9090)
- **Node Exporter**: System-level metrics collector (Port 9100)
- **cAdvisor**: Container metrics collector (Port 8070)
- **Unraid Exporter**: Custom Unraid array and disk health metrics (Port 9101)
- **NVIDIA GPU Exporter**: GPU metrics via nvidia-smi (Port 9835)

## Prerequisites

- Unraid server with Docker support
- Docker and Docker Compose installed
- At least 2GB of free RAM
- Approximately 10GB of disk space for metrics retention

## Installation

### Option 1: Docker Compose (Recommended)

1. **Clone or download this repository to your Unraid server:**
   ```bash
   cd /mnt/user/appdata/
   git clone <your-repo-url> monitoring
   cd monitoring
   ```

2. **Create environment configuration:**
   ```bash
   cp .env.example .env
   ```

3. **Edit the .env file with your preferences:**
   ```bash
   nano .env
   ```

   Update the following:
   - `GRAFANA_ADMIN_PASSWORD`: Change the default admin password
   - `TZ`: Set your timezone (e.g., `America/New_York`, `Europe/London`)

4. **Create necessary directories:**
   ```bash
   mkdir -p grafana/data prometheus/data
   chmod -R 777 grafana/data prometheus/data
   ```

5. **Start the monitoring stack:**
   ```bash
   docker-compose up -d
   ```

6. **Verify all containers are running:**
   ```bash
   docker-compose ps
   ```

7. **Access Grafana and start monitoring:**
   - Open `http://YOUR-UNRAID-IP:3000` in your browser
   - Login with `admin` / `admin` (or your configured password)
   - You'll automatically see the **Home Dashboard** with an overview of everything
   - **New to Grafana?** Follow the [Quick Start Guide](QUICK_START_GUIDE.md)

### Option 2: Unraid Community Applications

If you prefer using the Unraid UI:

1. Navigate to the **Apps** tab in Unraid
2. Search for and install the following containers:
   - Grafana
   - Prometheus
   - Node Exporter
   - cAdvisor

3. Configure each container according to the settings in `docker-compose.yml`

## Accessing the Dashboards

Once deployed, access your monitoring services at:

```
Grafana:              http://YOUR-UNRAID-IP:3000
Prometheus:           http://YOUR-UNRAID-IP:9090
Node Exporter:        http://YOUR-UNRAID-IP:9100/metrics
cAdvisor:             http://YOUR-UNRAID-IP:8070
Unraid Exporter:      http://YOUR-UNRAID-IP:9101/metrics
NVIDIA GPU Exporter:  http://YOUR-UNRAID-IP:9835/metrics
```

**Default Grafana credentials:**
- Username: `admin`
- Password: `admin` (or what you set in `.env`)

You'll be prompted to change the password on first login.

### 🏠 Default Home Dashboard

**New to Grafana?** Don't worry! When you first log in, you'll automatically see the **Home Dashboard** - a comprehensive overview designed specifically for beginners.

The Home Dashboard includes:
- **Quick status gauges** - Array, CPU, Memory, GPU, Containers at a glance
- **Dashboard navigation** - Easy links to all detailed dashboards
- **Key metrics** - CPU/Memory trends, network traffic, disk temperatures
- **Quick stats** - System uptime, disk count, resources
- **Help section** - Built-in guidance and links

📖 **First time using Grafana?** Check out **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** for a complete beginner's tutorial with:
- How to navigate dashboards
- Understanding what each metric means
- What to look for in monitoring
- Troubleshooting tips
- Keyboard shortcuts and pro tips

## Available Dashboards

The following dashboards are automatically provisioned and ready to use:

### 0. Home Dashboard (Default)
- System status overview at a glance
- Quick navigation to all dashboards
- CPU, Memory, and Network trends
- Disk temperatures and space usage
- Quick stats summary
- Built-in help and documentation links

### 1. Unraid System Overview
- Real-time CPU usage
- Memory consumption
- System load average
- Network traffic (RX/TX)
- Disk I/O statistics
- Filesystem usage with color-coded warnings
- System uptime and hardware info

### 2. Docker Containers
- Container count and status
- CPU usage per container
- Memory usage per container
- Network traffic per container
- Disk I/O per container
- Historical resource trends

### 3. Hardware Sensors
- CPU temperature monitoring
- Disk temperatures
- Fan speeds (if available)
- Power consumption metrics
- Voltage sensors
- Temperature gauges with thresholds

### 4. Unraid Array Health
- Array status (started/stopped)
- Total disks in array
- Parity check status and progress
- Disk space usage per disk with color-coded warnings
- SMART health status for all disks
- Disk temperature monitoring
- Power-on hours tracking
- Reallocated sectors count
- Parity errors tracking
- Disk status (active/standby/disabled)

### 5. NVIDIA GPU Monitoring
- GPU temperature with gauges and thresholds
- GPU utilization (GPU and memory controllers)
- VRAM usage and availability
- Power consumption and power limit
- Fan speed monitoring
- GPU and memory clock speeds
- Encoder/Decoder utilization
- Historical trends for all metrics

## NVIDIA GPU Monitoring

The monitoring stack includes comprehensive NVIDIA GPU monitoring using nvidia-smi. Track your GPU's performance, temperature, and resource usage in real-time.

### Monitored GPU Metrics

**Temperature & Cooling:**
- GPU temperature (°C)
- Fan speed (%)
- Thermal throttling detection

**Performance:**
- GPU utilization (%)
- Memory controller utilization (%)
- Graphics clock speed (MHz)
- Memory clock speed (MHz)
- Power consumption (W)
- Power limit percentage

**Memory:**
- VRAM used (GB)
- VRAM total (GB)
- Memory usage percentage

**Video Processing:**
- Encoder utilization (for video encoding)
- Decoder utilization (for video decoding)

### GPU Alerts

Four automatic GPU alerts are configured:

**Critical Alerts** (🔥):
- **Critical GPU Temperature** - Above 85°C (wait: 5 min, repeat: 1 hour)
- **GPU Memory Critical** - Above 95% usage (wait: 5 min, repeat: 1 hour)

**Warning Alerts** (⚠️):
- **High GPU Temperature** - Above 75°C (wait: 10 min, repeat: 4 hours)
- **GPU Power Limit Reached** - Above 98% of power limit (wait: 15 min, repeat: 4 hours)

### Requirements

To use GPU monitoring, your Unraid server must have:
1. NVIDIA GPU installed
2. NVIDIA drivers installed
3. `nvidia-smi` command available

**Verify GPU is detected:**
```bash
nvidia-smi
```

If you see GPU information, you're all set!

### Troubleshooting GPU Monitoring

**Problem**: No GPU metrics showing

**Solutions**:
1. Verify nvidia-smi works on the host:
   ```bash
   nvidia-smi
   ```

2. Check nvidia-gpu-exporter logs:
   ```bash
   docker-compose logs nvidia-gpu-exporter
   ```

3. Verify Prometheus is scraping GPU metrics:
   - Go to `http://YOUR-UNRAID-IP:9090/targets`
   - Check if `nvidia-gpu` target shows "UP"

4. Test GPU exporter directly:
   ```bash
   curl http://localhost:9835/metrics | grep nvidia_gpu
   ```

**Problem**: Multiple GPUs not showing

The exporter automatically detects all NVIDIA GPUs. If you have multiple GPUs, ensure:
- All GPUs are visible to `nvidia-smi`
- Docker has access to all GPU devices

**For multiple GPUs**, you may need to add additional device mappings in `docker-compose.yml`:
```yaml
devices:
  - /dev/nvidiactl:/dev/nvidiactl
  - /dev/nvidia0:/dev/nvidia0
  - /dev/nvidia1:/dev/nvidia1  # Add for second GPU
  - /dev/nvidia-uvm:/dev/nvidia-uvm
```

## Unraid Array Health Monitoring

The custom **Unraid Exporter** provides deep insights into your Unraid array and disk health. This is a Python-based exporter specifically designed for Unraid servers.

### What's Monitored

**Array Status:**
- Array state (started/stopped)
- Number of disks in the array
- Parity check status (running/idle)
- Parity check progress percentage
- Total parity errors detected

**Disk Health (SMART Data):**
- Disk temperatures from SMART data
- Power-on hours for each disk
- Reallocated sectors count (indicator of disk degradation)
- SMART health status (PASSED/FAILED)

**Disk Usage:**
- Space used per disk
- Total disk size
- Available space
- Real-time usage percentages

**Disk Status:**
- Active/Standby/Disabled state per disk
- Mounted disk detection
- Device identification

### How It Works

The Unraid Exporter runs as a privileged container with access to:
- `/proc/mdstat` - For array and parity status
- `/dev` - For direct disk access to read SMART data
- `/mnt` - For mounted disk detection and space calculations

The exporter uses:
- **smartmontools** - To read SMART attributes from physical drives
- **mdstat parsing** - To determine array and parity check status
- **df command** - To calculate disk space usage

Metrics are collected every 30 seconds and exposed on port 9101 in Prometheus format.

### SMART Monitoring

The exporter automatically detects all `/dev/sd*` devices and reads SMART data including:
- Temperature_Celsius
- Power_On_Hours
- Reallocated_Sector_Ct
- Overall health status

**Note:** Ensure `smartmontools` is installed on your Unraid host for full SMART monitoring. The exporter container includes it, but needs access to the host's `/dev` devices.

### Customizing Unraid Monitoring

The Unraid exporter can be customized by editing `unraid-exporter/unraid_exporter.py`. You can:
- Add additional SMART attributes to monitor
- Customize scrape intervals in `prometheus/prometheus.yml`
- Modify disk detection patterns
- Add custom Unraid-specific metrics

## Configuration

### Customizing Metrics Retention

Edit `prometheus/prometheus.yml` to adjust scrape intervals and retention:

```yaml
global:
  scrape_interval: 15s  # How often to scrape metrics
  evaluation_interval: 15s
```

In `docker-compose.yml`, adjust retention period:

```yaml
command:
  - '--storage.tsdb.retention.time=30d'  # Keep metrics for 30 days
```

### Adding Custom Dashboards

1. Create your dashboard in Grafana UI
2. Export the dashboard as JSON
3. Save it to `grafana/provisioning/dashboards/`
4. Restart Grafana: `docker-compose restart grafana`

### Monitoring Additional Services

To monitor additional services, edit `prometheus/prometheus.yml` and add new scrape configs:

```yaml
scrape_configs:
  - job_name: 'my-service'
    static_configs:
      - targets: ['my-service:port']
```

## Email Alerts for Critical Disk Issues

The monitoring stack includes automatic email alerts for critical disk issues. Get notified immediately when problems are detected!

📧 **For detailed setup instructions, see [EMAIL_ALERTS_SETUP.md](EMAIL_ALERTS_SETUP.md)**

### Configured Alerts

The following alerts are automatically configured:

**Critical Alerts** (sent within 1-5 minutes):
- 🔥 **SMART Health Failed** - Disk has failed SMART health check
- 🔥 **Critical Disk Temperature** - Disk temperature above 60°C
- 🔥 **Disk Space Critical** - Disk usage above 95%
- 🔥 **Array Stopped** - Unraid array has stopped unexpectedly
- 🔥 **Parity Errors** - Parity check found data corruption

**Warning Alerts** (sent after 10-15 minutes):
- ⚠️ **High Disk Temperature** - Disk temperature above 50°C
- ⚠️ **Disk Space Warning** - Disk usage above 85%
- ⚠️ **Reallocated Sectors** - Disk showing signs of degradation

### Setting Up Email Alerts

#### Step 1: Configure SMTP Settings

Edit your `.env` file and configure the email settings:

```bash
# Enable email alerts
SMTP_ENABLED=true

# SMTP server (examples below)
SMTP_HOST=smtp.gmail.com:587

# Your email credentials
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Sender information
SMTP_FROM_ADDRESS=unraid-monitoring@yourdomain.com
SMTP_FROM_NAME=Unraid Monitoring

# Who receives the alerts
ALERT_EMAIL_TO=admin@yourdomain.com
```

#### Step 2: SMTP Provider Configuration

**Gmail:**
1. Go to [Google App Passwords](https://myaccount.google.com/apppasswords)
2. Generate a new App Password
3. Use your Gmail address as `SMTP_USER`
4. Use the generated App Password as `SMTP_PASSWORD`
5. Set `SMTP_HOST=smtp.gmail.com:587`

**Outlook/Office365:**
```bash
SMTP_HOST=smtp-mail.outlook.com:587
SMTP_USER=your-email@outlook.com
SMTP_PASSWORD=your-password
```

**Office365:**
```bash
SMTP_HOST=smtp.office365.com:587
SMTP_USER=your-email@company.com
SMTP_PASSWORD=your-password
```

**Custom SMTP Server:**
```bash
SMTP_HOST=mail.yourdomain.com:587
SMTP_USER=alerts@yourdomain.com
SMTP_PASSWORD=your-password
SMTP_SKIP_VERIFY=false  # Set to true for self-signed certificates
```

#### Step 3: Restart Grafana

After configuring SMTP settings:

```bash
docker-compose restart grafana
```

#### Step 4: Test Email Alerts

1. Open Grafana: `http://YOUR-UNRAID-IP:3000`
2. Navigate to **Alerting** → **Contact points**
3. Click on **Email Alerts**
4. Click **Test** to send a test email
5. Check your inbox for the test email

### Alert Notification Settings

Alerts are configured with smart grouping and timing:

- **Critical alerts** repeat every 1 hour if not resolved
- **Warning alerts** repeat every 4 hours if not resolved
- Alerts are grouped by severity to avoid spam
- Each alert includes detailed information about the issue

### Customizing Alerts

#### Modify Alert Thresholds

Edit `grafana/provisioning/alerting/rules.yml` to change thresholds:

```yaml
# Example: Change disk temperature critical threshold from 60°C to 65°C
- evaluator:
    params:
      - 65  # Changed from 60
    type: gt
```

#### Add Multiple Email Recipients

In `.env`, separate emails with commas:

```bash
ALERT_EMAIL_TO=admin@company.com,backup@company.com,oncall@company.com
```

#### Change Alert Timing

Edit `grafana/provisioning/alerting/policies.yml`:

```yaml
# Send critical alerts immediately and repeat every 30 minutes
- receiver: Email Alerts
  object_matchers:
    - ['severity', '=', 'critical']
  group_wait: 10s
  repeat_interval: 30m  # Changed from 1h
```

### Viewing Alert History

In Grafana:
1. Navigate to **Alerting** → **Alert rules**
2. See all configured rules and their current states
3. Click on any rule to see its history and details

### Silencing Alerts

To temporarily disable alerts (e.g., during maintenance):

1. Go to **Alerting** → **Silences**
2. Click **Add silence**
3. Configure the silence duration and matching rules
4. Alerts will not be sent during the silence period

## Troubleshooting

### Container Won't Start

Check container logs:
```bash
docker-compose logs -f [service-name]
```

### No Metrics Showing

1. Verify Prometheus is scraping targets:
   - Navigate to `http://YOUR-UNRAID-IP:9090/targets`
   - All targets should show "UP" status

2. Check Node Exporter is accessible:
   ```bash
   curl http://localhost:9100/metrics
   ```

### Permission Issues

If you encounter permission errors:
```bash
chmod -R 777 grafana/data prometheus/data
```

### High Memory Usage

Reduce Prometheus retention:
```yaml
- '--storage.tsdb.retention.time=7d'  # Reduce to 7 days
```

### Email Alerts Not Working

**Problem**: Not receiving email alerts

**Solutions**:

1. **Verify SMTP settings in `.env`:**
   ```bash
   cat .env | grep SMTP
   ```
   - Ensure `SMTP_ENABLED=true`
   - Check credentials are correct

2. **Test SMTP connection from Grafana:**
   - Open Grafana → Alerting → Contact points
   - Click "Email Alerts"
   - Click "Test" button
   - Check for error messages

3. **Check Grafana logs:**
   ```bash
   docker-compose logs grafana | grep -i smtp
   docker-compose logs grafana | grep -i email
   ```

4. **Common issues:**
   - **Gmail**: Must use App Password, not regular password
   - **2FA enabled**: Generate an app-specific password
   - **Firewall**: Ensure port 587 (or 465) is not blocked
   - **Wrong credentials**: Double-check username and password

5. **Verify alert rules are active:**
   - Grafana → Alerting → Alert rules
   - Check if rules show "Normal" or "Pending" state

6. **Check spam folder:**
   - Alerts might be filtered as spam
   - Add sender to safe senders list

7. **Enable debug logging:**
   Add to Grafana environment in `docker-compose.yml`:
   ```yaml
   - GF_LOG_LEVEL=debug
   ```
   Then restart: `docker-compose restart grafana`

## Hardware Sensor Requirements

For temperature and fan monitoring to work:

1. **Install lm-sensors on the Unraid host:**
   ```bash
   sensors-detect
   ```

2. **Verify sensors are working:**
   ```bash
   sensors
   ```

3. Node Exporter will automatically discover and expose sensor metrics

## Updating

To update to the latest versions:

```bash
docker-compose pull
docker-compose up -d
```

## Backup and Restore

### Backup Grafana Dashboards and Settings

```bash
tar -czf grafana-backup.tar.gz grafana/data/
```

### Backup Prometheus Data

```bash
tar -czf prometheus-backup.tar.gz prometheus/data/
```

### Restore

```bash
tar -xzf grafana-backup.tar.gz
tar -xzf prometheus-backup.tar.gz
docker-compose restart
```

## Resource Usage

Expected resource consumption:

- **Grafana**: ~100-200 MB RAM
- **Prometheus**: ~500 MB - 2 GB RAM (depends on retention)
- **Node Exporter**: ~10-20 MB RAM
- **cAdvisor**: ~100-200 MB RAM

**Total**: Approximately 1-2.5 GB RAM

## Security Recommendations

1. **Change default passwords** immediately
2. **Use a reverse proxy** (nginx, Traefik) for HTTPS access
3. **Restrict access** using firewall rules if exposed to internet
4. **Regular backups** of Grafana and Prometheus data
5. **Update containers** regularly for security patches

## Advanced Configuration

### Enable Email Alerts

Edit `grafana/provisioning/alerting/alerting.yml`:

```yaml
apiVersion: 1
contactPoints:
  - name: email
    receivers:
      - uid: email
        type: email
        settings:
          addresses: your-email@example.com
```

### Custom Metrics with Pushgateway

Add to `docker-compose.yml`:

```yaml
pushgateway:
  image: prom/pushgateway
  container_name: pushgateway
  ports:
    - "9091:9091"
  networks:
    - monitoring
```

## Unraid-Specific Features

### Monitoring Docker Templates

The stack monitors all Docker containers running on Unraid, including:
- Community Applications
- Custom containers
- System containers

### Array Monitoring

To monitor Unraid array status, consider adding:
- UPS monitoring (if available)
- SMART data exporters for detailed disk health
- Custom scripts for array parity status

## Support and Contributing

For issues, questions, or contributions:

1. Check existing documentation
2. Review logs for errors
3. Open an issue with details about your setup

## License

This project is provided as-is for monitoring Unraid servers.

## Acknowledgments

- Grafana Labs for the visualization platform
- Prometheus community for metrics collection
- Node Exporter and cAdvisor maintainers
- Unraid community for testing and feedback
