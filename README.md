# Job Portal Microservices Platform
## System Design & Vibe Coding Specification

---

### Document Purpose
This file is the **single source of truth** for the entire project. It specifies what exists, where it lives, what it must do, and how it connects to everything else. When vibe-coding a feature, paste the relevant section of this document into the AI prompt along with the instruction: *"Generate the files listed in this specification. Do not modify files outside the specified paths."*

---

## 1. Executive Summary

A microservices-based "Mini LinkedIn Jobs" platform with:
- **6 custom Docker images** (rubric requires ≥3)
- **3 simultaneous environments** (dev/test/prod) via Docker Compose
- **Kubernetes orchestration** with Minikube
- **RabbitMQ async messaging** between Application and Notification services
- **Prometheus + Grafana monitoring** (dev only)
- **Flutter Web frontend** served via nginx

**Tech Stack:** Node.js + Express (backend), Flutter (frontend), PostgreSQL (data), RabbitMQ (messaging), Nginx (gateway), Prometheus/Grafana (monitoring), Kubernetes (orchestration).

---

## 2. Architecture & Component Mapping

### 2.1 Services

| # | Service | Responsibility | Image Name | Internal Port |
|---|---------|--------------|------------|---------------|
| 1 | **Flutter Web App** | Frontend UI | `jobportal/app` | 80 |
| 2 | **User Service** | Auth, JWT, profiles | `jobportal/user-service` | 3000 |
| 3 | **Job Service** | Job CRUD, search | `jobportal/job-service` | 3001 |
| 4 | **Application Service** | Applications, publishes RabbitMQ events | `jobportal/application-service` | 3002 |
| 5 | **Notification Service** | Consumes RabbitMQ events, notifications | `jobportal/notification-service` | 3003 |
| 6 | **API Gateway** | Reverse proxy, routing | `jobportal/gateway` | 80 |
| — | PostgreSQL | 4 logical databases | `postgres:16-alpine` | 5432 |
| — | RabbitMQ | Message broker | `rabbitmq:3.13-management-alpine` | 5672 / 15672 |
| — | Prometheus | Metrics collection | `prom/prometheus:v2.50.0` | 9090 |
| — | Grafana | Metrics visualization | `grafana/grafana:10.4.0` | 3000 |

### 2.2 Data Ownership

| Service | Database | Table(s) |
|---------|----------|----------|
| User Service | `user_db` | `users` |
| Job Service | `job_db` | `jobs` |
| Application Service | `application_db` | `applications` |
| Notification Service | `notification_db` | `notifications` |

### 2.3 Communication Patterns

**Synchronous (HTTP/REST):**
```
Flutter Web App ──→ Gateway:80 ──→ Target Service:PORT/api/v1/...
```

**Asynchronous (RabbitMQ):**
```
Application Service ──publish──→ [application_events] exchange ──consume──→ Notification Service
```

**Events:**

| Event | Routing Key | Payload | Publisher |
|-------|-------------|---------|-----------|
| `application.submitted` | `application.submitted` | `{applicationId, jobId, seekerId, employerId}` | Application Service |
| `application.status_changed` | `application.status_changed` | `{applicationId, seekerId, newStatus}` | Application Service |

---

## 3. Complete File Structure

Every file that must exist is listed below. If it is not listed, it should not exist.

