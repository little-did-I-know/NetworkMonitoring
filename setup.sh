#!/bin/bash

# Unraid Monitoring Stack Setup Script
# This script automates the initial setup of the monitoring stack

set -e

echo "=========================================="
echo "Unraid Monitoring Stack Setup"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if Docker is installed
echo "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_success "Docker Compose is installed"

echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    print_success ".env file created"
    print_warning "Please edit .env file to set your admin password and timezone"
    echo ""
    read -p "Do you want to set the admin password now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter Grafana admin password: " -s password
        echo ""
        read -p "Confirm password: " -s password2
        echo ""
        if [ "$password" = "$password2" ]; then
            sed -i "s/GRAFANA_ADMIN_PASSWORD=admin/GRAFANA_ADMIN_PASSWORD=$password/" .env
            print_success "Admin password set"
        else
            print_error "Passwords don't match. Please edit .env manually."
        fi
    fi
else
    print_success ".env file already exists"
fi

echo ""

# Create necessary directories
echo "Creating data directories..."
mkdir -p grafana/data
mkdir -p prometheus/data

# Set permissions
echo "Setting permissions..."
chmod -R 777 grafana/data
chmod -R 777 prometheus/data
print_success "Directories created and permissions set"

echo ""

# Check if containers are already running
if docker-compose ps | grep -q "Up"; then
    print_warning "Containers are already running"
    read -p "Do you want to restart them? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Stopping containers..."
        docker-compose down
        echo "Starting containers..."
        docker-compose up -d
    fi
else
    echo "Starting monitoring stack..."
    docker-compose up -d
fi

echo ""
echo "Waiting for containers to start..."
sleep 10

# Check if all containers are running
echo ""
echo "Checking container status..."
if docker-compose ps | grep -q "Exit"; then
    print_error "Some containers failed to start. Check logs with: docker-compose logs"
    exit 1
fi

print_success "All containers are running"

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Access your monitoring dashboards at:"
echo ""
echo "  Grafana:              http://$(hostname -I | awk '{print $1}'):3000"
echo "  Prometheus:           http://$(hostname -I | awk '{print $1}'):9090"
echo "  Node Exporter:        http://$(hostname -I | awk '{print $1}'):9100"
echo "  cAdvisor:             http://$(hostname -I | awk '{print $1}'):8070"
echo "  Unraid Exporter:      http://$(hostname -I | awk '{print $1}'):9101"
echo "  NVIDIA GPU Exporter:  http://$(hostname -I | awk '{print $1}'):9835"
echo ""
echo "Default Grafana credentials:"
echo "  Username: admin"
echo "  Password: (check your .env file)"
echo ""
echo "🏠 You'll automatically see the Home Dashboard when you login!"
echo ""
echo "Pre-configured dashboards:"
echo "  - Home Dashboard (Default) - Overview of everything"
echo "  - Unraid System Overview"
echo "  - Docker Containers"
echo "  - Hardware Sensors"
echo "  - Unraid Array Health"
echo "  - NVIDIA GPU Monitoring"
echo ""
echo "📖 New to Grafana? Check out QUICK_START_GUIDE.md"
echo ""
echo "Useful commands:"
echo "  View logs:        docker-compose logs -f"
echo "  Stop stack:       docker-compose down"
echo "  Restart stack:    docker-compose restart"
echo "  Update images:    docker-compose pull && docker-compose up -d"
echo ""
print_success "Happy monitoring!"
