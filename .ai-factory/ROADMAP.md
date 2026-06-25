# Mind — Root Roadmap

> Cross-project coordination layer: deployment, infrastructure, and architectural decisions spanning all sub-projects.

## Milestones

- [x] **Root docker-compose for full-stack deployment** — No root compose exists today; `mind_api` and `mind_web` have separate Dockerfiles but no unified orchestration. Create `docker-compose.prod.yml` and `docker-compose.dev.yml` at the repo root, each bringing up three containers: `postgres`, `mind_api`, `mind_web` on a shared bridge network. Each compose file reads its own env file (`.env.prod` / `.env.dev`, both gitignored) that feeds all vars to all services — postgres credentials, mind_api secrets, and `VITE_API_BASE_URL` build-arg for mind_web (`https://api.mind-awake.life` prod / `https://dev-api.mind-awake.life` dev). Build with `DOCKER_BUILDKIT=1` for the SSH mount required by mind_api's private dependency. Commit `.env.example` with all keys and empty values. Spec: `.ai-factory/notes/01-root-docker-compose.md`. [21m 52s]
