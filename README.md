# Job Portal Microservices Platform

## Overview

This repository implements a containerized job portal platform with a Flutter web frontend, an Nginx API gateway, four independently owned Node.js microservices, PostgreSQL database isolation, RabbitMQ event messaging, Prometheus metrics, Grafana dashboards, Docker Compose environments, Kubernetes manifests, and GitHub Actions validation.

This platform has been overhauled to support both local execution (via Docker Compose and Minikube) and enterprise-grade cloud deployment on Amazon Web Services (AWS) using Infrastructure as Code (Terraform). The entire software delivery lifecycle is protected by robust DevSecOps pipelines executing Static Application Security Testing (SAST), Software Composition Analysis (SCA), and Infrastructure as Code (IaC) compliance scanning.

The project is organized to demonstrate production-style microservice boundaries while still being runnable locally through Docker Compose and Minikube, or fully deployed as a resilient cloud platform on AWS.

## System Capabilities

| Capability | Implementation |
| --- | --- |
| User accounts | Registration, login, JWT authentication, and profile lookup through `user-service`. |
| Job marketplace | Employers create, update, and delete jobs; seekers and guests browse jobs through `job-service`. |
| Applications | Seekers apply for jobs and employers review application status through `application-service`. |
| Notifications | Application events create user notifications asynchronously through `notification-service`. |
| Web client | Flutter web app served by Nginx and configured at runtime through `env.json`. |
| Gateway routing | Nginx exposes one public HTTP entry point and routes `/api/v1/*` traffic to the owning service. |
| Metrics | Each backend exposes `/metrics`; Prometheus scrapes service metrics and Grafana provisions dashboards. |
| Orchestration | Docker Compose covers dev, test, and prod-like local stacks; Kubernetes manifests cover cluster deployment. |
| Cloud Infrastructure | Automated AWS VPC, private Amazon EKS (Elastic Kubernetes Service) clusters, and Amazon RDS PostgreSQL instances provisioned securely via Terraform. |
| DevSecOps | Automated static analysis (Semgrep SAST), container and dependency scanning (Trivy), and Cloud Security Posture Management / IaC linting (Checkov) integrated in GitHub Actions pipelines. |

## Architecture & Routing

Client traffic enters through the gateway, which forwards each public route to the service that owns the capability.

| Public route | Owning service | Internal port |
| --- | --- | --- |
| `/api/v1/users/` | `user-service` | `3000` |
| `/api/v1/jobs/` | `job-service` | `3001` |
| `/api/v1/applications/` | `application-service` | `3002` |
| `/api/v1/notifications/` | `notification-service` | `3003` |

Each backend service exposes:

| Endpoint | Purpose |
| --- | --- |
| `/health` | Container, Compose, Kubernetes, and smoke-test health checks. |
| `/metrics` | Prometheus metrics for request rate, duration, process CPU, and memory. |
| `/api/v1/...` | Service-owned REST API routes. |

## Cloud Infrastructure & Security

The platform utilizes AWS Infrastructure as Code (IaC) located under `infrastructure/terraform/`. The design adheres to AWS Well-Architected guidelines, prioritizing security, isolation, and micro-segmentation.

### Network Architecture
- **VPC Configuration**: Managed Virtual Private Cloud (VPC) with a CIDR block of `10.0.0.0/16` spanning multiple Availability Zones (AZs) for high availability.
- **Subnet Segmentation**: 
  - **Public Subnets**: Host the NAT Gateway and Internet Gateway, providing secure outbound routing.
  - **Private Subnets**: EKS nodes, pods, and the Amazon RDS PostgreSQL instance are placed in private subnets, completely isolated from direct public internet exposure.

### Compute Infrastructure
- **Amazon EKS**: Managed Kubernetes cluster version `1.29` provisioned in the private subnets.
- **Managed Node Groups**: Run in private subnets, scaling dynamically based on load.
- **Security & Instance Hardening**: EC2 worker nodes utilize a custom launch template enforcing IMDSv2 (`http_tokens = "required"`) and encrypting local EBS volumes at rest.

