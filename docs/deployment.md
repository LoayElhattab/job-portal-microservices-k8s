# Kubernetes And Production Deployment

## Strategy

Kubernetes manifests in `k8s/` deploy the same microservices architecture used by Docker Compose:

1. Namespace, configuration, and secrets.
2. Stateful infrastructure: PostgreSQL and RabbitMQ.
3. Backend services.
4. Flutter web frontend and Nginx gateway.
5. Monitoring stack.

The gateway is exposed with a NodePort service so a local Minikube node can receive browser traffic and route REST calls to the internal services.

## Minikube Workflow

Start Minikube:

```bash
minikube start
```

Use Minikube's Docker daemon before building local images:

```bash
eval "$(minikube docker-env)"
```

Build the local images expected by the Kubernetes manifests:

```bash
docker build -t jobportal/user-service:latest ./services/user-service
docker build -t jobportal/job-service:latest ./services/job-service
docker build -t jobportal/application-service:latest ./services/application-service
docker build -t jobportal/notification-service:latest ./services/notification-service
docker build -t jobportal/app:latest ./app
docker build -t jobportal/gateway:latest ./gateway
```

The gateway Dockerfile defaults to `ENVIRONMENT=k8s`, so the Kubernetes build uses `gateway/nginx.k8s.conf`.

Apply everything:

```bash
./k8s/apply-all.sh
```

## Deployment Order

`k8s/apply-all.sh` applies manifests in this order:

| Step | Manifests |
| --- | --- |
| 1. Namespace | `k8s/00-namespace.yml` |
| 2. Config and secrets | `k8s/01-configmap.yml`, `k8s/02-secrets.yml` |
| 3. Infrastructure | `k8s/postgres/deployment.yml`, `k8s/postgres/service.yml`, `k8s/rabbitmq/deployment.yml`, `k8s/rabbitmq/service.yml` |
| 4. Backend services | `k8s/user-service/`, `k8s/job-service/`, `k8s/application-service/`, `k8s/notification-service/` |
| 5. Frontend and gateway | `k8s/app/`, `k8s/gateway/` |
| 6. Monitoring | `k8s/monitoring/` |

Init containers wait for PostgreSQL, RabbitMQ, and backend services before dependent workloads start. Backend deployments use two replicas and rolling updates where appropriate.

## Gateway Entry Point

The gateway service is defined in `k8s/gateway/service.yml`:

| Field | Value |
| --- | --- |
| Service type | `NodePort` |
| Service port | `80` |
| Target port | `80` |
| NodePort | `30080` |

Get the Minikube node IP:

```bash
minikube ip
```

Open the app through the gateway:

```bash
http://$(minikube ip):30080
```

The Flutter app uses the relative runtime API base URL `/api/v1` in Kubernetes, so browser requests return to the same NodePort gateway host.

## Useful Validation Commands

Check pods and services:

```bash
kubectl get pods -n jobportal-prod
kubectl get services -n jobportal-prod
```

Check rollout status:

```bash
kubectl rollout status deployment/user-service -n jobportal-prod
kubectl rollout status deployment/job-service -n jobportal-prod
kubectl rollout status deployment/application-service -n jobportal-prod
kubectl rollout status deployment/notification-service -n jobportal-prod
kubectl rollout status deployment/gateway -n jobportal-prod
```

Dry-run a manifest:

```bash
kubectl apply --dry-run=client -f k8s/00-namespace.yml
```

