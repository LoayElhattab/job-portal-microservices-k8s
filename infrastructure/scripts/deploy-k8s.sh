#!/bin/bash
set -e
echo "Building local Docker images into Minikube..."
"$(dirname "$0")/../../k8s/apply-all.sh" "$@"