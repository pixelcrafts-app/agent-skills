---
name: contract-tests
description: Generates tests FROM contracts before any implementation. Authored by a dedicated Test Writer, never the implementer; the implementer cannot modify them. Eliminates fix-the-test and done-delusion — the only way to pass is to correctly implement the contract.
---

# Contract Tests

> When the implementer writes the tests, it tests what it built — wrong build, wrong tests confirm it. Contract tests come from the contract (types, API surface, invariants); the implementer must make them pass, not modify them.

**When:** after all contracts are locked, before any implementation.

**Test Writer reads** the locked `<project-state-dir>/contracts/<domain>.contract.md`, `acceptance-tests.md` (awareness), and existing `tests/` patterns. **Must NOT read any `src/`** — tests come from contracts, not code. (`<project-state-dir>` = `.claude/`/`.kimi/`/`.agent/`/project root.)

**Location:** `tests/contracts/<domain>.contract.test.<ext>` — separate from unit/integration; first line `// LOCKED — generated from contract`.

## Generate per contract

- **Shape conformance** — implementation returns exactly the contract's types: `expect(typeof token.accessToken).toBe('string')`.
- **Invariants** — one test each: `expect(token.expiresIn).toBeGreaterThan(0)`; `expect(user.id).toMatch(/UUID-v4-regex/)`.
- **API surface** (if endpoints) — one happy + one error per endpoint: `POST /auth/login` → 200 with `toMatchObject({accessToken: expect.any(String), ...})`; wrong password → 401.
- **Events** (if events) — subscribe, act, assert payload shape: `user.created` emitted once with `{userId: any(String), email: any(String)}`.

## Locking

After writing: `// LOCKED` first line + sha256 entries in `<project-state-dir>/contracts/LOCKED`. No agent may modify locked test files (mechanically enforced where the harness supports it, else a hard rule). If a contract changes (human-approved), the tests are **regenerated from scratch** (delete + rewrite + re-lock), never patched.

## Implementer constraints

Gets the contract-test path in its brief; must make **all** pass; may add `tests/unit/`; may **not** touch `tests/contracts/`. Contract tests run on every write as a fix-loop gate — failures block progress.

## Test Writer must not

Write tests around what's easy to implement · test internals (private methods/state) · write tests a trivial stub would pass (hardcoded returns) · loosen tests after locking for implementation difficulty · leave any `.skip`/`.todo` (every test runnable).
