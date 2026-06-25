# Code Review: Root docker-compose for full-stack deployment

**Plan:** `.ai-factory/plans/01-root-docker-compose-for-full-stack-deployment.md`
**Changed files reviewed (in full):** `.env.example`, `docker-compose.prod.yml`, `docker-compose.dev.yml`, `.gitignore`
**Cross-referenced:** `mind_api/Dockerfile`, `mind_api/docker-compose.prod.yml`, `mind_api/database.config.ts`, `mind_api/src/main.ts`, `mind_api/src/health.controller.ts`, `mind_api/package.json`, `mind_web/Dockerfile`, `mind_web/package.json`
**Risk Level:** 🟢 Low — implementation faithfully matches the (already plan-reviewed) plan; no runtime-breaking bug found. One hardening finding tied to a previously-flagged Critical risk.

---

## Runtime correctness checks (all pass)

- **API healthcheck is satisfiable.** `mind_web` gates on `mind_api` with `condition: service_healthy`, and `mind_api`'s healthcheck hits `http://localhost:${CONTAINER_API_PORT}/health`. Verified the endpoint exists: `health.controller.ts` (`@Controller('health')` → returns `{status:'ok'}`, HTTP 200) and `main.ts:146-149` binds HTTP on `CONTAINER_API_PORT`. So the gate resolves; no startup deadlock. `wget` is available in the `node:20-alpine` production image (busybox). ✅
- **`${VAR}` interpolation sources are correct.** Host ports, `${POSTGRES_USER}` (pg_isready), `${CONTAINER_API_PORT}` (API healthcheck) and `${VITE_API_BASE_URL}` (build arg) are all supplied by `--env-file` at parse time, while `env_file:` feeds container runtime env. The dual mechanism is used correctly, matching the plan. ✅
- **DB wiring.** `POSTGRES_HOST=postgres` + `CONTAINER_DB_PORT=5432` documented inline; `database.config.ts:8-9` reads exactly those, so the API resolves the DB by service name over `mind_net`. ✅
- **SSH premise applied correctly.** `mind_api` build has **no** `ssh:` key (its Dockerfile uses plain `npm ci`, consumes no SSH mount); `mind_web` build keeps `ssh: [default]` to match its `--mount=type=ssh`. Matches the corrected plan. ✅
- **`.gitignore`** still ignores `.env.*` with the `!.env.example` exception — unchanged, correct. `.env.example` ships only empty values — no secret leakage. ✅
- **No `version:` key, no `container_name:`** — correct. Omitting `container_name` is in fact required for the prod/dev project-name isolation strategy to work (a global `container_name` would collide across projects). ✅

---

## Findings

### 1. (Low / Hardening) Project-name isolation relies entirely on the operator remembering `-p`
Plan-review Critical #3 (prod/dev Compose project collision) was resolved only at the *documentation* layer — the Build reference passes `-p mind_prod` / `-p mind_dev`. The compose files themselves set no project name, so the safeguard evaporates the moment someone runs the documented-elsewhere form, e.g.:

```bash
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d   # no -p
```

Both files then derive the **same** default project name from the directory basename (`mind`), sharing the `postgres`/`mind_api`/`mind_web` service identities and the `mind_net` network — so a dev `up` reconciles/replaces a running prod stack (only the named volumes `db_prod_data` vs `db_dev_data` differ, which is not enough to keep the deployments apart). On a single host this is a foot-gun with production-data blast radius.

**Recommendation:** Pin the project name *in each file* with the top-level Compose `name:` key, so isolation no longer depends on the CLI flag:

```yaml
# docker-compose.prod.yml
name: mind_prod
services:
  ...
```
```yaml
# docker-compose.dev.yml
name: mind_dev
services:
  ...
```

With `name:` set, `docker compose -f docker-compose.dev.yml up` lands in project `mind_dev` regardless of `-p`, and `-p` (if still passed) overrides it. This closes the collision risk at the file level rather than trusting operator discipline. (Host-port collisions if co-located remain an env-file concern, already documented.)

### 2. (Info) Empty `POSTGRES_HOST` fails open to `localhost`, not loudly
`database.config.ts:8` defaults `POSTGRES_HOST` to `'localhost'` when unset. An operator who copies `.env.example` and forgets to fill `POSTGRES_HOST` gets a container that tries `localhost:5432`, fails to reach the `postgres` service, and crash-loops with a connection error rather than an obvious "missing config" message. The inline comment ("MUST be the compose service name `postgres`") mitigates this; no code change required, but worth being aware of when writing `.env.prod`/`.env.dev` on the server. Not introduced by this change — pre-existing API default.

### 3. (Info, no action) `mind_web` → `mind_api` `depends_on` is startup ordering only
Browser traffic targets the external `VITE_API_BASE_URL` (`https://api.mind-awake.life`), not the in-network `mind_api` service, so `condition: service_healthy` only orders container startup; it does not affect request routing. Correct and harmless — noting so it isn't mistaken for in-cluster proxying.

---

## Verdict

The three compose/env artifacts are correct, internally consistent, and faithful to the revised plan — no migration, type, port, or healthcheck defect that would break at runtime. Finding #1 is a real single-host data-safety hardening that also fully neutralizes the previously-flagged Critical #3; recommend applying the top-level `name:` keys before deploying prod and dev on a shared host. Findings #2–#3 are informational.

Because actionable findings exist, this review does not emit a pass marker.
