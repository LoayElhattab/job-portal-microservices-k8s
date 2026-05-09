#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "  Job Portal — Stop All Environments"
echo "=========================================="

echo ""
echo "Stopping DEVELOPMENT environment..."
docker compose -f docker-compose.dev.yml -p jobportal-dev down

echo ""
echo "Stopping TEST environment..."
docker compose -f docker-compose.test.yml -p jobportal-test down

echo ""
echo "Stopping PRODUCTION environment..."
docker compose -f docker-compose.prod.yml -p jobportal-prod down

echo ""
echo "=========================================="
echo "  All environments stopped."
echo "=========================================="