# Architecture

## Overview

The Job Portal is implemented as a microservices system with independently built Node.js services, a Flutter web frontend, an Nginx API gateway, PostgreSQL, RabbitMQ, and an observability stack.

Each backend service owns one bounded business capability:

| Service | Responsibility | Data store |
| --- | --- | --- |
| `services/user-service` | Registration, login, JWT issuance, user profile | `user_db` |
| `services/job-service` | Job posting, search, update, deletion | `job_db` |
| `services/application-service` | Job applications and application status changes | `application_db` |
| `services/notification-service` | User notifications generated from application events | `notification_db` |

The services share infrastructure, but not application tables. IDs are UUIDs across users, jobs, applications, and notifications so cross-service references remain type-safe.

## Synchronous Communication

Client traffic enters through the Nginx gateway in `gateway/`. The gateway exposes a single HTTP entry point and routes REST requests to the owning service:

| Public route | Upstream service |
| --- | --- |
| `/api/v1/users/` | `user-service` |
| `/api/v1/jobs/` | `job-service` |
| `/api/v1/applications/` | `application-service` |
| `/api/v1/notifications/` | `notification-service` |

Docker Compose uses environment-specific gateway configs:

| Environment | Gateway config |
| --- | --- |
| Development | `gateway/nginx.dev.conf` |
| Testing | `gateway/nginx.test.conf` |
| Production Compose | `gateway/nginx.prod.conf` |
| Kubernetes | `gateway/nginx.k8s.conf` |

The Kubernetes gateway config targets Kubernetes Service DNS names such as `user-service`, `job-service`, `application-service`, `notification-service`, and `app`.

## Asynchronous Communication

Application events use RabbitMQ so notification delivery is decoupled from the request that creates or updates an application.

| Producer | Consumer | Exchange | Type | Routing keys |
| --- | --- | --- | --- | --- |
| `application-service` | `notification-service` | `application_events` | `topic` | `application.submitted`, `application.status_changed` |

The publisher is implemented in `services/application-service/rabbitmq/publisher.js`. The consumer is implemented in `services/notification-service/rabbitmq/consumer.js` and binds `notification_queue` to `application.*`.

This means the application service can return after publishing the event, while the notification service processes the event independently and writes the resulting notification to `notification_db`.

## Data Ownership

The project follows database-per-service ownership:

| Database | Owner | Initialized by |
| --- | --- | --- |
| `user_db` | `user-service` | `infrastructure/databases/init-databases.sql` |
| `job_db` | `job-service` | `infrastructure/databases/init-databases.sql` |
| `application_db` | `application-service` | `infrastructure/databases/init-databases.sql` |
| `notification_db` | `notification-service` | `infrastructure/databases/init-databases.sql` |

Each service runs its own table migration at startup. Other services reference foreign service records only by UUID value; they do not join across databases.

## Monitoring And Logging

The observability stack combines metrics, dashboards, and logs:

| Component | Purpose | Local path |
| --- | --- | --- |
| Prometheus | Scrapes `/metrics` from backend services | `infrastructure/monitoring/prometheus/prometheus.yml` |
| Grafana | Visualizes Prometheus metrics and Loki logs | `infrastructure/monitoring/grafana/provisioning/` |
| Loki | Stores aggregated container and Kubernetes logs | `infrastructure/monitoring/loki/loki-config.yml` |
| Promtail | Ships container or pod logs to Loki | `infrastructure/monitoring/promtail/promtail-config.yml`, `k8s/monitoring/promtail-daemonset.yml` |

In development, `docker-compose.dev.yml` runs Prometheus, Grafana, Loki, and Promtail. In Kubernetes, manifests under `k8s/monitoring/` deploy Prometheus, Loki, Promtail, and Grafana into the `jobportal-prod` namespace.

## Rubric Compliance

| Requirement | Implementation |
| --- | --- |
| Multi-environment Docker Compose | `docker-compose.dev.yml`, `docker-compose.test.yml`, and `docker-compose.prod.yml` use isolated project names, networks, containers, volumes, and host port ranges. |
| Kubernetes orchestration | `k8s/00-namespace.yml` through `k8s/gateway/service.yml` define namespace, config, secrets, databases, RabbitMQ, services, frontend, gateway, and monitoring. |
| Async Bonus: RabbitMQ | `application-service` publishes application lifecycle events to RabbitMQ; `notification-service` consumes `application.*` events and persists notifications. |
| Monitoring Bonus: Loki/Promtail | `docker-compose.dev.yml` and `k8s/monitoring/` include Loki and Promtail for log aggregation, with Grafana configured to query Loki. |
| Metrics and dashboards | Each backend exposes `/metrics`; Prometheus scrapes all services and Grafana provisions dashboards from `infrastructure/monitoring/grafana/provisioning/`. |

