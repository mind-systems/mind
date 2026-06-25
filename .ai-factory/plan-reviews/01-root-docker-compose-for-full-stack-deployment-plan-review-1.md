# Plan Review: Root docker-compose for full-stack deployment

**Plan:** `.ai-factory/plans/01-root-docker-compose-for-full-stack-deployment.md`
**Files Reviewed:** plan + `mind_api/docker-compose.prod.yml`, `mind_api/Dockerfile`, `mind_api/database.config.ts`, `mind_api/src/config/typeorm.config.ts`, `mind_api/.env.prod`/`.env.dev`, `mind_web/Dockerfile`, `mind_web/package.json`, `mind_web/.env.example`, `mind_web/src/core/config.ts`/`observe/config.ts`, root `.gitignore`, root `ROADMAP.md`
**Risk Level:** 🟡 Medium

---

## Context Gates

- **Architecture** (`ARCHITECTURE.md` not present at root) — WARN: no root architecture doc to check boundary alignment. Plan stays within the orchestration layer described in root `CLAUDE.md`, so no boundary violation observed.
- **Rules** (`RULES.md` not present) — WARN: none to enforce.
- **Roadmap** (`ROADMAP.md` present) — Plan is correctly linked to the milestone "Root docker-compose for full-stack deployment". Note: the ROADMAP milestone text itself repeats the same incorrect SSH premise flagged below (see Critical #1).
- **skill-context** (`aif-review/SKILL.md` not present) — no project-specific review overrides.

---

## Critical Issues

### 1. The SSH-forwarding rationale for `mind_api` is false — `mind_api` has no private dependency
The plan (Task 2 and the Build reference) asserts that `ssh: [default]` is required so that **both** `mind_api` and `mind_web` can clone private dependencies:

> `ssh: [default]` … so both `mind_api` and `mind_web` can clone their private dependencies.

This is incorrect for `mind_api`. Verified:
- `mind_api/Dockerfile` uses `RUN npm ci --legacy-peer-deps` — **no** `RUN --mount=type=ssh`, no `# syntax` directive.
- `mind_api/package.json` has **no** `git+ssh` / `github.com` / `ssh://` dependency.

Adding `ssh: [default]` to the `mind_api` build block is functionally harmless (BuildKit ignores an unused SSH forward), but it:
- couples the `mind_api` build to the presence of a host SSH agent for no reason, and
- documents a requirement that does not exist, which will mislead the operator.

**Recommendation:** Drop `ssh: [default]` from the `mind_api` service build block, and correct the Build-reference prose to say only `mind_web` needs SSH agent forwarding.

### 2. `mind_web`'s private dep is `git+https`, not `git+ssh` — verify SSH forwarding actually authenticates it
The plan leans heavily on `ssh: [default]` being mandatory for `mind_web` ("Without it the web image build fails to clone the private dep"). But:
- `mind_web/package.json` → `"observe-js": "git+https://github.com/mind-systems/observe-js.git#v0.1.0"` — an **HTTPS** URL.
- `mind_web/Dockerfile` uses `RUN --mount=type=ssh npm ci` and `ssh-keyscan github.com`, but contains **no** `git config … insteadOf` rewrite from HTTPS→SSH in the active (non-commented) path.

A forwarded SSH agent only authenticates `ssh://` / `git+ssh://` clones. With a `git+https` URL and no `insteadOf` rewrite, npm clones over HTTPS, which uses no agent. So either:
- `mind-systems/observe-js` is a **public** repo → the HTTPS clone needs no credentials and `ssh: [default]` is irrelevant (the build succeeds without it), or
- it is **private** → the current `mind_web` Dockerfile SSH path will not authenticate it, and the plan's "must include `ssh: [default]`" claim does not match how the image actually authenticates.

This is primarily a pre-existing `mind_web` concern, but the plan's correctness claim depends on it. **Recommendation:** Verify a clean `DOCKER_BUILDKIT=1 docker build --ssh default --build-arg VITE_API_BASE_URL=… ./mind_web` actually succeeds before encoding "SSH is required" as fact. Keep `ssh: [default]` on `mind_web` (it matches the Dockerfile's `--mount=type=ssh`), but soften the absolute claim.

### 3. `dev` and `prod` compose files share the default Compose project name → collision if co-located
Both `docker-compose.prod.yml` and `docker-compose.dev.yml` live in the same root directory, and the Build-reference commands do not pass `-p` / set `COMPOSE_PROJECT_NAME`. Compose derives the project name from the working-directory basename (`mind`) for **both** files. Consequences if prod and dev are ever brought up on the **same host**:
- Identical service names (`postgres`, `mind_api`, `mind_web`) and identical network name (`mind_net`) resolve to the **same** project → the second `up` reconciles/replaces the first project's containers instead of running alongside it.
- Only the named volumes differ (`db_prod_data` vs `db_dev_data`), which is not enough to keep the two deployments isolated.

