# DevOps API Stack

A small DevOps lab project using Docker Compose to run a multi-service application with Nginx, a Python backend API and PostgreSQL.

## Architecture

```text
Client
  ↓
Nginx reverse proxy :8080
  ↓
Python backend :8080
  ↓
PostgreSQL :5432
```

## Services
- nginx: reverse proxy exposed on host port 8080
- backend: Python API
- db: PostgreSQL database with persistent volume

## Endpoints
```text
/api/visits	increments and returns visit counter
/api/health	checks database connectivity
/api/reset	resets visit counter
/api/version check version for backend
```

## How to run
docker compose up -d --build

```text
## Test
curl localhost:8080/api/health
curl localhost:8080/api/visits
curl localhost:8080/api/reset
curl localhost:8080/api/version
```

## Troubleshooting notes
Backend starts before PostgreSQL is ready

Problem:
The backend failed with connection refused because PostgreSQL was still initializing.

Solution:
Added a PostgreSQL healthcheck and used:

```text
depends_on:
  db:
    condition: service_healthy
```
