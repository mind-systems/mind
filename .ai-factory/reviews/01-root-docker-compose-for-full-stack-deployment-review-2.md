# Code Review (Pass 2): Root docker-compose for full-stack deployment

**Plan:** `.ai-factory/plans/01-root-docker-compose-for-full-stack-deployment.md`
**Changed files reviewed (in full):** `.env.example`, `docker-compose.prod.yml`, `docker-compose.dev.yml`, `.gitignore`
**Cross-referenced this pass:** `mind_api/src/main.ts` (bootstrap: gRPC bind, CORS, HTTP listen), `mind_api/src/health.controller.ts`, `mind_api/database.config.ts`, `mind_web/nginx.conf`, `mind_web/Dockerfile`, both reference compose files
**State:** Code unchanged since review-1 (the review-1 finding #1 `name:` recommendation was not applied; no `name:` key present in either compose file).
**Risk Level:** 🟢 Low — compose/env artifacts are correct and faithful to the plan. Findings are a single-host isolation hardening (carried from review-1) plus three `.env.example` operator-config footguns rooted in the API's env-fallback semantics.

---

## Confirmed correct this pass

- **gRPC default bind is container-safe.** `main.ts:87` defaults `GRPC_URL` to `0.0.0.0:50051` — binds all interfaces, so the published `${HOST_GRPC_PORT}:${CONTAINER_GRPC_PORT}` mapping is reachable (a `localhost`-only bind would not be). ✅ (caveat in finding #2 below).
- **HTTP `/health` is real and 200.** `health.controller.ts` returns `{status:'ok'}`; `main.ts:146-149` listens on `CONTAINER_API_PORT`. The API healthcheck and `mind_web`'s `depends_on: condition: service_healthy` gate therefore resolve — no startup deadlock. ✅
- **nginx is pure SPA serving.** `mind_web/nginx.conf` has only `try_files … /index.html` and **no** `proxy_pass`. This independently validates two plan decisions: (a) `VITE_API_BASE_URL` must be a full external origin (it is — `https://api.mind-awake.life`), since the web container does not proxy to `mind_api`; and (b) web OTLP shipping to a relative `/otlp/v1/logs` would not be proxied anyway, so leaving `VITE_OTLP_ENDPOINT` out of scope is correct, not a regression. ✅
- **Compose interpolation, SSH placement, DB wiring, `.gitignore`, no-secrets-in-`.env.example`** — all as verified in review-1; unchanged and correct. ✅

---

## Findings

### 1. (Low / Hardening — carried from review-1, still unaddressed) Project-name isolation depends on the operator passing `-p`
Both compose files set no top-level `name:`, so when run without `-p` they both default to project `mind` (directory basename), sharing service identities and the `mind_net` network — a dev `up` can then reconcile/replace a running prod stack on the same host. The Build reference passes `-p mind_prod`/`-p mind_dev`, but that safeguard lives only in docs.

**Recommendation (unchanged):** add `name: mind_prod` / `name: mind_dev` as a top-level key in the respective compose files so isolation holds regardless of the CLI flag. Low severity, but production-data blast radius on a shared host.

### 2. (Low) Empty `GRPC_URL` in `.env.example` breaks the gRPC bind — `??` does not catch empty string
`main.ts:87`: `const grpcUrl = process.env.GRPC_URL ?? '0.0.0.0:50051';`. Nullish-coalescing (`??`) falls back **only** on `undefined`/`null`. `.env.example` ships `GRPC_URL=` (empty), and `env_file:` injects it as an **empty string**, so `'' ?? '0.0.0.0:50051'` → `''` — NestJS would attempt to bind gRPC to an empty URL rather than the intended default. Two coupled pitfalls for an operator filling `.env.prod`/`.env.dev` from the template:
- Leaving `GRPC_URL=` empty does **not** mean "use the default" (unlike deleting the line); it yields a broken bind.
- The port inside `GRPC_URL` must equal `CONTAINER_GRPC_PORT` (and match the default `50051`), or the published `${HOST_GRPC_PORT}:${CONTAINER_GRPC_PORT}` mapping points at a port nothing is listening on; and `GRPC_URL` must use host `0.0.0.0` (not `localhost`) to be reachable through the port mapping.

This mirrors the `CONTAINER_DB_PORT=5432` guidance the plan already added. **Recommendation:** add an inline comment in `.env.example` for `GRPC_URL` — e.g. "must be `0.0.0.0:${CONTAINER_GRPC_PORT}` (host `0.0.0.0` so the published port is reachable); an empty value does NOT fall back to the default." Not a compose-file bug; an `.env.example` documentation gap.

### 3. (Info) Empty `FRONTEND_URL` silently CORS-blocks the web dashboard
`main.ts:141`: `origin: process.env.FRONTEND_URL || 'http://localhost:8000'`. With `FRONTEND_URL=` empty, `'' || …` falls back to `http://localhost:8000`, so the deployed web origin (e.g. `https://mind-awake.life`) is rejected by CORS — the exact cross-service path this milestone exists to enable. The operator must set `FRONTEND_URL` to the web origin in `.env.prod`/`.env.dev`. Worth a one-line comment in `.env.example` ("web dashboard origin; required for CORS, empty falls back to localhost"). Operator-config concern, not a code defect.

### 4. (Info, no action) `CONTAINER_GRPC_PORT` / `HOST_GRPC_PORT` parallel the DB-port caveat
Same class as the documented `CONTAINER_DB_PORT=5432` note: `CONTAINER_GRPC_PORT` is meaningful only as the in-container listen port and must agree with the port inside `GRPC_URL`. Covered implicitly by finding #2's recommendation; noted for completeness.

---

## Verdict

The three artifacts are correct, internally consistent, and faithful to the revised plan; no migration, type, race, or healthcheck defect. The actionable items are: finding #1 (top-level `name:` for single-host prod/dev isolation — recommend before co-locating deployments) and findings #2–#3 (low-cost `.env.example` inline comments that prevent silent gRPC-bind and CORS misconfiguration when an operator fills the template). All are hardening/documentation, none block the compose files from functioning when the env files are filled correctly.

Because actionable findings exist, this review does not emit a pass marker.