```
job-portal/
│
├── app/                                    # Flutter Web Frontend — Custom Image #1
│   ├── web/
│   │   ├── index.html
│   │   └── manifest.json
│   ├── lib/
│   │   ├── main.dart                       # Entry point. Calls env_loader BEFORE runApp.
│   │   ├── app.dart                        # MaterialApp / root widget
│   │   ├── config/
│   │   │   ├── app_config.dart             # Singleton holding runtime API URL
│   │   │   ├── env_loader.dart             # Fetches /env.json, injects into AppConfig
│   │   │   ├── app_routes.dart             # GoRouter configuration
│   │   │   └── environments/
│   │   │       ├── development.dart        # Fallback defaults
│   │   │       ├── testing.dart
│   │   │       └── production.dart
│   │   ├── core/
│   │   │   ├── network/
│   │   │   │   ├── api_client.dart         # Dio singleton
│   │   │   │   └── api_interceptor.dart    # JWT injection + 401 redirect
│   │   │   ├── errors/
│   │   │   │   └── failures.dart
│   │   │   └── widgets/
│   │   │       ├── loading_widget.dart
│   │   │       └── error_widget.dart
│   │   └── features/
│   │       ├── auth/
│   │       │   ├── data/
│   │       │   │   ├── models/
│   │       │   │   │   ├── user_model.dart
│   │       │   │   │   ├── login_request_model.dart
│   │       │   │   │   └── register_request_model.dart
│   │       │   │   ├── datasources/
│   │       │   │   │   ├── auth_remote_datasource.dart
│   │       │   │   │   └── auth_local_datasource.dart
│   │       │   │   └── repositories/
│   │       │   │       └── auth_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── user.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── auth_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── login_usecase.dart
│   │       │   │       ├── register_usecase.dart
│   │       │   │       └── get_current_user_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/
│   │       │       │   ├── auth_bloc.dart
│   │       │       │   ├── auth_event.dart
│   │       │       │   └── auth_state.dart
│   │       │       ├── pages/
│   │       │       │   ├── login_page.dart
│   │       │       │   └── register_page.dart
│   │       │       └── widgets/
│   │       │           ├── login_form.dart
│   │       │           └── register_form.dart
│   │       │
│   │       ├── jobs/
│   │       │   ├── data/
│   │       │   │   ├── models/
│   │       │   │   │   ├── job_model.dart
│   │       │   │   │   └── job_filter_model.dart
│   │       │   │   ├── datasources/
│   │       │   │   │   └── job_remote_datasource.dart
│   │       │   │   └── repositories/
│   │       │   │       └── job_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── job.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── job_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── get_jobs_usecase.dart
│   │       │   │       ├── get_job_details_usecase.dart
│   │       │   │       ├── search_jobs_usecase.dart
│   │       │   │       └── post_job_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/
│   │       │       │   ├── job_bloc.dart
│   │       │       │   ├── job_event.dart
│   │       │       │   └── job_state.dart
│   │       │       ├── pages/
│   │       │       │   ├── jobs_list_page.dart
│   │       │       │   ├── job_detail_page.dart
│   │       │       │   ├── post_job_page.dart
│   │       │       │   └── my_jobs_page.dart
│   │       │       └── widgets/
│   │       │           ├── job_card.dart
│   │       │           └── job_search_bar.dart
│   │       │
│   │       ├── applications/
│   │       │   ├── data/
│   │       │   │   ├── models/
│   │       │   │   │   ├── application_model.dart
│   │       │   │   │   └── status_update_model.dart
│   │       │   │   ├── datasources/
│   │       │   │   │   └── application_remote_datasource.dart
│   │       │   │   └── repositories/
│   │       │   │       └── application_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── application.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── application_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── apply_for_job_usecase.dart
│   │       │   │       ├── get_applications_usecase.dart
│   │       │   │       └── update_application_status_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/
│   │       │       │   ├── application_bloc.dart
│   │       │       │   ├── application_event.dart
│   │       │       │   └── application_state.dart
│   │       │       ├── pages/
│   │       │       │   ├── apply_page.dart
│   │       │       │   ├── my_applications_page.dart
│   │       │       │   └── applicants_page.dart
│   │       │       └── widgets/
│   │       │           ├── application_card.dart
│   │       │           └── status_badge.dart
│   │       │
│   │       ├── notifications/
│   │       │   ├── data/
│   │       │   │   ├── models/
│   │       │   │   │   └── notification_model.dart
│   │       │   │   ├── datasources/
│   │       │   │   │   └── notification_remote_datasource.dart
│   │       │   │   └── repositories/
│   │       │   │       └── notification_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── notification.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── notification_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── get_notifications_usecase.dart
│   │       │   │       └── mark_as_read_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── bloc/
│   │       │       │   ├── notification_bloc.dart
│   │       │       │   ├── notification_event.dart
│   │       │       │   └── notification_state.dart
│   │       │       ├── pages/
│   │       │       │   └── notifications_page.dart
│   │       │       └── widgets/
│   │       │           └── notification_tile.dart
│   │       │
│   │       └── profile/
│   │           ├── data/
│   │           │   ├── models/
│   │           │   │   └── profile_model.dart
│   │           │   ├── datasources/
│   │           │   │   └── profile_remote_datasource.dart
│   │           │   └── repositories/
│   │           │       └── profile_repository_impl.dart
│   │           ├── domain/
│   │           │   ├── entities/
│   │           │   │   └── profile.dart
│   │           │   ├── repositories/
│   │           │   │   └── profile_repository.dart
│   │           │   └── usecases/
│   │           │       └── get_profile_usecase.dart
│   │           └── presentation/
│   │               ├── bloc/
│   │               │   ├── profile_bloc.dart
│   │               │   ├── profile_event.dart
│   │               │   └── profile_state.dart
│   │               ├── pages/
│   │               │   └── profile_page.dart
│   │               └── widgets/
│   │                   └── profile_header.dart
│   │
│   ├── docker-entrypoint.sh                # Generates env.json from env vars at runtime
│   ├── env.template.json                   # Template for env.json generation
│   ├── Dockerfile                            # Multi-stage: Flutter build → nginx serve
│   ├── nginx.conf                            # Serves static files + /env.json
│   ├── .dockerignore
│   └── pubspec.yaml
│
├── services/
│   ├── user-service/                         # Custom Image #2
│   │   ├── src/
│   │   │   ├── controllers/
│   │   │   │   └── users.controller.js       # Express route handlers
│   │   │   ├── middleware/
│   │   │   │   ├── auth.js                   # JWT verify, attach {userId, email, role}
│   │   │   │   └── errorHandler.js           # Global error handler, spec envelope
│   │   │   ├── routes/
│   │   │   │   └── users.routes.js           # Route definitions → controller
│   │   │   ├── services/
│   │   │   │   └── users.service.js          # Business logic + DB queries
│   │   │   ├── utils/
│   │   │   │   ├── ApiError.js               # Custom error class
│   │   │   │   └── ApiResponse.js            # Success envelope helper
│   │   │   ├── index.js                      # Express entry point, /health, /metrics
│   │   │   ├── db.js                         # Postgres pool + migration (users table) + retry loop
│   │   │   └── metrics.js                    # prom-client registry + HTTP histogram
│   │   ├── __tests__/
│   │   │   └── users.test.js                 # Jest + Supertest API tests
│   │   ├── Dockerfile                        # Multi-stage production build
│   │   ├── Dockerfile.dev                    # nodemon + bind mount
│   │   ├── jest.config.js
│   │   ├── .dockerignore
│   │   ├── package.json
│   │   └── .env.example
│   │
│   ├── job-service/                          # Custom Image #3
│   │   ├── src/
│   │   │   ├── controllers/
│   │   │   │   └── jobs.controller.js        # Express route handlers
│   │   │   ├── middleware/
│   │   │   │   ├── auth.js
│   │   │   │   └── errorHandler.js
│   │   │   ├── routes/
│   │   │   │   └── jobs.routes.js            # Route definitions → controller
│   │   │   ├── services/
│   │   │   │   └── jobs.service.js           # Business logic + DB queries
│   │   │   ├── utils/
│   │   │   │   ├── ApiError.js
│   │   │   │   └── ApiResponse.js
│   │   │   ├── index.js                      # Express entry point, /health, /metrics
│   │   │   ├── db.js                         # Postgres pool + migration (jobs table) + retry loop
│   │   │   └── metrics.js
│   │   ├── __tests__/
│   │   │   └── jobs.test.js                  # Jest + Supertest API tests
│   │   ├── Dockerfile
│   │   ├── Dockerfile.dev
│   │   ├── jest.config.js
│   │   ├── .dockerignore
│   │   ├── package.json
│   │   └── .env.example
│   │
│   ├── application-service/                  # Custom Image #4
│   │   ├── src/
│   │   │   ├── controllers/
│   │   │   │   └── applications.controller.js
│   │   │   ├── middleware/
│   │   │   │   ├── auth.js
│   │   │   │   └── errorHandler.js
│   │   │   ├── routes/
│   │   │   │   └── applications.routes.js
│   │   │   ├── services/
│   │   │   │   └── applications.service.js   # Business logic + DB queries, calls publisher
│   │   │   ├── utils/
│   │   │   │   ├── ApiError.js
│   │   │   │   └── ApiResponse.js
│   │   │   ├── index.js                      # Express entry point, /health, /metrics
│   │   │   ├── db.js                         # Postgres pool + migration (applications table)
│   │   │   └── metrics.js
│   │   ├── rabbitmq/
│   │   │   └── publisher.js                  # RabbitMQ connection + event publishing
│   │   ├── __tests__/
│   │   │   └── applications.test.js          # Jest + Supertest API tests
│   │   ├── Dockerfile
│   │   ├── Dockerfile.dev
│   │   ├── jest.config.js
│   │   ├── .dockerignore
│   │   ├── package.json
│   │   └── .env.example
│   │
│   └── notification-service/                 # Custom Image #5
│       ├── src/
│       │   ├── controllers/
│       │   │   └── notifications.controller.js
│       │   ├── middleware/
│       │   │   ├── auth.js
│       │   │   └── errorHandler.js
│       │   ├── routes/
│       │   │   └── notifications.routes.js
│       │   ├── services/
│       │   │   └── notifications.service.js  # DB queries for notifications
│       │   ├── utils/
│       │   │   ├── ApiError.js
│       │   │   └── ApiResponse.js
│       │   ├── index.js                      # Express entry point, starts consumer, /health, /metrics
│       │   ├── db.js                         # Postgres pool + migration (notifications table)
│       │   └── metrics.js
│       ├── rabbitmq/
│       │   └── consumer.js                   # RabbitMQ connection + event consumption
│       ├── __tests__/
│       │   └── notifications.test.js         # Jest + Supertest API tests
│       ├── Dockerfile
│       ├── Dockerfile.dev
│       ├── jest.config.js
│       ├── .dockerignore
│       ├── package.json
│       └── .env.example
│
├── gateway/                                  # Custom Image #6
│   ├── Dockerfile                            # Bakes nginx.{env}.conf into image
│   ├── nginx.dev.conf                        # Dev routing: upstreams = *-dev:PORT
│   ├── nginx.test.conf                       # Test routing: upstreams = *-test:PORT
│   ├── nginx.prod.conf                       # Prod routing: upstreams = *-prod:PORT
│   └── .dockerignore
│
├── infrastructure/
│   ├── databases/
│   │   └── init-databases.sql                # CREATE DATABASE for all 4 services
│   ├── monitoring/
│   │   ├── prometheus/
│   │   │   └── prometheus.yml                # Static scrape config for 4 services
│   │   └── grafana/
│   │       └── provisioning/
│   │           ├── datasources/
│   │           │   └── datasource.yml          # Auto-provisions Prometheus source
│   │           └── dashboards/
│   │               ├── dashboards.yml          # Auto-imports dashboard JSON
│   │               └── jobportal-dashboard.json # Actual dashboard definition
│   └── scripts/
│       ├── start-all.sh                      # Spins up dev + test + prod simultaneously
│       ├── stop-all.sh                       # Tears down all 3 environments
│       └── deploy-k8s.sh                     # Builds images + applies K8s manifests
│
├── k8s/
│   ├── apply-all.sh                          # Ordered apply: namespace → config → secrets → infra → services → monitoring
│   ├── 00-namespace.yml                      # Creates jobportal-prod namespace
│   ├── 01-configmap.yml                      # Non-sensitive env vars
│   ├── 02-secrets.yml                        # Base64-encoded secrets
│   ├── postgres/
│   │   ├── deployment.yml                    # Recreate strategy, init SQL ConfigMap
│   │   └── service.yml                       # ClusterIP, port 5432
│   ├── rabbitmq/
│   │   ├── deployment.yml
│   │   └── service.yml                       # ClusterIP, ports 5672 + 15672
│   ├── user-service/
│   │   ├── deployment.yml                    # 2 replicas, RollingUpdate, probes
│   │   └── service.yml                       # ClusterIP, port 3000
│   ├── job-service/
│   │   ├── deployment.yml
│   │   └── service.yml                       # ClusterIP, port 3001
│   ├── application-service/
│   │   ├── deployment.yml
│   │   └── service.yml                       # ClusterIP, port 3002
│   ├── notification-service/
│   │   ├── deployment.yml
│   │   └── service.yml                       # ClusterIP, port 3003
│   ├── app/
│   │   ├── deployment.yml                    # Flutter web nginx container
│   │   └── service.yml                       # ClusterIP, port 80
│   ├── gateway/
│   │   ├── deployment.yml
│   │   └── service.yml                       # NodePort, external entry point
│   └── monitoring/
│       ├── prometheus-deployment.yml
│       ├── prometheus-service.yml            # ClusterIP, port 9090
│       ├── grafana-deployment.yml
│       └── grafana-service.yml               # ClusterIP, port 3000
│
├── docs/
│   ├── architecture.md
│   ├── setup.md
│   ├── deployment.md
│   ├── api.md
│   └── diagrams/
│       └── system-architecture.png
│
├── docker-compose.dev.yml                    # Full stack, 3100s, hot reload, monitoring
├── docker-compose.test.yml                   # Full stack, 3200s, prod Dockerfiles, no monitoring
├── docker-compose.prod.yml                   # Full stack, 3300s, prod Dockerfiles, no monitoring
├── .env.dev                                  # Actual dev secrets (gitignored)
├── .env.test                                 # Actual test secrets (gitignored)
├── .env.prod                                 # Actual prod secrets (gitignored)
├── .env.example                              # Template showing all required variables
├── .gitignore
└── README.md                                 # This file
```

