---
name: contract-tests
description: Generates tests FROM contracts before any implementation begins. Tests are authored by a dedicated Test Writer, never by the implementer. Implementer cannot modify generated tests. Eliminates fix-the-test and done-delusion — the only way to make tests pass is to correctly implement the contract.
---

# Contract Tests

## What it solves

When the implementer writes tests, it tests what it built. If it built something wrong, the tests confirm the wrong thing. Contract tests are generated from the contract specification — they test whether the implementation conforms to the contract's types, API surface, and invariants. The implementer must make them pass, not modify them.

## When to run

After all contracts are locked, before any implementation begins.

## What the Test Writer reads

- `<project-state-dir>/contracts/<domain>.contract.md` — the locked contract
- `<project-state-dir>/acceptance-tests.md` — for awareness of end-to-end criteria
- Existing test patterns in `tests/` — to match project conventions

> **Harness note:** `<project-state-dir>` is harness-specific — e.g. `.claude/` for Claude Code, `.kimi/` for Kimi, `.agent/` for Cursor/Codex/Aider, or the project root when no agent-state directory exists.

The Test Writer must NOT read any `src/` files. Tests come from contracts, not from code.

---

## Test file location

```
tests/contracts/<domain>.contract.test.<ext>
```

These files are separate from unit tests and integration tests. They test contract conformance only.

Once written, these files are **locked** — add `// LOCKED — generated from contract` as the first line. No agent may modify them.

---

## What to generate for each contract

### 1. Type / shape conformance tests

Verify the implementation returns the exact shape defined in the contract:

```typescript
// auth.contract.test.ts
describe('AuthToken contract conformance', () => {
  it('has accessToken as string', async () => {
    const token = await authService.login({ email: 'test@test.com', password: 'valid' })
    expect(typeof token.accessToken).toBe('string')
  })

  it('has expiresIn as number', async () => {
    const token = await authService.login({ email: 'test@test.com', password: 'valid' })
    expect(typeof token.expiresIn).toBe('number')
  })
})
```

### 2. Invariant tests

One test per invariant listed in the contract:

```typescript
it('expiresIn is always greater than 0', async () => {
  const token = await authService.login(validCredentials)
  expect(token.expiresIn).toBeGreaterThan(0)
})

it('User.id is UUID v4', async () => {
  const user = await userService.create(validPayload)
  expect(user.id).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i)
})
```

### 3. API surface tests (if contract defines endpoints)

One happy-path test + one error test per endpoint:

```typescript
it('POST /auth/login 200 — returns AuthToken shape', async () => {
  const res = await request(app).post('/auth/login').send(validCredentials)
  expect(res.status).toBe(200)
  expect(res.body).toMatchObject({
    accessToken: expect.any(String),
    refreshToken: expect.any(String),
    expiresIn: expect.any(Number)
  })
})

it('POST /auth/login 401 — wrong password', async () => {
  const res = await request(app).post('/auth/login').send({ email: 'a@b.com', password: 'wrong' })
  expect(res.status).toBe(401)
})
```

### 4. Event tests (if contract defines events)

```typescript
it('emits user.created with correct payload shape after user creation', async () => {
  const emitted: unknown[] = []
  eventBus.on('user.created', (payload) => emitted.push(payload))
  await userService.create(validPayload)
  expect(emitted).toHaveLength(1)
  expect(emitted[0]).toMatchObject({ userId: expect.any(String), email: expect.any(String) })
})
```

---

## Locking protocol

After all contract tests are written:

1. Add `// LOCKED — generated from <domain>.contract.md` as the first line of each file
2. Add file entries to `<project-state-dir>/contracts/LOCKED`:
   ```
   tests/contracts/auth.contract.test.ts: <sha256>
   tests/contracts/user.contract.test.ts: <sha256>
   ```
3. Locked contract test files are protected by convention — no agent may modify them. Tool-specific adapters may enforce this mechanically; otherwise it is a hard rule of the protocol.

If a contract is later changed (requires human approval):
- The corresponding contract tests are REGENERATED from scratch — not patched
- Old test file is deleted, new one written, re-locked

---

## Implementer constraints

The implementer:
- Receives the path to their contract tests at the start of their brief
- Must make ALL contract tests pass
- May write additional unit tests in `tests/unit/`
- May NOT modify any file in `tests/contracts/`
- Contract tests are run on every write as a fix-loop gate; failures block progress

---

## What the Test Writer must not do

- Write tests based on what seems easy to implement
- Write tests that test internal implementation details (private methods, internal state)
- Write tests that would pass with a trivial stub (e.g., always returning hardcoded values)
- Modify generated tests after locking based on implementation difficulty
- Leave any test with `.skip` or `.todo` — every test must be runnable