### Data Layer & Security Controls
- **Amazon RDS**: Managed PostgreSQL instance in private subnets with public access disabled (`publicly_accessible = false`).
- **Security Group Micro-segmentation**: Strict ingress rules limit access to the RDS database. Only traffic originating from the EKS nodes security group is allowed on port `5432`.
- **Encryption at Rest**: AWS Key Management Service (KMS) is integrated to handle transparent encryption at rest for the RDS database (`storage_encrypted = true`) and EKS node volumes.

## Services, Asynchronous Messaging, & Data Ownership

### Services
| Service | Path | Responsibility | Database |
| --- | --- | --- | --- |
| User service | `services/user-service` | Register users, authenticate credentials, issue JWTs, return current profile. | `user_db` |
| Job service | `services/job-service` | Create jobs, list/search jobs, fetch one job, update owned jobs, soft-delete jobs. | `job_db` |
| Application service | `services/application-service` | Create applications, enforce duplicate protection, list role-specific applications, update status. | `application_db` |
| Notification service | `services/notification-service` | Consume application events and expose paginated notifications for the current user. | `notification_db` |

The services share infrastructure, but they do not share application tables. Cross-service references are stored as UUID values instead of database joins.

### Asynchronous Messaging
RabbitMQ decouples application writes from notification delivery.

| Producer | Consumer | Exchange | Type | Routing keys |
| --- | --- | --- | --- | --- |
| `application-service` | `notification-service` | `application_events` | `topic` | `application.submitted`, `application.status_changed` |

The producer lives in `services/application-service/rabbitmq/publisher.js`. The consumer lives in `services/notification-service/rabbitmq/consumer.js`. This means `application-service` can persist the application or status change, publish an event, and return the API response while `notification-service` handles notification creation independently.

### Data Ownership
PostgreSQL runs as one shared infrastructure instance per environment, but each service owns a separate logical database.

| Database | Owner | Initialized by |
| --- | --- | --- |
| `user_db` | `user-service` | `infrastructure/databases/init-databases.sql` (Local Compose) / `infrastructure/terraform/k8s/rds-init-job.yaml` (AWS RDS) |
| `job_db` | `job-service` | `infrastructure/databases/init-databases.sql` (Local Compose) / `infrastructure/terraform/k8s/rds-init-job.yaml` (AWS RDS) |
| `application_db` | `application-service` | `infrastructure/databases/init-databases.sql` (Local Compose) / `infrastructure/terraform/k8s/rds-init-job.yaml` (AWS RDS) |
| `notification_db` | `notification-service` | `infrastructure/databases/init-databases.sql` (Local Compose) / `infrastructure/terraform/k8s/rds-init-job.yaml` (AWS RDS) |

Each service runs its own startup migration so tables are created by the code that owns them.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `app/` | Flutter web application with Clean Architecture-style features, BLoC state management, and runtime API config. |
| `gateway/` | Nginx Docker image and environment-specific routing configs for dev, test, prod, and Kubernetes. |
| `services/` | Node.js backend services, one folder per bounded context. |
| `infrastructure/databases/` | Shared PostgreSQL initialization script that creates the service databases for local deployment. |
| `infrastructure/monitoring/` | Prometheus scrape config and Grafana dashboard/datasource provisioning. |
| `infrastructure/scripts/` | Helper scripts for starting or stopping all local Compose environments and delegating Kubernetes deployment. |
| `infrastructure/terraform/` | Terraform modules for provisioning VPC networking, IAM policies, RDS instance, EKS cluster, and Node Groups. |
| `k8s/` | Kubernetes namespace, config, secrets, infrastructure, service, frontend, gateway, and monitoring manifests. |
| `docs/` | API, architecture, deployment, setup, and internal blueprint documentation. |
| `.github/workflows/` | GitHub Actions workflow definitions executing build, test, and security validations (Semgrep SAST, Trivy vulnerability scans, Checkov IaC posture checks, E2E Compose integration). |

### Documentation Map

| Document | Purpose |
| --- | --- |
| `docs/api.md` | Public API envelope, authentication model, routes, roles, pagination, and RabbitMQ event contract. |
| `docs/architecture.md` | Service boundaries, routing, async flow, data ownership, observability, and compliance mapping. |
| `docs/setup.md` | Local prerequisites, environment setup, Compose commands, ports, and shared environment variables. |
| `docs/deployment.md` | Minikube workflow, image builds, manifest order, NodePort access, and validation commands. |
| `docs/master-blueprint.md` | File-by-file platform reference for backend, infrastructure, orchestration, CI, and docs. |

