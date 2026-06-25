# Plan Review (round 2): Root docker-compose for full-stack deployment

**Plan:** `.ai-factory/plans/01-root-docker-compose-for-full-stack-deployment.md`
**Files Reviewed:** plan + `mind_api/docker-compose.prod.yml`, `mind_api/Dockerfile`, `mind_api/database.config.ts`, `mind_api/.env.prod` / `.env.dev` (keys), `mind_api/package.json`, `mind_web/Dockerfile`, `mind_web/package.json`, root `.gitignore`, prior review `…-plan-review-1.md`
**Risk Level:** 🟢 Low

---

## Context Gates

- **Architecture** (`ARCHITECTURE.md` not present at root) — WARN: no root architecture doc to check boundary alignment. Plan stays within the orchestration layer described in root `CLAUDE.md`; no boundary violation.
- **Rules** (`RULES.md` not present) — WARN: none to enforce.
- **Roadmap** (`ROADMAP.md` present) — Plan is linked to the milestone "Root docker-compose for full-stack deployment". The false SSH premise that previously leaked into the milestone text has been corrected in the plan body.
- **skill-context** (`aif-review/SKILL.md` not present) — no project-specific review overrides.

---

## Resolution of round-1 critical issues

All three blockers from review-1 are resolved, and the two WARNs are folded in:

1. **SSH for `mind_api` (was Critical #1)** — Resolved. The plan now explicitly states `mind_api/Dockerfile` consumes no SSH mount and instructs **not** to add `ssh:` to the `mind_api` build block. Verified against the codebase: `mind_api/Dockerfile` uses `RUN npm ci --legacy-peer-deps` with no `--mount=type=ssh` and no `# syntax` directive; `mind_api/package.json` pulls `observe-js` via `github:mind-systems/observe-js#main` (npm's own git resolver, no SSH agent). Correct.
2. **`mind_web` SSH claim (was Critical #2)** — Resolved. The plan downgrades the requirement to "probable, not proven" and adds an explicit clean-build verification step (Task 2). Verified: `mind_web/Dockerfile` carries `# syntax=docker/dockerfile:1`, `RUN --mount=type=ssh npm ci`, and `ssh-keyscan github.com`, while `mind_web/package.json` pins a `git+https://…#v0.1.0` URL — exactly the mismatch the plan describes. Keeping `ssh: [default]` to match the Dockerfile while verifying is the right call.
3. **prod/dev project-name collision (was Critical #3)** — Resolved. The plan adds a deployment-topology assumption (isolated Compose projects) and the Build reference uses explicit `-p mind_prod` / `-p mind_dev`, plus a `HOST_*` port-collision caveat for co-located hosts. Correct: both files derive the same default project name (`mind`) from the directory basename, so `-p` is the necessary isolation mechanism.
4. **Web observability vars (was WARN #4)** — Addressed. The plan documents the scope limit and explains why `VITE_LOG_DESTINATION` / `VITE_OTLP_ENDPOINT` are intentionally left out (the web Dockerfile only declares `ARG VITE_API_BASE_URL`). Verified accurate.
5. **`CONTAINER_DB_PORT` = 5432 (was WARN #5)** — Addressed with an explicit inline comment. Verified: `database.config.ts` reads `port = CONTAINER_DB_PORT` (line 9) and `host = POSTGRES_HOST` (line 8), so the constraint is real.
6. **API healthcheck/logging (was WARN #6)** — Addressed. Task 2 now spells out the API `wget` healthcheck and `json-file` rotation and uses `depends_on: { mind_api: { condition: service_healthy } }` for `mind_web`. Matches the reference compose.

---

## Critical Issues

None.

---

## Non-Blocking Issues (WARN)

### 1. Be explicit about omitting `container_name:` / `image:` to preserve `-p` isolation
The reference `mind_api/docker-compose.prod.yml` sets `container_name: mind_api_prod`, `container_name: mind_api_database_prod_host`, and `image: mind_api_prod:latest`. `container_name` is **host-global** — it ignores the Compose project name — so if those keys were copied into both root compose files, the `-p mind_prod` / `-p mind_dev` isolation the plan relies on would break (name conflict on a co-located host) and the second `up` would fail.

The plan's per-service key lists do not include `container_name`, and Task 2 scopes "follow the reference" narrowly to *healthcheck/logging style*, so a careful implementer will omit them. Still, since the implementer is pointed at a reference file that *does* set these, one defensive sentence — "do not set `container_name:`; let Compose derive names from the `-p` project so prod/dev stay isolated" — would remove the last foot-gun. Non-blocking.

### 2. `mind_api` runtime `image:` name is unspecified (cosmetic)
Without an `image:` key the built API image gets an auto-generated `mind_prod-mind_api` / `mind_dev-mind_api` name. That's fine and actually reinforces isolation; just noting the deviation from the reference so it isn't mistaken for an omission.

---

## Positive Notes

- **Env key set verified exact.** Diffed the Task 1 key list against `mind_api/.env.prod` and `.env.dev` — all 33 keys present, no missing or stray entries, and the Postgres/`CONTAINER_DB_PORT`/`HOST_DB_PORT` de-duplication note is correct.
- **SSH reasoning is now codebase-accurate** for both services, including the `git+https` vs `--mount=type=ssh` mismatch on `mind_web` and the verification step to settle it empirically rather than by assertion.
- **No migration task needed** — `migrationsRun: true` in `database.config.ts` applies migrations on API startup. Correctly not duplicated as a plan task.
- **`env_file:` vs `--env-file` distinction** (runtime env vs `${VAR}` interpolation for ports/healthcheck/build-args) is real and correctly explained; obsolete top-level `version:` correctly omitted.
- **`.gitignore` check is correct** — root ignores `.env.*` with a `!.env.example` exception (lines 25–27); no edit required, exactly as the plan states.
- **Healthcheck/logging blocks** match the reference compose (`pg_isready -U ${POSTGRES_USER}` 10s/5s/5; API `wget` 10s/5s/3/start_period 40s; `json-file` 10m/3).

---

## Verdict

The plan is well-researched, internally consistent, and every claim I spot-checked against the codebase holds. All three round-1 blockers and both WARNs are resolved or explicitly scoped. The only remaining items are non-blocking hardening notes (avoid copying `container_name`) that do not affect correctness of the deliverable.

PLAN_REVIEW_PASS
