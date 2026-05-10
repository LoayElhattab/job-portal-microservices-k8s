# Development And Testing Setup

## Prerequisites

Install Docker with Docker Compose support. For Kubernetes validation, install Minikube and `kubectl`.

Copy the environment examples before first use:

```bash
cp .env.dev.example .env.dev
cp .env.test.example .env.test
cp .env.prod.example .env.prod
```

## Development Environment

Development uses `docker-compose.dev.yml`. Backend services use `Dockerfile.dev` and run with `nodemon` for hot reload. Source folders are mounted read-only into the service containers.

Start development:

```bash
docker compose -f docker-compose.dev.yml -p jobportal-dev up -d --build
```

Stop development:

```bash
docker compose -f docker-compose.dev.yml -p jobportal-dev down
```

If an older pre-UUID application schema exists in a local volume, recreate the development database volume:

```bash
docker compose -f docker-compose.dev.yml -p jobportal-dev down -v
docker compose -f docker-compose.dev.yml -p jobportal-dev up -d --build
```

### Development Ports

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
| Loki | `http://localhost:3122` |

## Testing Environment

Testing uses `docker-compose.test.yml`. Services are built from production Dockerfiles rather than hot-reload Dockerfiles, and they run on an isolated test network.

Start testing:

```bash
docker compose -f docker-compose.test.yml -p jobportal-test up -d --build
```

Stop testing:

```bash
docker compose -f docker-compose.test.yml -p jobportal-test down
```

### Testing Ports

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

## Simultaneous Environments

Development, test, and production Compose stacks can run at the same time because they use separate networks, container names, volumes, and host ports.

| Environment | Gateway | App | Services | PostgreSQL | RabbitMQ | Monitoring |
| --- | --- | --- | --- | --- | --- | --- |
| Development | `3100` | `3105` | `3101-3104` | `3110` | `3111-3112` | `3120-3122` |
| Testing | `3200` | `3205` | `3201-3204` | `3210` | `3211-3212` | Not enabled |
| Production Compose | `3300` | `3305` | `3301-3304` | `3310` | `3311-3312` | Not enabled |

Start all Compose environments with:

```bash
./infrastructure/scripts/start-all.sh
```

Stop all Compose environments with:

```bash
./infrastructure/scripts/stop-all.sh
```

## Key Environment Variables

| Variable | Purpose |
| --- | --- |
| `JWT_SECRET` | Shared JWT signing and validation secret used by all backend services. |
| `DB_HOST` | PostgreSQL hostname inside the environment network. |
| `DB_PORT` | PostgreSQL port, normally `5432` inside containers. |
| `DB_USER` | PostgreSQL application user. |
| `DB_PASSWORD` | PostgreSQL application password. |
| `USER_SERVICE_DB` | User service database name. |
| `JOB_SERVICE_DB` | Job service database name. |
| `APPLICATION_SERVICE_DB` | Application service database name. |
| `NOTIFICATION_SERVICE_DB` | Notification service database name. |
| `RABBITMQ_URL` | AMQP URL used by application and notification services. |
| `GATEWAY_URL` | Runtime Flutter web API base URL injected into `env.json`. |