## Local Prerequisites & Environment Files

### Local Prerequisites
Install the following dependencies for local execution:

| Tool | Purpose |
| --- | --- |
| Docker with Compose | Run local dev, test, and prod-like stacks. |
| Node.js and npm | Run backend service tests outside containers if desired. |
| Flutter SDK | Run or test the web app outside containers if desired. |
| Minikube and `kubectl` | Validate Kubernetes deployment locally. |
| Git Bash or a POSIX shell | Run the included `.sh` helper scripts on Windows. |

### Environment Files
Copy the examples before first use:

```bash
cp .env.dev.example .env.dev
cp .env.test.example .env.test
cp .env.prod.example .env.prod
```

The environment files define:

| Variable group | Purpose |
| --- | --- |
| `JWT_SECRET` | Shared JWT signing and validation secret for all backend services. |
| `DB_*` | Database host, port, user, and password used by service containers. |
| `*_SERVICE_DB` | Logical database names for each service boundary. |
| `POSTGRES_*` | PostgreSQL container bootstrap credentials and default database. |
| `RABBITMQ_*` | RabbitMQ credentials and AMQP connection URL for async messaging. |
| `GF_SECURITY_*` | Grafana admin credentials for the development monitoring stack. |

## Running Locally (Docker Compose)

### Development Environment
Development uses `docker-compose.dev.yml`. Backend services use `Dockerfile.dev`, run with `nodemon`, and mount source folders read-only for local iteration.

Start development:
```bash
docker compose -f docker-compose.dev.yml -p jobportal-dev up -d --build
```

Stop development:
```bash
docker compose -f docker-compose.dev.yml -p jobportal-dev down
```

Recreate the development database volume if an older local schema conflicts with current migrations:
```bash
docker compose -f docker-compose.dev.yml -p jobportal-dev down -v
docker compose -f docker-compose.dev.yml -p jobportal-dev up -d --build
```

#### Development Ports
| Component | URL |
| --- | --- |
| Gateway | `http://localhost:3100` |
| Flutter app | `http://localhost:3105` |
| User service | `http://localhost:3101` |
| Job service | `http://localhost:3102` |
| Application service | `http://localhost:3103` |
| Notification service | `http://localhost:3104` |
| PostgreSQL | `localhost:3110` |
| RabbitMQ AMQP | `localhost:3111` |
| RabbitMQ Management | `http://localhost:3112` |
| Prometheus | `http://localhost:3120` |
| Grafana | `http://localhost:3121` |

### Testing Environment
Testing uses `docker-compose.test.yml`. It builds services from production Dockerfiles and runs on isolated container names, networks, volumes, and host ports.

Start testing:
```bash
docker compose -f docker-compose.test.yml -p jobportal-test up -d --build
```

Stop testing:
```bash
docker compose -f docker-compose.test.yml -p jobportal-test down
```

#### Testing Ports
| Component | URL |
| --- | --- |
| Gateway | `http://localhost:3200` |
| Flutter app | `http://localhost:3205` |
| User service | `http://localhost:3201` |
| Job service | `http://localhost:3202` |
| Application service | `http://localhost:3203` |
| Notification service | `http://localhost:3204` |
| PostgreSQL | `localhost:3210` |
| RabbitMQ AMQP | `localhost:3211` |
| RabbitMQ Management | `http://localhost:3212` |

### Production-Style Compose Environment
Production Compose uses `docker-compose.prod.yml`. It builds production images, runs on its own network and volumes, and exposes a separate local port range.

Start production-style Compose:
```bash
docker compose -f docker-compose.prod.yml -p jobportal-prod up -d --build
```

Stop production-style Compose:
```bash
docker compose -f docker-compose.prod.yml -p jobportal-prod down
```

#### Production Compose Ports
| Component | URL |
| --- | --- |
| Gateway | `http://localhost:3300` |
| Flutter app | `http://localhost:3305` |
| User service | `http://localhost:3301` |
| Job service | `http://localhost:3302` |
| Application service | `http://localhost:3303` |
| Notification service | `http://localhost:3304` |
| PostgreSQL | `localhost:3310` |
| RabbitMQ AMQP | `localhost:3311` |
| RabbitMQ Management | `http://localhost:3312` |

