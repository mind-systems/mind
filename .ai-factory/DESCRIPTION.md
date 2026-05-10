# Project: Mind

## Overview

Mind is a wellness/breathing app consisting of a NestJS REST API backend, a Flutter mobile app (iOS/Android), a static landing page, an MCP server for Claude Code integration, and a Flutter plugin wrapping the Neiry neurofeedback hardware SDK. Users authenticate via passwordless email (one-time code), perform guided breathing sessions, and the app persists session history both locally (Drift) and remotely (PostgreSQL). The landing page serves as a public-facing entry point for the product.

## Core Features

- Passwordless email authentication (one-time code) with JWT session management
- Guided breathing sessions with animated UI (shape morphing, physics-based motion)
- Breathing session history — CRUD, pagination, local cache + remote sync
- Offline-first: Drift (SQLite) local DB, synced to API on reconnect
- Static landing page with Snake easter-egg (placeholder while real content is built)

## Tech Stack

### Backend (`mind_api/`)
- **Language:** TypeScript
- **Framework:** NestJS
- **Database:** PostgreSQL
- **ORM:** TypeORM (migrations-based, synchronize: false)
- **Auth:** Passwordless email + one-time code, Passport JWT (access token), JWT blacklist (PostgreSQL, purged nightly via cron)
- **Infra:** Docker (dev + prod), Makefile

### Mobile (`mind_mobile/`)
- **Language:** Dart
- **Framework:** Flutter 3+
- **Local DB:** Drift (SQLite ORM, code-gen based)
- **State:** Riverpod (presentation) + RxDart BehaviorSubject (domain)
- **Navigation:** GoRouter
- **HTTP:** Dio + AuthInterceptor
- **Flavors:** dev / prod

### Landing (`mind_landing/`)
- **Stack:** Plain HTML/CSS/JS — single `index.html`, no build step, no dependencies
- **Current state:** Placeholder with a playable Snake game; real product content TBD

### MCP Server (`mind_mcp/`)
- **Language:** TypeScript
- **Transport:** stdio (MCP protocol)
- **Role:** Claude Code integration — exposes Mind API tools (breath sessions, auth tokens) to AI agents
- **Proto:** consumes `.proto` files from `mind_api/proto/`, regenerates TypeScript stubs via `npm run proto:gen`

### Neiry Kit (`neiry_kit/`)
- **Stack:** Flutter plugin (Dart + native iOS/Android bridges)
- **Role:** Wraps the Neiry/Capsule neurofeedback hardware SDK; tested via included example app before integrating into `mind_mobile`
- **Vendored binaries:** `official/iOS/CapsuleClient.framework` (XCFramework), `official/Android/CapsuleService.aar` + `devicedriver.aar`

## Architecture Notes

### Backend
Modular Monolith. Each domain (auth, breath-sessions, mail) is a self-contained NestJS feature module. Single-guard auth: `JwtAuthGuard` on all protected routes. Passwordless flow: user requests code → receives email → exchanges code for JWT. Controllers are thin — all logic in services.

### Mobile
Layered architecture: Repository → Notifier (domain) → Service → ViewModel → Screen + Coordinator. ViewModel is the module boundary; domain models never leak into presentation. DI is manual via `App.shared` singleton.

## Cross-project Coordination

- API changes first (migrations → controller → service), then mobile client
- DTO shapes must stay in sync: Dart models + Drift schema must match API responses
- Auth changes affect both `mind_api/src/auth/` and `mind_mobile/lib/Core/Api/AuthInterceptor.dart` + `lib/User/`

## Non-Functional Requirements

- Logging: NestJS built-in logger, configurable
- Error handling: Structured HTTP errors on API, typed domain events on mobile
- Security: JWT blacklist (PostgreSQL), HTTPS
