# Plan: Root docker-compose for full-stack deployment

## Context
Add unified root-level orchestration that brings up `postgres`, `mind_api`, and `mind_web` together for both prod and dev deployments, each driven by its own gitignored env file, with a committed `.env.example` documenting every key.

Deployment topology assumption: **prod and dev run as isolated Compose projects** (separate project names), so they may share a host. The Build reference encodes this with explicit `-p` project names; if prod and dev are ever co-located, their `HOST_*` ports must also differ (driven by env files).

## Settings
- Testing: no
- Logging: minimal
- Docs: no

## SSH / private-dependency facts (verified — read before Task 2)
Both sub-projects depend on the same private repo `mind-systems/observe-js`, but their Dockerfiles consume it differently:
- `mind_api/Dockerfile`: `RUN npm ci --legacy-peer-deps` — **no** `RUN --mount=type=ssh`, no `# syntax` directive. It consumes **no** SSH mount. Therefore `ssh: [default]` in the compose `mind_api` build block would be inert and misleading — **do not add it**. (`mind_api/package.json` → `"observe-js": "github:mind-systems/observe-js#main"`.)
- `mind_web/Dockerfile`: `RUN --mount=type=ssh npm ci` with `ssh-keyscan github.com`. Keep `ssh: [default]` on the `mind_web` build block to match. Caveat: `mind_web/package.json` pins `"observe-js": "git+https://github.com/mind-systems/observe-js.git#v0.1.0"` (an **HTTPS** URL) and the Dockerfile has no `insteadOf` HTTPS→SSH rewrite in its active path. A forwarded SSH agent only authenticates `ssh://` clones, so SSH forwarding only matters if that repo is private *and* npm is rewriting to SSH. Treat "SSH is required for `mind_web`" as **probable, not proven** — see the verification step in Task 2.

## Tasks

### Phase 1: Environment contract

- [x] **Task 1: Create root `.env.example`**
  Files: `.env.example`
  Commit `.env.example` at the repo root with every key the two compose files reference, all values empty. Include these groups:
  - **Postgres:** `POSTGRES_USER=`, `POSTGRES_PASSWORD=`, `POSTGRES_DB=`, `POSTGRES_HOST=`, `CONTAINER_DB_PORT=`, `HOST_DB_PORT=`.
    Inline comments:
    - `POSTGRES_HOST` MUST be the compose service name `postgres` (not `localhost`/`mind_database_*`) — `mind_api` reaches the DB over the shared `mind_net` bridge network by service name.
    - `CONTAINER_DB_PORT` MUST be `5432` — the stock `postgres:15-alpine` image always listens on `5432` inside the container, and `mind_api` connects using `port = CONTAINER_DB_PORT` (`database.config.ts:9`). Any other value makes the API fail to reach the DB while `pg_isready` still passes on the default socket, masking the cause. `HOST_DB_PORT` is the only freely-chosen host-side mapping.
  - **mind_api:** copy the full key set from `mind_api/.env.prod` (keys only, no values) — `APP_BASE_URL`, `CONTAINER_API_PORT`, `CONTAINER_GRPC_PORT`, `FRONTEND_URL`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_IOS_CLIENT_ID`, `GRPC_KEEPALIVE_PERMIT_WITHOUT_CALLS`, `GRPC_KEEPALIVE_TIMEOUT_MS`, `GRPC_KEEPALIVE_TIME_MS`, `GRPC_URL`, `HOST_API_PORT`, `HOST_GRPC_PORT`, `JWT_EXPIRES_IN`, `JWT_SECRET`, `LOG_LEVEL`, `MAIL_FROM`, `NODE_ENV`, `RESEND_API_KEY`, `TZ`, `WEB_REDIRECT_URI`, `WS_BACKPRESSURE_SAMPLES_PER_SEC`, `WS_MIN_SESSION_DURATION_S`, `WS_RECONNECT_GRACE_MS`, `WS_STREAM_MAX_BUFFER_BYTES`, `WS_STREAM_MAX_SESSIONS`, `WS_TELEMETRY_MAX_PAYLOAD_BYTES`. (`POSTGRES_*` and `CONTAINER_DB_PORT`/`HOST_DB_PORT` already covered in the Postgres group — do not duplicate.)
    Inline comments required on two keys:
    - `GRPC_URL`: MUST be `0.0.0.0:${CONTAINER_GRPC_PORT}` — host `0.0.0.0` so the published port is reachable from outside the container. `main.ts` reads `process.env.GRPC_URL ?? '0.0.0.0:50051'`; nullish-coalescing does **not** catch empty string, so leaving `GRPC_URL=` empty injects `''` via `env_file:` and breaks the gRPC bind. The port inside `GRPC_URL` must equal `CONTAINER_GRPC_PORT`.
    - `FRONTEND_URL`: web dashboard origin; required for CORS. `main.ts` reads `process.env.FRONTEND_URL || 'http://localhost:8000'`; an empty value falls back to `localhost:8000`, silently blocking the deployed web dashboard. Set to the mind_web public origin (e.g. `https://mind-awake.life`).
  - **mind_web:** `VITE_API_BASE_URL=` (comment: prod `https://api.mind-awake.life`, dev `https://dev-api.mind-awake.life`), `HOST_WEB_PORT=`.
    Add a comment documenting the scope limit: root compose configures **only** `VITE_API_BASE_URL` for the web build. The web app also reads two other build-time (Vite-inlined) vars — `VITE_LOG_DESTINATION` and `VITE_OTLP_ENDPOINT` (`mind_web/.env.example` ships `file` / `/otlp/v1/logs`) — but the current `mind_web/Dockerfile` only declares `ARG VITE_API_BASE_URL`, so those two fall back to compiled-in defaults. Per-deployment OTLP log shipping for the web app is therefore **out of scope** here; enabling it would require adding `ARG VITE_LOG_DESTINATION` / `ARG VITE_OTLP_ENDPOINT` to `mind_web/Dockerfile` (separate repo) first. Do not add these two keys to `.env.example` as if they were wired — leave them out and let the comment explain why.
  Note: root `.gitignore` already ignores `.env.*` with a `!.env.example` exception — no `.gitignore` change is required. Verify this holds; do not edit `.gitignore` unless the exception is missing.