### Running All Compose Environments
The three Compose environments can run at the same time because they use separate projects, networks, containers, volumes, and host ports.

| Environment | Gateway | App | Services | PostgreSQL | RabbitMQ | Monitoring |
| --- | --- | --- | --- | --- | --- | --- |
| Development | `3100` | `3105` | `3101-3104` | `3110` | `3111-3112` | `3120-3121` |
| Testing | `3200` | `3205` | `3201-3204` | `3210` | `3211-3212` | Not enabled |
| Production Compose | `3300` | `3305` | `3301-3304` | `3310` | `3311-3312` | Not enabled |

Start all environments:
```bash
./infrastructure/scripts/start-all.sh
```

Stop all environments:
```bash
./infrastructure/scripts/stop-all.sh
```

## Kubernetes Deployment (Minikube)

Kubernetes manifests in `k8s/` deploy the same platform shape used by Compose:

1. Namespace.
2. ConfigMap and Secret.
3. PostgreSQL and RabbitMQ.
4. Backend services.
5. Flutter web app and gateway.
6. Prometheus and Grafana monitoring.

Start Minikube:
```bash
minikube start
```

Use the Minikube Docker daemon before building local images:
```bash
eval "$(minikube docker-env)"
```

Build the images expected by the manifests:
```bash
docker build -t jobportal/user-service:latest ./services/user-service
docker build -t jobportal/job-service:latest ./services/job-service
docker build -t jobportal/application-service:latest ./services/application-service
docker build -t jobportal/notification-service:latest ./services/notification-service
docker build -t jobportal/app:latest ./app
docker build -t jobportal/gateway:latest ./gateway
```

Apply the platform:
```bash
./k8s/apply-all.sh
```

The gateway is exposed as a NodePort:

| Field | Value |
| --- | --- |
| Service | `k8s/gateway/service.yml` |
| Type | `NodePort` |
| Service port | `80` |
| NodePort | `30080` |

Open the app through Minikube:
```bash
http://$(minikube ip):30080
```

## AWS Terraform Deployment

To deploy production-grade infrastructure on AWS, use the Terraform modules defined in `infrastructure/terraform/`.

### Deployment Lifecycle
Navigate to the directory:
```bash
cd infrastructure/terraform
```

Initialize the backend and provider plugins:
```bash
terraform init
```

Validate the syntactical correctness of the configurations:
```bash
terraform validate
```

Generate and save the execution plan:
```bash
terraform plan -out=tfplan
```

Apply the configuration to provision resources in AWS:
```bash
terraform apply tfplan
```

### Contextual Integration with Kubernetes
Following a successful `terraform apply`, retrieve the outputs needed to configure the Kubernetes deployments inside EKS:

