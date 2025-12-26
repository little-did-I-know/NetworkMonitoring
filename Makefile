.PHONY: help start stop restart logs status update clean backup restore

# Default target
help:
	@echo "Unraid Monitoring Stack - Available Commands:"
	@echo ""
	@echo "  make start      - Start all monitoring containers"
	@echo "  make stop       - Stop all monitoring containers"
	@echo "  make restart    - Restart all monitoring containers"
	@echo "  make logs       - View container logs (follow mode)"
	@echo "  make status     - Show container status"
	@echo "  make update     - Update all container images"
	@echo "  make clean      - Remove all containers and volumes (DESTRUCTIVE)"
	@echo "  make backup     - Backup Grafana and Prometheus data"
	@echo "  make restore    - Restore from backup"
	@echo ""

# Start the monitoring stack
start:
	@echo "Starting monitoring stack..."
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 5
	@docker-compose ps
	@echo ""
	@echo "Access Grafana at: http://localhost:3000"

# Stop the monitoring stack
stop:
	@echo "Stopping monitoring stack..."
	docker-compose down

# Restart the monitoring stack
restart:
	@echo "Restarting monitoring stack..."
	docker-compose restart
	@echo "Services restarted"

# View logs
logs:
	docker-compose logs -f

# Show container status
status:
	@echo "Container Status:"
	@docker-compose ps
	@echo ""
	@echo "Resource Usage:"
	@docker stats --no-stream $$(docker-compose ps -q)

# Update container images
update:
	@echo "Pulling latest images..."
	docker-compose pull
	@echo "Recreating containers..."
	docker-compose up -d
	@echo "Update complete"

# Clean up everything (DESTRUCTIVE)
clean:
	@echo "WARNING: This will remove all containers and data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		rm -rf grafana/data/* prometheus/data/*; \
		echo "Cleanup complete"; \
	else \
		echo "Cleanup cancelled"; \
	fi

# Backup data
backup:
	@echo "Creating backup..."
	@mkdir -p backups
	@tar -czf backups/grafana-$$(date +%Y%m%d-%H%M%S).tar.gz grafana/data
	@tar -czf backups/prometheus-$$(date +%Y%m%d-%H%M%S).tar.gz prometheus/data
	@echo "Backup complete. Files saved in backups/ directory"

# Restore from backup (interactive)
restore:
	@echo "Available backups:"
	@ls -lh backups/
	@echo ""
	@read -p "Enter Grafana backup filename: " grafana_file; \
	read -p "Enter Prometheus backup filename: " prometheus_file; \
	echo "Stopping containers..."; \
	docker-compose down; \
	echo "Restoring Grafana data..."; \
	tar -xzf backups/$$grafana_file; \
	echo "Restoring Prometheus data..."; \
	tar -xzf backups/$$prometheus_file; \
	echo "Starting containers..."; \
	docker-compose up -d; \
	echo "Restore complete"