---

## 4. Environment Variable Contract

Copy `.env.example` to `.env.dev`, `.env.test`, `.env.prod`. Fill in real values. Never commit the `.env.*` files.

### Required Variables

```bash
# Global
NODE_ENV=development          # development | test | production
JWT_SECRET=<64-char-hex>     # Shared across all services. Generate with crypto.randomBytes(64)

# Database (shared connection params)
DB_HOST=postgres-dev          # Changes per env: postgres-test, postgres-prod
DB_PORT=5432
DB_USER=jobportal
DB_PASSWORD=<change-me>

# Service-specific DB names
USER_SERVICE_DB=user_db
JOB_SERVICE_DB=job_db
APPLICATION_SERVICE_DB=application_db
NOTIFICATION_SERVICE_DB=notification_db

# Postgres container init (must match DB_USER/DB_PASSWORD)
POSTGRES_USER=jobportal
POSTGRES_PASSWORD=<change-me>
POSTGRES_DB=postgres          # Default DB for health checks

# RabbitMQ
RABBITMQ_USER=jobportal
RABBITMQ_PASS=<change-me>
RABBITMQ_URL=amqp://jobportal:<pass>@rabbitmq-dev:5672

# Grafana
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=<change-me>
```

---

## 5. Port Map

| Service | Internal | Dev Host | Test Host | Prod Host |
|---------|----------|----------|-----------|-----------|
| Gateway | 80 | 3100 | 3200 | 3300 |
| User Service | 3000 | 3101 | 3201 | 3301 |
| Job Service | 3001 | 3102 | 3202 | 3302 |
| Application Service | 3002 | 3103 | 3203 | 3303 |
| Notification Service | 3003 | 3104 | 3204 | 3304 |
| Flutter Web | 80 | 3105 | 3205 | 3305 |
| PostgreSQL | 5432 | 3110 | 3210 | 3310 |
| RabbitMQ AMQP | 5672 | 3111 | 3211 | 3311 |
| RabbitMQ Mgmt UI | 15672 | 3112 | 3212 | 3312 |
| Prometheus | 9090 | 3120 | — | — |
| Grafana | 3000 | 3121 | — | — |