1. **Kubeconfig Alignment**: Configure your local terminal to interact with the new cluster:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw eks_cluster_name)
   ```
2. **Access Output Variables**: Retrieve the RDS database endpoint, master user, and generated sensitive password:
   ```bash
   # Retrieve database host endpoint
   terraform output -raw rds_endpoint

   # Retrieve master username
   terraform output -raw rds_username

   # Retrieve RDS master password (sensitive)
   terraform output -raw rds_password
   ```
3. **Apply Configuration in Cluster**: Set up the production ConfigMap and Secret inside the EKS cluster using the retrieved outputs:
   ```bash
   # Create Kubernetes Secrets with the sensitive RDS password and JWT secret
   kubectl create secret generic jobportal-secrets \
     --from-literal=DB_PASSWORD="<RETRIEVED_RDS_PASSWORD>" \
     --from-literal=JWT_SECRET="<YOUR_PRODUCTION_JWT_SECRET>" \
     -n jobportal-prod

   # Create ConfigMap with the non-sensitive RDS endpoint details
   kubectl create configmap jobportal-config \
     --from-literal=DB_HOST="<RETRIEVED_RDS_ENDPOINT>" \
     --from-literal=DB_PORT="5432" \
     --from-literal=DB_USER="jobportal" \
     -n jobportal-prod
   ```
4. **Initialize logical databases on RDS**: Execute the database initialization Job inside the EKS cluster. This job boots a transient PostgreSQL container inside the VPC to provision logical database schemas:
   ```bash
   kubectl apply -f infrastructure/terraform/k8s/rds-init-job.yaml -n jobportal-prod
   ```

### Production Upgrades
For cost savings during development, the default Terraform variables are sized minimally. For production rollouts, upgrade the parameters as detailed in the matrix below:

| Feature / Variable | Development / Staging Default | Production Target | Architectural Rationale |
| --- | --- | --- | --- |
| RDS High Availability | `multi_az = false` | `multi_az = true` | Deploys synchronous secondary replicas across multiple Availability Zones for zero-data-loss failover. |
| RDS Instance Scaling | `db.t4g.micro` | `db.r6g.large` (or larger) | Memory-optimized instance classes suitable for high-throughput, latency-critical relational databases. |
| Storage Autoscaling | Fixed 20GB size | Enabled scaling up to 1000GB | Allows dynamic storage expansion to prevent database crashes when disk capacity is exhausted. |
| RDS Deletion Protection | `deletion_protection = false` | `deletion_protection = true` | Adds a safety layer preventing the database instance from being accidentally terminated during Terraform sweeps. |
| Secrets Management | Kubernetes Secrets | AWS Secrets Manager + External Secrets Operator | Enables automated secret rotation, compliance audits, and tight integration with AWS KMS. |
| EKS API Control Plane | `endpoint_public_access = true` | `endpoint_public_access = false` | Restricts EKS cluster management interface to the private network. Requires VPN or Bastion for administrative access. |
| Public Traffic Routing | Service NodePort | AWS Load Balancer Controller (ALB Ingress) | Integrates AWS Application Load Balancer for automated SSL/TLS termination, WAF protection, and routing. |
| Key Management | AWS Managed Keys | Customer Managed Keys (CMK) in KMS | Grants granular control over key rotation policy, resource access tracking, and security audits. |

## API Contract Snapshot

All public APIs are exposed through the gateway under `/api/v1`.

Success response envelope:
```json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

