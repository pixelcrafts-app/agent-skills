---
name: api-design
description: REST API design principles — resource naming, HTTP semantics, status codes, pagination, errors, auth, rate limiting, versioning. Framework-agnostic.
---

# API Design

> Design REST APIs that are predictable, evolvable, and safe. Principles are firm; the numbers and snippets below are starting points — fit them to the project.

## When to apply

Designing or reviewing endpoints, contracts, pagination, error handling, or versioning.

## Principles (firm)

1. **URLs are plural, kebab-case nouns. No verbs in paths.** `/users/:id`, `/users/:id/orders`. Verbs only for non-CRUD actions (`/orders/:id/cancel`).
2. **HTTP method = semantics.** GET safe, PUT/DELETE idempotent, POST not. Don't return `200 {success:false}` — use the real status.
3. **Errors are typed.** Body: `{ error: { code, message, details? } }`. The client switches on `code`, not status alone. Never leak stack traces or SQL.
4. **List endpoints paginate.** Always bounded; never return unbounded sets.
5. **Validate every inbound payload at the boundary** (Zod / class-validator / Pydantic). Reject `422` on semantic failure, `400` on malformed.
6. **Authn + authz on every endpoint** — or mark it explicitly public. Ownership-check resources (a user reads only their own).
7. **Version only on breaking change.** Add fields freely; rename/remove/retype → new version.

## Reference (adjust to context)

**Status codes:** `200/201/204` success · `400/401/403/404/409/422/429` client · `500/502/503` server (send `Retry-After` on `503`/`429`).

**Pagination — pick per use case:**

| Need | Use |
|------|-----|
| Jump to page N, small/admin datasets | Offset |
| Feeds, infinite scroll, large/concurrent data, public APIs | Cursor |

**Filtering/sorting:** query params — `?status=active&sort=-created_at&fields=id,name`.

**Auth:** user sessions → `Authorization: Bearer <token>`; service-to-service → API key header. No custom session headers (invisible to gateways/scanners).

**Rate limiting:** tier by caller, stricter on auth endpoints, return `X-RateLimit-*` + `Retry-After`. *Example* tiers: anon 30/min, authed 100/min, premium 1000/min — set real values from traffic, don't copy these.

## Checklist

- [ ] Plural kebab-case URLs, no verbs in path
- [ ] Method matches semantics; correct status codes
- [ ] Typed error shape `{ code, message, details? }`
- [ ] Input validated at the boundary
- [ ] List endpoints paginated and bounded
- [ ] Authn + authz (or explicitly public); ownership enforced
- [ ] No internal details leaked in responses
- [ ] Breaking change → new version; OpenAPI spec updated
