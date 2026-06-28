---
name: nestjs
description: Apply when writing or reviewing NestJS + Prisma code — module/controller/service/repository discipline, thin controllers, validated DTOs, repository-wrapped Prisma, consistent error shape. Auto-invoke on changes under src/.
---

# NestJS + Prisma

> Keep layers thin and one-directional: controller → service → repository. Each layer does one job.

## When to apply

Writing or reviewing any file under `src/` in a NestJS project.

## Rules (firm)

**Layering**
- Controllers handle HTTP only — no business logic, no DB access. One per resource. Return DTOs, not entities. Explicit `@HttpCode()` when non-default.
- Services hold all business logic. Constructor-injected deps. Throw specific exceptions (`NotFoundException`, …), never raw `Error`.
- Repositories are the only layer touching the DB client. Transactions for multi-step mutations.

**Modules**
- One module per feature under `src/modules/<feature>/`; shared infra in `src/common/`. Export only the public surface. `forwardRef()` only when a circular dep is truly unavoidable. Register global pipes/filters/guards once in the app module.

**DTOs & validation**
- Every inbound payload is a DTO with `class-validator` decorators — validate at the boundary, trust nothing. Separate Create/Update DTOs (compose with `PartialType`/`PickType`/`OmitType`). `@ApiProperty()` on response DTOs.

**Errors & config**
- Global exception filter → one consistent error shape. Never return raw DB errors; stack traces in dev only.
- All config via `ConfigService`/env — no hardcoded URLs, keys, ports. Validate required config on startup (fail fast).

**Types** (NestJS-specific)
- No `any` — use `unknown` then narrow at the boundary. `enum` for finite value sets. `readonly` on DTO/config fields.

## Checklist

- [ ] Controllers: HTTP only, return DTOs, no DB/business logic
- [ ] Services: all logic, typed exceptions, injected deps
- [ ] Repositories: sole DB access; transactions for multi-step writes
- [ ] Every inbound DTO validated with class-validator
- [ ] Global exception filter; no raw DB errors leaked
- [ ] Config from env, validated on startup
- [ ] No `any`; finite sets are enums
