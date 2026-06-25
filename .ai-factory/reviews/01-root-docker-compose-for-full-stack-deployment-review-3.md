# Code Review (Pass 3, re-review): Root docker-compose for full-stack deployment

**Plan:** `.ai-factory/plans/01-root-docker-compose-for-full-stack-deployment.md`
**Changed files reviewed (in full):** `.env.example`, `docker-compose.prod.yml`, `docker-compose.dev.yml`, `.gitignore`
**Cross-referenced:** `mind_api/src/main.ts` (gRPC bind, CORS, HTTP listen), `mind_api/src/health.controller.ts`, `mind_api/database.config.ts`, `mind_api/Dockerfile`, `mind_web/Dockerfile`, `mind_web/nginx.conf`, `mind_web/.dockerignore`
**Risk Level:** 🟢 None — the delivered artifacts are correct and all prior-review findings have been incorporated.

---

## Resolution of prior findings (all addressed)

The implementation was updated since the earlier passes; verified against the current files:

1. **Prod/dev project isolation — fixed.** `docker-compose.prod.yml:1` now declares `name: mind_prod` and `docker-compose.dev.yml:1` declares `name: mind_dev`. Each file pins its own Compose project name, so a `-p`-less `up` no longer collapses both stacks onto a shared `mind` project/network. `name:` is a valid top-level Compose Specification key; an explicit `-p` (still shown in the Build reference) overrides with the same value — harmless. No `container_name:` was added to any service, which is correct (a host-global `container_name` would defeat the project-name isolation).
2. **`GRPC_URL` empty-string footgun — documented.** `.env.example:56-61` now warns that the API uses `GRPC_URL ?? '0.0.0.0:50051'`, that nullish-coalescing does not catch an empty string, that it must be `0.0.0.0:${CONTAINER_GRPC_PORT}` (host `0.0.0.0` for reachability through the port mapping), and that the embedded port must equal `CONTAINER_GRPC_PORT`. Matches `main.ts:87`.
3. **`FRONTEND_URL` CORS fallback — documented.** `.env.example:44-47` now warns that an empty value falls back to `http://localhost:8000` and silently blocks the deployed dashboard. Matches `main.ts:141`.

---

## Correctness re-confirmed on the changed files

- **Compose validity & structure:** both files — `name:` → `services:` → `volumes:` → `networks:`. Three services on the `mind_net` bridge; prod/dev differ only by `name`, `env_file`, and volume name (`db_prod_data` vs `db_dev_data`), exactly as the plan specifies.
- **Healthcheck gating is satisfiable:** API healthcheck hits HTTP `/health` (`health.controller.ts` → 200, served on `CONTAINER_API_PORT` per `main.ts:146-149`); `mind_web`'s `depends_on: { mind_api: { condition: service_healthy } }` therefore resolves — no startup deadlock. `wget` exists in `node:20-alpine` (busybox).
- **Interpolation vs runtime env:** `${VAR}` (ports, `pg_isready -U ${POSTGRES_USER}`, API healthcheck port, `VITE_API_BASE_URL` arg) resolves from `--env-file`; `env_file:` supplies container runtime env. Both retained, used correctly.
- **SSH placement:** `mind_api` build has no `ssh:` (its Dockerfile consumes no SSH mount); `mind_web` keeps `ssh: [default]` to match its `--mount=type=ssh`. Correct.
- **DB wiring:** `POSTGRES_HOST=postgres` + `CONTAINER_DB_PORT=5432` documented inline; matches `database.config.ts:8-9`.
- **Security:** `.env.example` ships only empty values — no secret leakage; `.gitignore` still ignores `.env.*` with the `!.env.example` exception (unchanged).
- **nginx** is pure SPA serving (no `proxy_pass`), independently validating that `VITE_API_BASE_URL` must be a full external origin and that web OTLP is correctly out of scope.

---

## Out-of-scope note (not a finding against this change)

`mind_api/` has no `.dockerignore`, so its `COPY . .` builder stage ingests the repo's own `.env*` secrets into the *builder* layer. Verified this is **not** a shipped-secret leak (multi-stage production copies only `dist`/`node_modules`/`package*.json`/`proto`; NestJS reads env at runtime) and is **unaffected** by this change (the root-level `.env.prod`/`.env.dev` live outside the `./mind_api` build context). It is a pre-existing hygiene item in a separate repo, optional, and outside this milestone's diff. `mind_web/.dockerignore` already handles this correctly for the web build.

---

## Verdict

All actionable findings from the earlier passes are resolved, and the four changed files are correct, internally consistent, and deployable when the env files are filled per the (now well-commented) template. No bug, security defect, or correctness problem remains in the code under review.

REVIEW_PASS