**Note:** Prometheus and Grafana exist **only in dev** to save RAM. Test and prod omit them.

---

## 6. Docker Compose Specification

### 6.1 Dev Environment (`docker-compose.dev.yml`)

**Requirements:**
- Project name: `jobportal-dev`
- Network: `jobportal-dev-network` (bridge)
- All services use `restart: unless-stopped`
- All backend services use `Dockerfile.dev` (nodemon + bind mount)
- All backend services expose host ports 3101–3104 for debugging
- Gateway uses `nginx:1.25-alpine` and mounts `nginx.dev.conf`
- Postgres uses `postgres:16-alpine`, named volume `postgres-dev-data`, mounts `init-databases.sql`
- RabbitMQ uses `rabbitmq:3.13-management-alpine`, ports 3111 + 3112
- Prometheus uses `prom/prometheus:v2.50.0`, mounts `prometheus.yml`
- Grafana uses `grafana/grafana:10.4.0`, mounts provisioning folder
- **Health checks** on every service (see Section 8)
- **Depends on with condition:** backend services wait for postgres + rabbitmq healthy. Gateway waits for all backends healthy. Grafana waits for Prometheus healthy.

### 6.2 Test Environment (`docker-compose.test.yml`)

Identical to dev except:
- Project name: `jobportal-test`
- Network: `jobportal-test-network`
- Ports: 3200s
- Uses production `Dockerfile` (no bind mounts, no nodemon)
- No Prometheus/Grafana
- `NODE_ENV=test` explicitly set

