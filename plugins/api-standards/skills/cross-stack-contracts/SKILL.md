---
name: cross-stack-contracts
description: Apply when 2+ stacks communicate (Flutter+NestJS, Next.js+NestJS, any frontend+backend) — error shape, pagination, auth header, versioning at the boundary. Active when craft.json stacks[] has 2+ entries, or any code touches an external API boundary.
---

# Cross-Stack Contracts

> The boundary between stacks is where silent drift hits hardest — one side changes, the other breaks at runtime, and neither's tests catch it. Lock the contract.

## When to apply

`craft.json stacks[]` has 2+ entries, or a single-stack project consumes/exposes an external API boundary.

## Rules (firm)

1. **One error shape everywhere:** `{ code, message, details? }`. The consumer switches on `code` (e.g. `auth.token_expired`), not status alone. `code` lives in a shared enum, never a raw string in the handler. `message` is for logs, not UI.
2. **Cursor pagination for new endpoints.** Offset shifts under concurrent writes (pages repeat/skip). Offset is allowed only with a documented reason (e.g. user-facing page numbers); never silently.
3. **`Authorization: Bearer <token>` for user sessions** across all stacks — no custom session headers (gateways and scanners can't see them). Service-to-service API keys may use custom headers.
4. **Breaking change → new route version.** Breaking = remove/rename/retype a field, change method, change auth. Additions (new optional field/endpoint) don't. Never strip a field from a live version — mark `@deprecated` and keep it until the version retires.
5. **The boundary has a generated, committed spec** (OpenAPI from `@nestjs/swagger` / `next-swagger-doc`). Consumers read the spec, not the endpoint name.

## Checklist

- [ ] Error responses use `{ code, message, details? }`; `code` from a shared enum
- [ ] New endpoints cursor-paginated (or offset with a documented reason)
- [ ] User auth uses `Authorization: Bearer`; no custom session headers
- [ ] Breaking changes versioned; no field removed from a live version
- [ ] Generated OpenAPI spec exists and is updated when the contract changes
