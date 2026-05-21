#!/bin/bash
# =============================================================================
# Job Portal Kubernetes Deployment Script
# =============================================================================
# Applies all K8s manifests in the correct order:
# namespace → config → secrets → infra → services → monitoring
# 
# Usage: ./apply-all.sh [namespace]
# Default namespace: jobportal-prod
# =============================================================================

set -euo pipefail

NAMESPACE="${1:-jobportal-prod}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Job Portal Kubernetes Deployment"
echo "Namespace: ${NAMESPACE}"
echo "Script Dir: ${SCRIPT_DIR}"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to apply a manifest
apply_manifest() {
    local file="$1"
    local description="$2"

    if [ ! -f "${SCRIPT_DIR}/${file}" ]; then
        echo -e "${RED}ERROR: File not found: ${file}${NC}"
        return 1
    fi

    echo -e "${YELLOW}Applying: ${description} (${file})${NC}"
    kubectl apply -f "${SCRIPT_DIR}/${file}" -n "${NAMESPACE}"
    echo -e "${GREEN}✓ ${description} applied successfully${NC}"
    echo ""
}

# Helper function to wait for deployment
wait_for_deployment() {
    local name="$1"
    local timeout="${2:-120s}"

    echo -e "${YELLOW}Waiting for ${name} to be ready (timeout: ${timeout})...${NC}"
    kubectl rollout status deployment/${name} -n "${NAMESPACE}" --timeout="${timeout}" || {
        echo -e "${RED}WARNING: ${name} rollout did not complete within ${timeout}${NC}"
        return 1
    }
    echo -e "${GREEN}✓ ${name} is ready${NC}"
    echo ""
}

# Step 1: Namespace
echo -e "${GREEN}=== STEP 1: Namespace ===${NC}"
apply_manifest "00-namespace.yml" "Namespace"

# Step 2: ConfigMap + Secrets
echo -e "${GREEN}=== STEP 2: ConfigMaps & Secrets ===${NC}"
apply_manifest "01-configmap.yml" "Main ConfigMap"
apply_manifest "02-secrets.yml" "Secrets"

# Step 3: Infrastructure (Postgres + RabbitMQ)
# When using AWS RDS, skip postgres manifests — see infrastructure/terraform/README.md
echo -e "${GREEN}=== STEP 3: Infrastructure ===${NC}"
if [ "${USE_RDS:-}" != "true" ]; then
    apply_manifest "postgres/deployment.yml" "Postgres (ConfigMap + PVC + Deployment)"
    apply_manifest "postgres/service.yml" "Postgres Service"
    echo -e "${YELLOW}Waiting for postgres to be ready...${NC}"
    wait_for_deployment "postgres" "120s"
else
    echo -e "${YELLOW}USE_RDS=true — skipping in-cluster Postgres (RDS via Terraform)${NC}"
fi
apply_manifest "rabbitmq/deployment.yml" "RabbitMQ Deployment"
apply_manifest "rabbitmq/service.yml" "RabbitMQ Service"
echo -e "${YELLOW}Waiting for rabbitmq to be ready...${NC}"
wait_for_deployment "rabbitmq" "300s"

# Step 4: Backend Services
echo -e "${GREEN}=== STEP 4: Backend Services ===${NC}"
apply_manifest "user-service/deployment.yml" "User Service Deployment"
apply_manifest "user-service/service.yml" "User Service Service"
apply_manifest "job-service/deployment.yml" "Job Service Deployment"
apply_manifest "job-service/service.yml" "Job Service Service"
apply_manifest "application-service/deployment.yml" "Application Service Deployment"
apply_manifest "application-service/service.yml" "Application Service Service"
apply_manifest "notification-service/deployment.yml" "Notification Service Deployment"
apply_manifest "notification-service/service.yml" "Notification Service Service"

# Wait for backend services to be ready
echo -e "${YELLOW}Waiting for backend services to be ready...${NC}"
wait_for_deployment "user-service" "120s"
wait_for_deployment "job-service" "120s"
wait_for_deployment "application-service" "120s"
wait_for_deployment "notification-service" "120s"

# Step 5: Frontend + Gateway
echo -e "${GREEN}=== STEP 5: Frontend & Gateway ===${NC}"
apply_manifest "app/deployment.yml" "Flutter Web App Deployment"
apply_manifest "app/service.yml" "Flutter Web App Service"
apply_manifest "gateway/deployment.yml" "Gateway Deployment"
apply_manifest "gateway/service.yml" "Gateway Service (NodePort)"

# Wait for gateway to be ready
echo -e "${YELLOW}Waiting for gateway to be ready...${NC}"
wait_for_deployment "app" "120s"
wait_for_deployment "gateway" "120s"

# Step 6: Monitoring
echo -e "${GREEN}=== STEP 6: Monitoring ===${NC}"
apply_manifest "monitoring/prometheus-deployment.yml" "Prometheus (ConfigMap + Deployment)"
apply_manifest "monitoring/prometheus-service.yml" "Prometheus Service"
apply_manifest "monitoring/grafana-deployment.yml" "Grafana (ConfigMap + Deployment)"
apply_manifest "monitoring/grafana-service.yml" "Grafana Service"

# Wait for monitoring to be ready
echo -e "${YELLOW}Waiting for monitoring to be ready...${NC}"
wait_for_deployment "prometheus" "120s"
wait_for_deployment "grafana" "120s"

# Final Summary
echo ""
echo "=========================================="
echo -e "${GREEN}✓ All manifests applied successfully!${NC}"
echo "=========================================="
echo ""
echo "Services:"
kubectl get services -n "${NAMESPACE}" -o wide
echo ""
echo "Deployments:"
kubectl get deployments -n "${NAMESPACE}" -o wide
echo ""
echo "Pods:"
kubectl get pods -n "${NAMESPACE}" -o wide
echo ""
echo "=========================================="
echo "Access Points:"
echo "  Gateway (NodePort):     http://<node-ip>:30080"
echo "  Prometheus (ClusterIP): http://prometheus.${NAMESPACE}.svc.cluster.local:9090"
echo "  Grafana (ClusterIP):    http://grafana.${NAMESPACE}.svc.cluster.local:3000"
echo "=========================================="
