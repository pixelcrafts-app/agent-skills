---
name: code-quality
description: Apply when auditing NestJS endpoints for security, correctness, and production readiness — guards, validated DTOs, no `any`, no console.log, tests for happy + failure paths. Smart-audits production concerns (rate limiting, idempotency, retries, webhooks, shutdown, health, tracing, soft delete, audit logs, DB pool, logging) via Detect → Check → Suggest — never blindly enforces. Auto-invoke when adding or modifying endpoints.
---

# API Code Quality Audit

> Universal security/testing/observability/engineering rules apply too; this skill covers NestJS+Prisma specifics. Sections A–I are binary (pass/fail). Sections J–V are contextual — **Detect → Check → Suggest, never auto-enforce.**

## A–I — Binary checks (pass or fail)

**A. Architecture** — controllers HTTP-only; services hold logic; feature/role checks in ONE place; domain constants as enums; modules import only exported services.
**B. Types** — no `as any`, no `as unknown as`; DB results typed; DTOs have `@ApiProperty()`.
**C. Errors** — NestJS exceptions in controllers; typed errors in services; global exception filter; consistent shape; no silent `catch {}`.
**D. Database** — only repos/services query; indexed columns; transactions for multi-step; no N+1; pagination clamped (`min(max(limit,1),100)`).
**E. Security** — every protected route guarded; keys server-side only; secrets in env; class-validator on all DTOs; parameterized queries only.
**F. Hygiene** — no unused imports/providers; no `console.log`; no commented-out code; no TODO without an issue; lint clean.
**G. Performance** — `AbortSignal.timeout()` on external fetches; cache hot data with TTL; bounded queries; `Promise.allSettled` for parallel; intervals cleared in `onModuleDestroy`.
**H. API** — Swagger decorators; consistent response wrapper; versioned routes; correct status codes; query params validated via DTOs.
**I. Consistency** — kebab-case files; PascalCase classes; one service per concern; one error pattern; `UPPER_SNAKE` constants.

## J — Production concerns (Detect → Check → Suggest)

For each: **detect** if it's handled (grep lib/decorator/table/header, ask if it's upstream) → if present, **check** depth → if absent, **suggest** with tradeoffs and let the user decide. Do not retrofit without approval.

| Concern | Detect / key check | If absent |
|---------|-------------------|-----------|
| Rate limiting | `@Throttle`, gateway/WAF; stricter on auth, tenant-aware key | Flag brute-force/cost risk; offer throttler or upstream |
| Idempotency keys | `idempotency-key`, replay table; returns original response | Ask which mutations are critical (payments) → offer pattern |
| Retry + backoff | `p-retry`/circuit breaker; bounded, jittered, idempotent-only | Offer `p-retry`+timeout; warn: retry+no-idempotency = dupes |
| Webhook signatures | verify **before** parse; raw body; timestamp check | **Security gap** if webhooks exist — flag loud, give provider snippet |
| Graceful shutdown | `enableShutdownHooks()`, SIGTERM drain | In containers, missing = dropped requests per deploy |
| Health/readiness | `/health` liveness pure; `/ready` checks deps | Required behind orchestrators; offer `@nestjs/terminus` |
| Correlation IDs | `x-request-id`, AsyncLocalStorage, in every log | Multi-service debugging needs it; offer middleware |
| Soft vs hard delete | `deletedAt` + global filter; GDPR hard-delete path | Ask GDPR/restore needs; else hard delete is fine |
| Audit logs | append-only table; actor/target/before-after | Flag for B2B/admin/regulated; skip for solo/consumer |
| DB pool + timeouts | `connection_limit`, `statement_timeout` | Offer defaults; outages trace to pool exhaustion |
| Env-aware logging | level/format by env; secrets redacted at logger | Offer `pino`; redaction list is non-negotiable |

## V — Verify, don't guess (cross-boundary)

Reading a DB column, calling an SDK, consuming an env var, importing a shared type → **read the source of truth first** (schema, `.env.example`, SDK typings, OpenAPI). Can't read it? Ask a concrete question. Never guess a field name. `"probably user_id"` is the same bug as `"definitely user_id"` when it's `userId`. Surface unverifiable assumptions to the user.

## Verdicts

- **PASS** — meets A–I; J concerns either handled or consciously deferred
- **FAIL** — any A–I violation, or an unaddressed J security gap (webhooks, secrets)
- **INFO** — J suggestion offered, user's call
