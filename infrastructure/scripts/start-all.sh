#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "  Job Portal — Start All Environments"
echo "=========================================="

for file in .env.dev .env.test .env.prod; do
    if [[ ! -f "$file" ]]; then
        echo "Missing $file. Copy from .env.dev.example and configure."
        exit 1
    fi
done

echo ""
echo "Starting DEVELOPMENT environment..."
docker compose -f docker-compose.dev.yml -p jobportal-dev up --pull never -d

echo ""
echo "Starting TEST environment..."
docker compose -f docker-compose.test.yml -p jobportal-test up --pull never -d

echo ""
echo "Starting PRODUCTION environment..."
docker compose -f docker-compose.prod.yml -p jobportal-prod up --pull never -d

echo ""
echo "=========================================="
echo "  All environments started!"
echo "=========================================="
echo ""
echo "Dev Gateway:    http://localhost:3100"
echo "Test Gateway:   http://localhost:3200"
echo "Prod Gateway:   http://localhost:3300"
echo "Dev Grafana:    http://localhost:3121"
echo "Dev RabbitMQ:   http://localhost:3112"
echo ""
echo "Check status:   docker ps --format 'table {{.Names}}\t{{.Status}}'"
echo "View logs:      docker logs -f <container-name>"
echo ""
