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

| Endpoint | Method | Description |
|---|---|---|
| `/api/visits` | GET | increments and returns visit counter |
| `/api/health` | GET | checks database connectivity |
| `/api/reset` | GET | resets visit counter |
| `/api/version` | GET | returns backend version |
| `/api/help` | GET | returns all the commands available |
| `/api/metrics` | GET | returns metrics for Endpoint requests, hostname, etc |
| `/api/whoami` | GET | returns the hostname and IP from current backend |

## How to run

```bash
docker compose up -d --build
```

## Test

```bash
curl localhost:8080/api/health
curl localhost:8080/api/visits
curl localhost:8080/api/reset
curl localhost:8080/api/version
curl localhost:8080/api/help
curl localhost:8080/api/whoami
curl localhost:8080/api/metrics
```

## Test with jq

```bash
curl -s localhost:8080/api/health | jq
curl -s localhost:8080/api/visits | jq
curl -s localhost:8080/api/reset | jq
curl -s localhost:8080/api/version | jq
curl -s localhost:8080/api/help | jq
curl -s localhost:8080/api/whoami | jq
curl -s localhost:8080/api/metrics | jq
```

## CI Pipeline

The GitHub Actions pipeline validates:

- Python syntax with Matrix
- Docker Compose configuration
- Docker image build
- Full stack healthcheck
- Added Reusable Workflows
- Added Composite Actions

## Troubleshooting notes
### Backend starts before PostgreSQL is ready

Problem:
The backend failed with connection refused because PostgreSQL was still initializing.

Solution:
Added a PostgreSQL healthcheck and used:

```text
depends_on:
  db:
    condition: service_healthy
```

## caching

### CI optimization
Added actions/cache to cache pip packages.

# Performance notes
Although there’s no significant optimization in seconds for this project, it’s a foundation for the future.

## Releases

v1.0.0
Docker Compose + API + PostgreSQL + GitHub Actions

v2.0.0
Terraform Infrastructure Foundation

### Check specific version

```bash
git fetch --tags
git switch --detach v2.0.0
```

Back to dev environment:

```bash
git switch main
```

## Stack
[![NGinx](https://img.shields.io/badge/nginx-009639?logo=nginx&logoColor=fff)](#)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff)](#)
[![Postgres](https://img.shields.io/badge/Postgres-%23316192.svg?logo=postgresql&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/docker-compose-blue)](#)
[![CI](https://github.com/limonne/devops-api-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/limonne/devops-api-stack/actions/workflows/ci.yml)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=fff)](https://github.com/limonne/devops-api-stack/tree/master/terraform)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=fff)](https://github.com/limonne/devops-api-stack/tree/master/kubernetes)
