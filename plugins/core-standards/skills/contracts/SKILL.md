---
name: contracts
description: Interface contract system for production autonomous development. Architect defines all contracts before any implementation. Human-approved contracts are locked — no agent can change them. Eliminates integration blindness by making every integration point explicit before code is written.
---

# Contracts

## What it solves

Agents implement in parallel. Agent A's auth service returns `user_id: string`. Agent B's user service expects `userId: number`. Both pass their own tests. Integration fails. No single agent ever saw both sides — the mismatch lived in the gap between them.

Contracts make every integration point explicit before any code is written. Implementations conform to contracts. Integration is mechanical once contracts hold.

## Location

`<project-state-dir>/contracts/`

One file per domain boundary:
```
<project-state-dir>/contracts/
  auth.contract.md
  user.contract.md
  order.contract.md
  ...
LOCKED          ← written after human approval; lists locked files + hashes
```

> **Harness note:** `<project-state-dir>` is harness-specific — e.g. `.claude/` for Claude Code, `.kimi/` for Kimi, `.agent/` for Cursor/Codex, or the project root when no agent-state directory exists.

---

## Contract format

````markdown
# Contract: <domain name>

## Status
draft | reviewed | locked

## Types

```typescript
// TypeScript-style interfaces regardless of implementation language.
// These define shape and invariants — not implementation.

interface User {
  id: string           // UUID v4 — never incremental integer
  email: string        // lowercase, validated on write
  createdAt: string    // ISO 8601 datetime
}
```

## API surface (if applicable)

| Method | Path | Request body | Response body | Errors |
|---|---|---|---|---|
| POST | /auth/login | `{email: string, password: string}` | `AuthToken` | 401, 422 |
| POST | /auth/refresh | `{refreshToken: string}` | `AuthToken` | 401 |
| POST | /auth/logout | `{refreshToken: string}` | `{}` | 401 |

## Events (if applicable)

| Event name | Payload type | Publisher | Subscribers |
|---|---|---|---|
| user.created | `{userId: string, email: string}` | user-service | notification-service |

## Invariants

Rules that must always hold — every test and implementation must respect these:
- `User.id` is UUID v4
- `AuthToken.expiresIn` is always > 0
- A refresh token can only be used once; reuse returns 401

## Dependencies

Depends on: <other contract names>
Used by: <other contract names>
````

---

## Architect protocol

The Architect writes all contracts AFTER `spec.md` is locked, BEFORE any implementation.

### Step 1 — Read the full spec
What are all the domain entities? What are all the points where two pieces of code exchange data?

### Step 2 — Write one contract per domain boundary
A domain boundary is any point where independently-developed code exchanges data: service-to-service, API endpoint, event bus, shared data model.

### Step 3 — Check completeness
- Every entity in the spec has a contract type
- Every API call has an entry in the API surface table
- Every event has an entry in the Events table
- No type references an undefined type

### Step 4 — Check cross-contract consistency
- For every `id` that crosses a boundary: is the type identical on both sides?
- For every shared entity: does it have the same shape in every contract that uses it?
- For every error code: is it defined in the contract that can emit it?

### Step 5 — Set status to `reviewed`, submit for Challenger review

---

## Challenger review (mandatory before locking)

The Challenger receives clean context — it has not seen the spec or the implementation plan. It reads contracts only and asks:

1. Where are type mismatches across contracts?
2. What happens when an invariant is violated — is error handling specified?
3. What data will implementations need that is not in these contracts?

Challenger findings must be addressed before contracts are locked.

---

## Locking

Once human has reviewed and approved:

1. Set status to `locked` in each contract file
2. Write `<project-state-dir>/contracts/LOCKED`:
```
Locked: 2026-05-04T10:00:00Z
auth.contract.md: <sha256 of file content>
user.contract.md: <sha256 of file content>
```
3. Locked contract files are protected by convention — no agent may modify them. Tool-specific adapters may enforce this mechanically; otherwise it is a hard rule of the protocol.

---

## Implementer scope

Each implementer is assigned exactly ONE contract:
- May only write files that implement that contract's surface
- May read other contracts (to understand dependencies) — must not modify them
- Their tests are generated from their contract by the Test Writer — not written by them
- They cannot modify files in `tests/contracts/`

---

## What agents must not do

- Begin implementing before all contracts are locked
- Modify a locked contract file
- Implement against a different contract than assigned
- Write types that contradict their contract's definitions
- Reference a type that is not defined in a locked contract