### 6.3 Prod Environment (`docker-compose.prod.yml`)

Identical to test except:
- Project name: `jobportal-prod`
- Network: `jobportal-prod-network`
- Ports: 3300s
- `NODE_ENV=production`

### 6.4 Scripts

**`start-all.sh`:** Runs `docker compose -p jobportal-dev -f docker-compose.dev.yml up -d --build`, then test, then prod. Verifies `.env.*` files exist first.

**`stop-all.sh`:** Runs `docker compose down` for all three environments.

---

## 7. Kubernetes Specification

### 7.1 Manifests

All files live in `k8s/`. Applied in order via `apply-all.sh`:

1. `00-namespace.yml` — creates `jobportal-prod`
2. `01-configmap.yml` — all non-sensitive env vars
3. `02-secrets.yml` — base64-encoded secrets
4. `postgres/deployment.yml` + `service.yml`
5. `rabbitmq/deployment.yml` + `service.yml`
6. `user-service/deployment.yml` + `service.yml`
7. `job-service/deployment.yml` + `service.yml`
8. `application-service/deployment.yml` + `service.yml`
9. `notification-service/deployment.yml` + `service.yml`
10. `app/deployment.yml` + `service.yml`
11. `gateway/deployment.yml` + `service.yml` (NodePort)
12. `monitoring/prometheus-deployment.yml` + `service.yml`
13. `monitoring/grafana-deployment.yml` + `service.yml`

