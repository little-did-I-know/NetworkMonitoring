#!/usr/bin/env python3
"""
Unraid Metrics Exporter for Prometheus
Collects Unraid-specific metrics including array status, disk health, and parity information
"""

import os
import re
import time
import subprocess
from prometheus_client import start_http_server, Gauge, Enum, Info
from prometheus_client.core import GaugeMetricFamily, REGISTRY
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class UnraidCollector:
    def __init__(self):
        self.mdstat_path = '/host/proc/mdstat'
        self.disk_path = '/mnt/disks'

    def collect(self):
        """Collect all Unraid metrics"""
        try:
            # Array status metrics
            yield from self.collect_array_status()

            # Disk metrics
            yield from self.collect_disk_metrics()

            # SMART metrics
            yield from self.collect_smart_metrics()

            # Parity check metrics
            yield from self.collect_parity_metrics()

        except Exception as e:
            logger.error(f"Error collecting metrics: {e}")

    def collect_array_status(self):
        """Collect array status from mdstat"""
        array_state = GaugeMetricFamily(
            'unraid_array_state',
            'Unraid array state (1=started, 0=stopped)',
            labels=['array']
        )

        array_disks = GaugeMetricFamily(
            'unraid_array_disks_total',
            'Total number of disks in array',
            labels=['array']
        )

        try:
            if os.path.exists(self.mdstat_path):
                with open(self.mdstat_path, 'r') as f:
                    mdstat_content = f.read()

                # Check if md arrays exist
                md_devices = re.findall(r'(md\d+)\s*:', mdstat_content)

                if md_devices:
                    array_state.add_metric(['md'], 1)

                    # Count active disks
                    for md_device in md_devices:
                        disk_count = len(re.findall(r'sd[a-z]+\[\d+\]', mdstat_content))
                        array_disks.add_metric([md_device], disk_count)
                else:
                    array_state.add_metric(['md'], 0)
                    array_disks.add_metric(['md'], 0)

                yield array_state
                yield array_disks

        except Exception as e:
            logger.error(f"Error reading mdstat: {e}")
            array_state.add_metric(['md'], 0)
            yield array_state

    def collect_disk_metrics(self):
        """Collect disk-specific metrics"""
        disk_status = GaugeMetricFamily(
            'unraid_disk_status',
            'Disk status (1=active, 0=standby, -1=disabled)',
            labels=['disk', 'device']
        )

        disk_size = GaugeMetricFamily(
            'unraid_disk_size_bytes',
            'Disk size in bytes',
            labels=['disk', 'device']
        )

        disk_used = GaugeMetricFamily(
            'unraid_disk_used_bytes',
            'Disk used space in bytes',
            labels=['disk', 'device']
        )

        try:
            # Get list of mounted disks
            result = subprocess.run(['df', '-B1'], capture_output=True, text=True)

            for line in result.stdout.split('\n'):
                # Look for /mnt/disk* or /mnt/cache mounts
                if '/mnt/disk' in line or '/mnt/cache' in line:
                    parts = line.split()
                    if len(parts) >= 6:
                        device = parts[0]
                        size = int(parts[1])
                        used = int(parts[2])
                        mount = parts[5]

                        disk_name = mount.split('/')[-1]

                        disk_status.add_metric([disk_name, device], 1)
                        disk_size.add_metric([disk_name, device], size)
                        disk_used.add_metric([disk_name, device], used)

            yield disk_status
            yield disk_size
            yield disk_used

        except Exception as e:
            logger.error(f"Error collecting disk metrics: {e}")

    def collect_smart_metrics(self):
        """Collect SMART data for disks"""
        smart_temp = GaugeMetricFamily(
            'unraid_disk_smart_temperature_celsius',
            'Disk temperature from SMART data',
            labels=['disk', 'device']
        )

        smart_power_on_hours = GaugeMetricFamily(
            'unraid_disk_smart_power_on_hours',
            'Disk power on hours from SMART data',
            labels=['disk', 'device']
        )

        smart_reallocated_sectors = GaugeMetricFamily(
            'unraid_disk_smart_reallocated_sectors',
            'Reallocated sectors count',
            labels=['disk', 'device']
        )

        smart_health = GaugeMetricFamily(
            'unraid_disk_smart_health',
            'SMART health status (1=PASSED, 0=FAILED)',
            labels=['disk', 'device']
        )

        try:
            # Get list of block devices
            devices = []
            if os.path.exists('/dev'):
                for dev in os.listdir('/dev'):
                    if re.match(r'sd[a-z]$', dev):
                        devices.append(f'/dev/{dev}')

            for device in devices:
                try:
                    # Run smartctl
                    result = subprocess.run(
                        ['smartctl', '-A', '-H', device],
                        capture_output=True,
                        text=True,
                        timeout=10
                    )

                    disk_name = device.split('/')[-1]

                    # Parse SMART health
                    if 'PASSED' in result.stdout:
                        smart_health.add_metric([disk_name, device], 1)
                    elif 'FAILED' in result.stdout:
                        smart_health.add_metric([disk_name, device], 0)

                    # Parse temperature
                    temp_match = re.search(r'Temperature_Celsius.*?(\d+)', result.stdout)
                    if temp_match:
                        smart_temp.add_metric([disk_name, device], float(temp_match.group(1)))
                    else:
                        # Try alternate format
                        temp_match = re.search(r'Current Drive Temperature:\s+(\d+)', result.stdout)
                        if temp_match:
                            smart_temp.add_metric([disk_name, device], float(temp_match.group(1)))

                    # Parse power on hours
                    hours_match = re.search(r'Power_On_Hours.*?(\d+)', result.stdout)
                    if hours_match:
                        smart_power_on_hours.add_metric([disk_name, device], float(hours_match.group(1)))

                    # Parse reallocated sectors
                    realloc_match = re.search(r'Reallocated_Sector_Ct.*?(\d+)', result.stdout)
                    if realloc_match:
                        smart_reallocated_sectors.add_metric([disk_name, device], float(realloc_match.group(1)))

                except subprocess.TimeoutExpired:
                    logger.warning(f"Timeout reading SMART data for {device}")
                except Exception as e:
                    logger.warning(f"Error reading SMART data for {device}: {e}")

            yield smart_temp
            yield smart_power_on_hours
            yield smart_reallocated_sectors
            yield smart_health

        except Exception as e:
            logger.error(f"Error collecting SMART metrics: {e}")

    def collect_parity_metrics(self):
        """Collect parity check metrics"""
        parity_status = GaugeMetricFamily(
            'unraid_parity_check_running',
            'Parity check running status (1=running, 0=not running)',
            labels=['array']
        )

        parity_progress = GaugeMetricFamily(
            'unraid_parity_check_progress_percent',
            'Parity check progress percentage',
            labels=['array']
        )

        parity_errors = GaugeMetricFamily(
            'unraid_parity_errors_total',
            'Total parity errors found',
            labels=['array']
        )

        try:
            if os.path.exists(self.mdstat_path):
                with open(self.mdstat_path, 'r') as f:
                    mdstat_content = f.read()

                # Check for resync/recovery/check operations
                if 'resync' in mdstat_content or 'recovery' in mdstat_content or 'check' in mdstat_content:
                    parity_status.add_metric(['md'], 1)

                    # Extract progress
                    progress_match = re.search(r'(\d+\.\d+)%', mdstat_content)
                    if progress_match:
                        parity_progress.add_metric(['md'], float(progress_match.group(1)))
                else:
                    parity_status.add_metric(['md'], 0)
                    parity_progress.add_metric(['md'], 0)

                # Parity errors would need to be read from Unraid's log or status files
                # For now, set to 0 as a placeholder
                parity_errors.add_metric(['md'], 0)

                yield parity_status
                yield parity_progress
                yield parity_errors

        except Exception as e:
            logger.error(f"Error collecting parity metrics: {e}")


def main():
    """Main function to start the exporter"""
    port = int(os.getenv('EXPORTER_PORT', 9101))

    logger.info(f"Starting Unraid Exporter on port {port}")

    # Register the collector
    REGISTRY.register(UnraidCollector())

    # Start the HTTP server
    start_http_server(port)

    logger.info("Unraid Exporter started successfully")

    # Keep the script running
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Shutting down Unraid Exporter")


if __name__ == '__main__':
    main()
