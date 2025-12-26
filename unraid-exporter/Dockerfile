FROM python:3.11-slim

# Install smartmontools for SMART data collection
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    smartmontools \
    util-linux \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the exporter script
COPY unraid_exporter.py .

# Make the script executable
RUN chmod +x unraid_exporter.py

# Expose the metrics port
EXPOSE 9101

# Run the exporter
CMD ["python", "-u", "unraid_exporter.py"]