### 7.2 Deployment Requirements

- **Strategy:** `RollingUpdate` for services, `Recreate` for postgres
- **Replicas:** 2 for each backend service, 1 for postgres/rabbitmq/gateway
- **Probes:** `readinessProbe` and `livenessProbe` on `/health` for all services
- **Image pull policy:** `Never` (for Minikube local builds)
- **Env injection:** `envFrom` referencing ConfigMap + Secret

### 7.3 Service Requirements

- All backend services: `ClusterIP`
- Gateway: `NodePort` (external entry point, e.g., port 30080)
- Postgres: `ClusterIP`, port 5432
- RabbitMQ: `ClusterIP`, ports 5672 + 15672

---

## 8. Health Check Specification

Every service must implement a `/health` endpoint returning HTTP 200 + `{ "status": "ok" }`.

| Service | Health Check Command | Interval | Timeout | Retries | Start Period |
|---------|---------------------|----------|---------|---------|--------------|
| Gateway | `curl -fsS http://localhost:80/health` | 10s | 5s | 5 | 5s |
| User Service | `curl -fsS http://localhost:3000/health` | 10s | 5s | 5 | 10s |
| Job Service | `curl -fsS http://localhost:3001/health` | 10s | 5s | 5 | 10s |
| Application Service | `curl -fsS http://localhost:3002/health` | 10s | 5s | 5 | 10s |
| Notification Service | `curl -fsS http://localhost:3003/health` | 10s | 5s | 5 | 10s |
| Postgres | `pg_isready -U $POSTGRES_USER -d $POSTGRES_DB` | 5s | 3s | 10 | 5s |
| RabbitMQ | `rabbitmq-diagnostics -q ping` | 10s | 5s | 5 | 10s |
| Prometheus | `wget -qO- http://localhost:9090/-/healthy` | 10s | 5s | 3 | 5s |
| Grafana | `curl -fsS http://localhost:3000/api/health` | 10s | 5s | 5 | 10s |

