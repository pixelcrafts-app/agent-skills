---
name: docker-patterns
description: Docker + Docker Compose patterns for local dev, container security, networking, volumes, multi-service orchestration. Apply when writing/reviewing Dockerfiles or compose files.
---

# Docker Patterns

> Templates below are starting points — adjust images/ports to the stack. The Hard Rules at the bottom are non-negotiable.

## Compose (dev stack)

```yaml
services:
  app:
    build: { context: ., target: dev }   # multi-stage; dev stage
    ports: ["3000:3000"]
    volumes:
      - .:/app                 # source bind-mount (hot reload)
      - /app/node_modules      # anonymous volume protects container deps
    environment: [DATABASE_URL=postgres://postgres:postgres@db:5432/app_dev, NODE_ENV=development]
    depends_on: { db: { condition: service_healthy } }
  db:
    image: postgres:16-alpine   # pin — never :latest
    ports: ["127.0.0.1:5432:5432"]   # localhost-only, don't expose externally
    environment: { POSTGRES_PASSWORD: postgres, POSTGRES_DB: app_dev }
    volumes: [pgdata:/var/lib/postgresql/data]
    healthcheck: { test: ["CMD-SHELL","pg_isready -U postgres"], interval: 5s, retries: 5 }
volumes: { pgdata: }
```

Containers resolve each other by service name (`postgres://db:5432`). Isolate tiers with networks (db on `backend-net` only, unreachable from frontend). `docker-compose.override.yml` auto-loads in dev (debug ports/env); `-f docker-compose.prod.yml` explicit for prod (`target: production`, `restart: always`, resource limits).

## Multi-stage Dockerfile

```dockerfile
FROM node:22-alpine AS deps
WORKDIR /app
COPY package*.json ./ && RUN npm ci

FROM node:22-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . . && RUN npm run build && npm prune --production

FROM node:22.12-alpine3.20 AS production   # pin exact tag
WORKDIR /app
RUN addgroup -g 1001 -S app && adduser -S app -u 1001
USER app                                   # never root
COPY --from=build --chown=app:app /app/dist ./dist
COPY --from=build --chown=app:app /app/node_modules ./node_modules
ENV NODE_ENV=production
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node","dist/server.js"]
```

## Security

```yaml
services:
  app:
    security_opt: [no-new-privileges:true]
    read_only: true
    tmpfs: [/tmp, /app/.cache]
    cap_drop: [ALL]
    cap_add: [NET_BIND_SERVICE]   # only if binding ports <1024
    env_file: [.env]              # gitignored; never ENV secrets in the image
```

`.dockerignore`: `node_modules .git .env .env.* dist coverage *.log .next Dockerfile* docker-compose*.yml tests/`.

## Debug

```bash
docker compose logs -f app          # stream logs
docker compose exec app sh          # shell in
docker compose exec db psql -U postgres
docker compose up --build           # rebuild
docker compose down -v              # DESTRUCTIVE: removes volumes
docker compose exec app nslookup db # network debug
```

## Hard rules

| Wrong | Right |
|-------|-------|
| `:latest` | pin exact version |
| run as root | non-root user |
| data without a volume | named volume for persistence |
| secrets in compose/Dockerfile | `.env` (gitignored) |
| all services in one container | one process per container |
| bare `docker compose` in prod | Kubernetes / ECS / Swarm |