The plan's Context says it supports "both prod and dev deployments," but never states whether they share a host. If they do, this is a blocker; if they are on separate hosts, it is fine.

**Recommendation:** Make the isolation explicit — either add `-p mind_prod` / `-p mind_dev` to the Build-reference commands, set `COMPOSE_PROJECT_NAME` per env file, or state in the plan that prod and dev run on separate hosts. Also confirm `HOST_*` ports differ between `.env.prod` and `.env.dev` if co-located (the plan acknowledges host ports come from env, but does not call out the collision risk).

---

## Non-Blocking Issues (WARN)

### 4. `mind_web` build-time observability vars are dropped
`mind_web` reads three build-time (Vite-inlined) vars: `VITE_API_BASE_URL`, `VITE_LOG_DESTINATION`, and `VITE_OTLP_ENDPOINT` (confirmed in `src/core/config.ts` and `src/core/observe/config.ts`; `mind_web/.env.example` ships `VITE_LOG_DESTINATION=file`, `VITE_OTLP_ENDPOINT=/otlp/v1/logs`). The plan's root `.env.example` and the compose `build.args` pass **only** `VITE_API_BASE_URL`, and the web `Dockerfile` only declares `ARG VITE_API_BASE_URL`. Result: the deployed web bundle falls back to compiled-in defaults for log destination/endpoint, so OTLP log shipping from the web app cannot be configured per-deployment.

This may be intentional (defaults are acceptable), but it is an undocumented behavior change vs. the web project's own `.env.example`. **Recommendation:** Either explicitly note "web observability uses build defaults; OTLP shipping not configured via root compose," or add `VITE_LOG_DESTINATION` / `VITE_OTLP_ENDPOINT` to the Dockerfile `ARG`s, the compose `build.args`, and the root `.env.example`.

### 5. `CONTAINER_DB_PORT` must equal Postgres's in-container listen port (5432)
`mind_api` connects to the DB using `host = POSTGRES_HOST`, `port = CONTAINER_DB_PORT` (verified in `database.config.ts:8-9` and `typeorm.config.ts:8-9`). The stock `postgres:15-alpine` image always listens on `5432` inside the container regardless of `CONTAINER_DB_PORT`. So if an operator sets `CONTAINER_DB_PORT` to anything other than `5432`, the API will fail to reach the DB (and the `pg_isready` healthcheck still passes on the default socket, masking the cause). The plan's inline comment correctly nails `POSTGRES_HOST=postgres` but says nothing about `CONTAINER_DB_PORT`. **Recommendation:** Add an inline comment in `.env.example` that `CONTAINER_DB_PORT` must be `5432` (the Postgres container's internal port), with `HOST_DB_PORT` being the only freely-chosen host-side mapping.

### 6. Minor: API service healthcheck/logging not specified
Task 2 says "Follow `mind_api/docker-compose.prod.yml` as the reference for healthcheck/logging style" but only spells out the `postgres` healthcheck. The reference compose also defines an API healthcheck and `json-file` log rotation on every service. With `mind_web depends_on: [mind_api]` (no `condition`), web only waits for the API container to *start*, not to be *healthy*. Consider adding the API `service_healthy` condition (the reference API healthcheck exists) if ordering matters. Non-blocking given web is a static nginx image that tolerates a not-yet-ready API.

---

## Positive Notes

- **Env key list is accurate and complete.** The `mind_api` key set in Task 1 matches `mind_api/.env.prod` exactly (diffed key-by-key), and the Postgres/`CONTAINER_DB_PORT`/`HOST_DB_PORT` de-duplication note is correct — no missing or stray keys.
- **`POSTGRES_HOST=postgres` is correct.** Verified against `database.config.ts` / `typeorm.config.ts` — the API resolves the DB host from `POSTGRES_HOST`, so pointing it at the compose service name works over `mind_net`.
- **`.gitignore` verification is correct.** Root `.gitignore` lines 25-27 ignore `.env` / `.env.*` with a `!.env.example` exception; no edit needed, exactly as the plan states. Build-context dirs being git-ignored does not affect Docker (build context is filesystem-based).
- **Correctly omits the obsolete `version:` key** and correctly keeps both `env_file:` (runtime env) and `--env-file` (interpolation for ports/healthcheck/build-args) — the distinction is real and well explained.
- **No migration step missing.** `migrationsRun: true` in `database.config.ts` means migrations apply automatically on API startup; no separate migration task is required in the plan.
- **Healthcheck style** (`pg_isready -U ${POSTGRES_USER}`, 10s/5s/5) matches the existing reference compose.

---

## Verdict

The plan is well-researched on the env contract and DB wiring, but rests on an **incorrect SSH premise for `mind_api`** (Critical #1, also propagated into the ROADMAP milestone), an **unverified SSH claim for `mind_web`** given its `git+https` dep (Critical #2), and a **prod/dev Compose project-name collision risk** that is unaddressed (Critical #3). These should be resolved or explicitly scoped before implementation. Withholding pass.