---

## 9. Flutter Runtime Environment Injection

The Flutter web app cannot bake API URLs at build time (would require 3 separate images). Instead:

1. **`app/docker-entrypoint.sh`** runs on container start. Reads env var `GATEWAY_URL`, writes `{"gatewayUrl": "..."}` to `/usr/share/nginx/html/env.json`.
2. **`app/env.template.json`** provides the JSON structure template.
3. **`app/lib/config/env_loader.dart`** fetches `/env.json` via HTTP before `runApp()`. Parses JSON, injects value into `AppConfig`.
4. **`app/nginx.conf`** serves static files AND the `/env.json` endpoint.

**Result:** Same Docker image runs in dev, test, or prod. Only the injected `GATEWAY_URL` env var changes.

---

## 10. API Contract

### 10.1 Global Conventions

| Convention | Value |
|------------|-------|
| Base Path | `/api/v1` |
| Content-Type | `application/json` |
| Auth Header | `Authorization: Bearer <JWT>` |
| Success Envelope | `{ "success": true, "data": { ... }, "meta": { ... } }` |
| Error Envelope | `{ "success": false, "error": { "code": "ERROR_CODE", "message": "..." } }` |
| Pagination | `?page=1&limit=20` |

### 10.2 JWT Specification

- **Algorithm:** `HS256`
- **Expiry:** `24h`
- **Secret:** Shared `JWT_SECRET` env var (identical across all services)
- **Payload:** `{ "userId": "uuid", "email": "...", "role": "seeker|employer", "iat": timestamp, "exp": timestamp }`
- **Validation:** Every service validates independently. On failure, return `401` with `INVALID_TOKEN`.

### 10.3 User Service Endpoints

| Method | Path | Access | Request | Response | Errors |
|--------|------|--------|---------|----------|--------|
| POST | `/api/v1/users/register` | Public | `{name, email, password, role}` | `201` + user + token | `409 EMAIL_EXISTS` |
| POST | `/api/v1/users/login` | Public | `{email, password}` | `200` + user + token | `401 INVALID_CREDENTIALS` |
| GET | `/api/v1/users/profile` | Auth (any) | — | `200` + user profile | `401 INVALID_TOKEN` |

### 10.4 Job Service Endpoints

| Method | Path | Access | Request | Response | Errors |
|--------|------|--------|---------|----------|--------|
| POST | `/api/v1/jobs` | Auth (employer) | `{title, company, location, description, salary}` | `201` + job | `403 FORBIDDEN` |
| GET | `/api/v1/jobs` | Public | `?search=&location=&page=&limit=` | `200` + jobs[] + meta | — |
| GET | `/api/v1/jobs/:id` | Public | — | `200` + job | `404 JOB_NOT_FOUND` |
| PATCH | `/api/v1/jobs/:id` | Auth (employer, owner) | `{any field}` | `200` + updated job | `403 FORBIDDEN`, `404 NOT_FOUND` |
| DELETE | `/api/v1/jobs/:id` | Auth (employer, owner) | — | `200` + `{deleted: true}` | `403 FORBIDDEN`, `404 NOT_FOUND` |