### Phase 2: Compose files

- [x] **Task 2: Create `docker-compose.prod.yml`** (depends on Task 1)
  Files: `docker-compose.prod.yml`
  Root-level compose with three services on one bridge network. Follow `mind_api/docker-compose.prod.yml` for healthcheck/logging style.
  Add `name: mind_prod` as the **top-level key** (before `services:`). This pins the Compose project name in the file itself so isolation holds regardless of whether `-p` is passed on the CLI. Do **not** add `container_name:` to any service — `container_name` is host-global and ignores the project name, so copying it from the reference compose would collide with a co-located dev stack.
  - `postgres`: `image: postgres:15-alpine`, `restart: unless-stopped`, `env_file: .env.prod`, named volume `db_prod_data:/var/lib/postgresql/data`, attached to `mind_net`, healthcheck `["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]` (interval 10s / timeout 5s / retries 5), `json-file` logging (`max-size: 10m`, `max-file: "3"`).
  - `mind_api`: `build: { context: ./mind_api, target: production }` — **no `ssh:` key** (its Dockerfile consumes no SSH mount; see the SSH facts section). `restart: unless-stopped`, `env_file: .env.prod`, ports `${HOST_API_PORT}:${CONTAINER_API_PORT}` and `${HOST_GRPC_PORT}:${CONTAINER_GRPC_PORT}`, `depends_on: { postgres: { condition: service_healthy } }`, attached to `mind_net`. Add the API healthcheck and `json-file` logging from the reference compose: healthcheck `["CMD", "sh", "-c", "wget --no-verbose --tries=1 --spider http://localhost:${CONTAINER_API_PORT}/health || exit 1"]` (interval 10s / timeout 5s / retries 3 / start_period 40s).
  - `mind_web`: `build: { context: ./mind_web, args: { VITE_API_BASE_URL: ${VITE_API_BASE_URL} }, ssh: [default] }`, `restart: unless-stopped`, ports `${HOST_WEB_PORT}:80`, attached to `mind_net`. Use `depends_on: { mind_api: { condition: service_healthy } }` so the web container starts only once the API reports healthy (the API healthcheck above makes this condition meaningful; harmless even though nginx tolerates a not-yet-ready API).
    Keep `ssh: [default]` to match `mind_web/Dockerfile`'s `--mount=type=ssh`, but do **not** assert in comments that the build always fails without it (the dep is a `git+https` URL — it may be public). Instead, before finalizing, run the verification below.
  - Bottom-level keys: `volumes: { db_prod_data: }` and `networks: { mind_net: { driver: bridge } }`.
  Do not add a top-level `version:` key (obsolete in Compose v2). Keep `env_file:` on services even though the build command also passes `--env-file` — `env_file:` provides container runtime env, while `--env-file` supplies the `${VAR}` interpolation used for ports, healthcheck, and build args.
  **Verification (mind_web SSH claim):** run a clean build of just the web image to confirm whether SSH forwarding is actually needed:
  `DOCKER_BUILDKIT=1 docker build --ssh default --build-arg VITE_API_BASE_URL=https://api.mind-awake.life ./mind_web`
  If it also succeeds **without** `--ssh default`, the dep is public and `ssh: [default]` is belt-and-suspenders (keep it, matches the Dockerfile). If it fails without it, the requirement is confirmed.

- [x] **Task 3: Create `docker-compose.dev.yml`** (depends on Task 2)
  Files: `docker-compose.dev.yml`
  Identical structure to `docker-compose.prod.yml` with only these differences:
  - Top-level `name: mind_dev` (instead of `mind_prod`).
  - `env_file: .env.dev` on every service.
  - Postgres volume named `db_dev_data` (both the mount and the bottom-level `volumes:` entry).
  Do **not** add `container_name:` — same reason as Task 2. Keep `mind_api` `target: production` (no `ssh:`) and the `mind_web` build args/`ssh: [default]` exactly as in prod — the "dev" here is the dev *deployment* (`dev-api.mind-awake.life`), not local hot-reload; environment differences (DB name, `VITE_API_BASE_URL`, host ports) come from `.env.dev`, not from the compose file.

## Build reference (for the operator, not a task)
Prod and dev are isolated as **separate Compose projects**. Each file declares its project name via the top-level `name:` key (`mind_prod` / `mind_dev`), so isolation holds even without `-p`. The named volumes alone (`db_prod_data` vs `db_dev_data`) are not sufficient — without `name:` both files would derive the same default project name (`mind`) from the working-directory basename and share the same containers and `mind_net` network.
```bash
# prod
DOCKER_BUILDKIT=1 docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
# dev
DOCKER_BUILDKIT=1 docker compose -f docker-compose.dev.yml  --env-file .env.dev  up -d --build
```
If prod and dev share a host, their `HOST_API_PORT` / `HOST_GRPC_PORT` / `HOST_WEB_PORT` / `HOST_DB_PORT` must differ between `.env.prod` and `.env.dev` to avoid host-port collisions. `ssh: [default]` on the `mind_web` build forwards the host SSH agent (BuildKit) for its `--mount=type=ssh` install step; `mind_api` needs no SSH forwarding. The gitignored `.env.prod` / `.env.dev` are created on the server from `.env.example`.
