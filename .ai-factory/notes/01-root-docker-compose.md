# Root docker-compose for full-stack deployment

**Date:** 2026-06-25
**Source:** conversation context

## Key Findings

- No root-level compose exists today; `mind_api` has its own `docker-compose.prod.yml` (postgres + api) and `mind_web` now has a `Dockerfile` — the root compose unifies them.
- Three containers: `postgres`, `mind_api`, `mind_web`. Two compose files: `docker-compose.dev.yml` and `docker-compose.prod.yml`, each paired with its own env file.
- `VITE_API_BASE_URL` is a build-time `ARG` for `mind_web` — dev: `https://dev-api.mind-awake.life`, prod: `https://api.mind-awake.life`.
- `mind_api` SSH mount for private `observe-js` dep: builder requires `--ssh default` (DOCKER_BUILDKIT=1).

## Details

### Files to create

```
mind/                          ← monorepo root
├── docker-compose.dev.yml
├── docker-compose.prod.yml
├── .env.dev                   ← gitignored, created on server
├── .env.prod                  ← gitignored, created on server
└── .env.example               ← committed, all keys with empty values
```

Root `.gitignore` already ignores `.env.*` (excluding `.env.example`) — no change needed.

---

### docker-compose.prod.yml

```yaml
services:
  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    env_file: .env.prod
    volumes:
      - db_prod_data:/var/lib/postgresql/data
    networks:
      - mind_net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  mind_api:
    build:
      context: ./mind_api
      target: production
      ssh:
        - default
    restart: unless-stopped
    env_file: .env.prod
    ports:
      - "${HOST_API_PORT}:${CONTAINER_API_PORT}"
      - "${HOST_GRPC_PORT}:${CONTAINER_GRPC_PORT}"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - mind_net

  mind_web:
    build:
      context: ./mind_web
      args:
        VITE_API_BASE_URL: ${VITE_API_BASE_URL}
    restart: unless-stopped
    ports:
      - "${HOST_WEB_PORT}:80"
    depends_on:
      - mind_api
    networks:
      - mind_net

volumes:
  db_prod_data:

networks:
  mind_net:
    driver: bridge
```

`docker-compose.dev.yml` is identical with `db_dev_data` volume name and `env_file: .env.dev`.

---

### .env.example (committed)

```env
# Postgres
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

# mind_api
CONTAINER_API_PORT=3000
CONTAINER_GRPC_PORT=50051
HOST_API_PORT=
HOST_GRPC_PORT=
# ... all other mind_api env vars (JWT_SECRET, SMTP, Google OAuth, etc.)

# mind_web
VITE_API_BASE_URL=
HOST_WEB_PORT=
```

Copy all keys from `mind_api/.env.prod` into the root `.env.example` — they're the same vars, root compose replaces the sub-project compose.

---

### .env.prod (gitignored, created on server)

```env
# Postgres
POSTGRES_USER=mind
POSTGRES_PASSWORD=<secret>
POSTGRES_DB=mind_prod

# mind_api
CONTAINER_API_PORT=3000
CONTAINER_GRPC_PORT=50051
HOST_API_PORT=3000
HOST_GRPC_PORT=50051
# ... all mind_api vars

# mind_web
VITE_API_BASE_URL=https://api.mind-awake.life
HOST_WEB_PORT=80
```

### .env.dev (gitignored, created on server)

```env
POSTGRES_DB=mind_dev
VITE_API_BASE_URL=https://dev-api.mind-awake.life
HOST_WEB_PORT=8081
HOST_API_PORT=3001
# ... rest same as prod with dev values
```

---

### How to build

```bash
# prod
DOCKER_BUILDKIT=1 docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# dev
DOCKER_BUILDKIT=1 docker compose -f docker-compose.dev.yml --env-file .env.dev up -d --build
```

`--ssh default` in the compose yaml handles the mind_api private dep automatically when BuildKit is on.

## Open Questions

- Does `mind_api` still need its own `docker-compose.prod.yml` for standalone API deploys, or can it be retired once the root compose is the primary entrypoint?