**Note:** DELETE is a soft delete (set `status = 'closed'`). Jobs table has `status` column with `CHECK (status IN ('active', 'closed'))`.

### 10.5 Application Service Endpoints

| Method | Path | Access | Request | Response | Errors |
|--------|------|--------|---------|----------|--------|
| POST | `/api/v1/applications` | Auth (seeker) | `{jobId, coverLetter}` | `201` + application | `409 ALREADY_APPLIED` |
| GET | `/api/v1/applications` | Auth (any) | `?page=&limit=` | `200` + applications[] + meta | — |
| PATCH | `/api/v1/applications/:id/status` | Auth (employer, owner) | `{status}` | `200` + updated application | `403 FORBIDDEN`, `404 NOT_FOUND` |

**Status values:** `pending`, `reviewed`, `accepted`, `rejected`. Database has `CHECK` constraint.

**Side effects:**
- POST publishes `application.submitted` to RabbitMQ
- PATCH publishes `application.status_changed` to RabbitMQ

### 10.6 Notification Service Endpoints

| Method | Path | Access | Response |
|--------|------|--------|----------|
| GET | `/api/v1/notifications` | Auth (any) | `200` + notifications[] |

**Consumer behavior:** `rabbitmq/consumer.js` binds to `application_events` exchange with `application.*` wildcard. On `application.submitted`, inserts notification for `employerId`. On `application.status_changed`, inserts notification for `seekerId`.

---

## 11. Monitoring Specification

### 11.1 Prometheus

- **Scrape interval:** 15s
- **Targets:** `user-service:3000/metrics`, `job-service:3001/metrics`, `application-service:3002/metrics`, `notification-service:3003/metrics`
- **Target discovery:** Static config (Docker Compose) or Kubernetes service discovery

### 11.2 Application Metrics

Each service exposes `/metrics` using `prom-client`:
- Default Node.js metrics (heap, event loop, GC)
- Custom histogram: `http_request_duration_seconds` with labels `[method, route, status_code]`

### 11.3 Grafana

- **Auto-provisioned datasource:** Prometheus at `http://prometheus-dev:9090`
- **Auto-imported dashboard:** `jobportal-dashboard.json`
- **Admin credentials:** From `.env.dev` (`GF_SECURITY_ADMIN_USER/PASSWORD`)

---

## 12. Branching Convention

| Branch Name | Directory Modified | Purpose |
|-------------|-------------------|---------|
| `feature/services/user-service` | `services/user-service/` | User backend |
| `feature/services/job-service` | `services/job-service/` | Job backend |
| `feature/services/application-service` | `services/application-service/` | Application backend |
| `feature/services/notification-service` | `services/notification-service/` | Notification backend |
| `feature/app` | `app/` | Flutter frontend |
| `feature/gateway` | `gateway/` | Nginx configs |
| `feature/infra` | `infrastructure/` | Docker Compose, scripts, monitoring |
| `feature/k8s` | `k8s/` | Kubernetes manifests |
| `feature/docs` | `docs/`, `README.md` | Documentation |

**Rule:** One branch = one top-level directory. Never mix.

---

## 13. Rubric Compliance Checklist

| Requirement | Proof Point |
|-------------|-------------|
| ≥3 services | 4 backend + 1 gateway + 1 frontend = 6 services |
| Independent, loosely coupled | Each service has own DB, own Dockerfile, talks via HTTP or RabbitMQ |
| ≥3 custom Docker images | 6 custom images (app, user, job, application, notification, gateway) |
| Docker + Docker Compose | 3 compose files, start-all.sh, stop-all.sh |
| Multi-environment | dev/test/prod with isolated networks and port ranges |
| Simultaneous environments | `start-all.sh` spins up all 3 at once |
| Kubernetes | Full manifests in `k8s/`, apply-all.sh, NodePort gateway |
| Monitoring + Logging (Bonus) | Prometheus + Grafana in dev, /metrics on all services |
| Async communication (Bonus) | RabbitMQ publisher + consumer between Application and Notification |
| Documentation | This README + docs/ directory |
| Linux host | Ubuntu 22.04 VM in VirtualBox |