Error response envelope:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message"
  }
}
```

### Authentication
| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `POST` | `/api/v1/users/register` | No | Any | Register a user with role `seeker` or `employer`. |
| `POST` | `/api/v1/users/login` | No | Any | Authenticate and receive a JWT. |
| `GET` | `/api/v1/users/profile` | Bearer JWT | `seeker` or `employer` | Return the current user's profile. |

### Jobs
| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `POST` | `/api/v1/jobs` | Bearer JWT | `employer` | Create a job. |
| `GET` | `/api/v1/jobs` | No | Any | List jobs with optional search and pagination filters. |
| `GET` | `/api/v1/jobs/:id` | No | Any | Get one job by UUID. |
| `PATCH` | `/api/v1/jobs/:id` | Bearer JWT | Owning `employer` | Update a job. |
| `DELETE` | `/api/v1/jobs/:id` | Bearer JWT | Owning `employer` | Delete a job. |

### Applications
| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `POST` | `/api/v1/applications` | Bearer JWT | `seeker` | Apply for a job. |
| `GET` | `/api/v1/applications` | Bearer JWT | `seeker` or `employer` | List applications visible to the current user. |
| `PATCH` | `/api/v1/applications/:id/status` | Bearer JWT | Owning `employer` | Update application status. |

### Notifications
| Method | Path | Auth | Role | Description |
| --- | --- | --- | --- | --- |
| `GET` | `/api/v1/notifications` | Bearer JWT | `seeker` or `employer` | List current user's notifications with pagination. |

Full API details live in `docs/api.md`.

## Observability

Development and Kubernetes monitoring use Prometheus and Grafana.

| Component | Local path | Purpose |
| --- | --- | --- |
| Prometheus | `infrastructure/monitoring/prometheus/prometheus.yml` | Scrapes backend `/metrics` endpoints every 15 seconds in development. |
| Grafana datasource | `infrastructure/monitoring/grafana/provisioning/datasources/datasource.yml` | Provisions Prometheus as the default Grafana datasource. |
| Grafana dashboards | `infrastructure/monitoring/grafana/provisioning/dashboards/` | Loads the Job Portal dashboard for service latency, CPU, memory, request distribution, and health. |
| Kubernetes monitoring | `k8s/monitoring/` | Deploys Prometheus, Grafana, and their internal services in the cluster namespace. |

Runtime logs are available through the active runtime:

```bash
docker compose -f docker-compose.dev.yml -p jobportal-dev logs -f
kubectl logs -n jobportal-prod deployment/user-service
```

## Validation Commands

Validate Compose files:
```bash
docker compose --env-file .env.dev -f docker-compose.dev.yml config --quiet
docker compose --env-file .env.test -f docker-compose.test.yml config --quiet
```

Validate Terraform:
```bash
cd infrastructure/terraform && terraform validate
```

Run backend tests:
```bash
cd services/user-service && npm test
cd services/job-service && npm test
cd services/application-service && npm test
cd services/notification-service && npm test
```

Run Flutter tests:
```bash
cd app && flutter test
```

Validate Kubernetes manifests:
```bash
kubectl apply --dry-run=client -f k8s/00-namespace.yml
kubectl apply --dry-run=client -f k8s/01-configmap.yml
kubectl apply --dry-run=client -f k8s/02-secrets.yml
```

Check running Kubernetes workloads:
```bash
kubectl get pods -n jobportal-prod
kubectl get services -n jobportal-prod
kubectl rollout status deployment/gateway -n jobportal-prod
```

## CI/CD & DevSecOps Coverage

The pipeline is fully automated using GitHub Actions. It validates code quality, executes tests, and verifies security configuration at the application, container, and infrastructure layers.

| Workflow File | Scope | Triggers | Key Validations & Tools |
| --- | --- | --- | --- |
| `ci-user-service.yml` | User Service | PR/Push to dev/main (matching paths) | Runs Node.js installation (`npm ci`) and backend unit tests. |
| `ci-job-service.yml` | Job Service | PR/Push to dev/main (matching paths) | Runs Node.js installation and backend unit tests. |
| `ci-application-service.yml` | Application Service | PR/Push to dev/main (matching paths) | Runs Node.js installation and backend unit tests. |
| `ci-notification-service.yml` | Notification Service | PR/Push to dev/main (matching paths) | Runs Node.js installation and backend unit tests. |
| `ci-flutter.yml` | Flutter App | PR/Push to dev/main (matching paths) | Installs Flutter SDK, resolves dependencies, compiles mocks, and runs tests. |
| `ci-gateway.yml` | API Gateway | PR/Push to dev/main (matching paths) | Lints the Nginx gateway configuration and Dockerfile structure. |
| `ci-infra.yml` | Shell scripts & databases | PR/Push to dev/main (matching paths) | Validates DB init SQL and executes `shellcheck` against local orchestration scripts. |
| `ci-k8s.yml` | K8s Manifests | PR/Push to dev/main (matching paths) | Dry-run validates Kubernetes manifests using `kubectl apply --dry-run=client`. |
| `ci-sec-sast.yml` | Static Analysis (SAST) | PR/Push to dev/main | Runs **Semgrep** scans on code files to identify potential application vulnerabilities. |
| `ci-sec-container.yml` | Vulnerability Scanning (SCA/IaC) | PR/Push to dev/main | Runs **Trivy** to scan dependencies and container images, and **Checkov** to inspect Terraform configuration files and Kubernetes manifests. |
| `e2e-tests.yml` | Integration Smoke Tests | PR/Push/Workflow Dispatch | Orchestrates testing Compose stacks, executes health-check validations, runs gateway endpoint checks, and verifies seeker user registration. |

### DevSecOps Scanning Engine Breakdown

#### Semgrep (SAST)
- **Purpose**: Static Application Security Testing.
- **Scope**: Scans all Javascript (Node.js microservices) and Dart (Flutter app) codebases.
- **Details**: Detects application-level flaws like SQL/command injection, insecure dependencies, improper cryptographic function calls, missing authorization middleware, and leaked credentials in code files.

#### Trivy (SCA & Container Security)
- **Purpose**: Software Composition Analysis (SCA) and Container Image Security.
- **Scope**: Scans NPM package-lock files, Flutter pubspec manifests, and packaged Docker images.
- **Details**: Identifies known Common Vulnerabilities and Exposures (CVEs) within third-party packages, libraries, and container base OS layers (e.g., node-alpine and nginx-alpine), blocking integration if high-severity CVEs are uncovered.

#### Checkov (IaC Security Compliance)
- **Purpose**: Cloud Security Posture Management (CSPM) and Infrastructure as Code scanning.
- **Scope**: Analyzes Terraform configurations (`infrastructure/terraform/`) and Kubernetes manifests (`k8s/`).
- **Details**: Checks configurations against industry benchmarks (CIS, NIST). It flags issues such as publicly accessible EKS API endpoints, unencrypted RDS storage databases, missing Kubernetes resource constraints, root container executions, or overly permissive security groups.

#### E2E Integration Smoke Testing
- **Purpose**: Functional API verification and service interaction validation.
- **Scope**: Orchestrated using Docker Compose in a clean, self-contained GitHub Actions runner.
- **Details**: Builds production-grade containers, provisions a testing Compose stack, performs parallel health check probes on all microservices and gateway ports, tests user registration flows, and asserts runtime environment configuration distribution (`env.json`).

## Compliance Matrix

| Security / Design Requirement | Project Evidence |
| --- | --- |
| Multiple services | Four Node.js services under `services/`, each with its own source, Dockerfile, tests, and package lock. |
| API gateway | `gateway/` contains Nginx configs for dev, test, prod, and Kubernetes routing. |
| Database per service | `init-databases.sql` (Local) / `rds-init-job.yaml` (AWS) creates separate logical databases, and each service migrates its own tables. |
| Async communication | `application-service` publishes RabbitMQ topic events; `notification-service` consumes them and writes notifications. |
| Dockerized stack | `docker-compose.dev.yml`, `docker-compose.test.yml`, and `docker-compose.prod.yml` run isolated local environments. |
| Kubernetes orchestration | `k8s/` includes namespace, config, secrets, infrastructure, services, frontend, gateway, and monitoring manifests. |
| Metrics and dashboards | Backend `/metrics` endpoints feed Prometheus; Grafana provisions a project dashboard automatically. |
| CI validation | GitHub Actions validate service tests, Flutter tests, gateway linting, infrastructure, and Kubernetes manifests. |
| Documentation | `docs/` documents setup, API, architecture, deployment, and file-level platform responsibilities. |
| **Infrastructure as Code** | AWS VPC, private EKS cluster, RDS PostgreSQL instance, security groups, and KMS encryption keys declared and managed via Terraform in `infrastructure/terraform/`. |
| **Vulnerability Management** | Automated pipelines run Semgrep (SAST) for source code analysis, Trivy (SCA/container) for dependencies and base images, and Checkov for IaC posture validation. |

## Operational Notes

| Task | Command |
| --- | --- |
| View development logs | `docker compose -f docker-compose.dev.yml -p jobportal-dev logs -f` |
| View one development service | `docker compose -f docker-compose.dev.yml -p jobportal-dev logs -f user-service` |
| List development containers | `docker compose -f docker-compose.dev.yml -p jobportal-dev ps` |
| Check RabbitMQ management | Open `http://localhost:3112` in development. |
| Check Prometheus targets | Open `http://localhost:3120/targets` in development. |
| Check Grafana dashboards | Open `http://localhost:3121` in development. |
| Port-forward Kubernetes Grafana | `kubectl port-forward -n jobportal-prod service/grafana 3000:3000` |
| Port-forward Kubernetes Prometheus | `kubectl port-forward -n jobportal-prod service/prometheus 9090:9090` |

## Current Platform Summary

The current platform includes:
- Flutter web frontend.
- Nginx gateway.
- User, job, application, and notification services.
- PostgreSQL with one logical database per service (local container or cloud-managed RDS).
- RabbitMQ for application lifecycle events.
- Prometheus metrics scraping.
- Grafana dashboard provisioning.
- Docker Compose development, testing, and production-style stacks.
- AWS Infrastructure as Code via Terraform (VPC, EKS, RDS, KMS, IAM).
- Kubernetes deployment manifests for local and cloud environments.
- CI workflows for service tests, frontend tests, infrastructure checks, Kubernetes validation, and Compose smoke tests.
- DevSecOps security checks integrated into CI/CD (Semgrep SAST, Trivy SCA, Checkov IaC).
