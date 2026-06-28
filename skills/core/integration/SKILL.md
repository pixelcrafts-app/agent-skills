---
name: integration
description: Integration phase protocol. Runs after all contracts are implemented and contract tests pass. Wires implementations together using locked contracts as the spec. Runs acceptance tests. Automatic fix loop with hard cap. Integration agent has fresh context — never saw the implementation process.
---

# Integration

## What it solves

Individual implementations pass their contract tests in isolation. Integration fails because contract tests test one side of a boundary. Integration wires the implementations together and runs acceptance tests — the only tests that prove the complete system works end-to-end as the spec requires.

## Trigger

Run when all entries in the project's shared progress state file show status `contract-tests-passing`.

---

## Integration agent context injection

```
GOAL
  Wire all implemented contracts into a working system and make all acceptance tests pass.

CONTEXT — locked contracts (paste full content):
  <project-state-dir>/contracts/auth.contract.md
  ---
  <paste content>
  ---
  <project-state-dir>/contracts/user.contract.md
  ---
  <paste content>
  ---

CONTEXT — acceptance tests (paste full content):
  <project-state-dir>/acceptance-tests.md
  ---
  <paste content>
  ---

CONTEXT — implementation status from the project's progress state file:
  auth:   contract-tests-passing
  user:   contract-tests-passing
  <...>

CONTEXT — test commands:
  Run acceptance tests: <exact command — e.g., "flutter test test/acceptance/" or "npm run test:acceptance">
  Run contract tests:   <exact command>

SCOPE
  In:  src/, tests/integration/, tests/acceptance/
  Out: <project-state-dir>/contracts/ (do not modify)
       tests/contracts/    (do not modify)

TASK
  1. Read all locked contracts
  2. Wire implementations — connect services, inject dependencies, configure entry points
  3. Run acceptance tests
  4. For each failing test: identify which contract boundary is violated, fix only that boundary
  5. Repeat until all acceptance tests pass or fix cap is reached
  6. Update the project's progress state file with final status

OUTPUT
  Write to the project's progress state file before returning.
  Return compact summary: acceptance tests pass/total, any remaining failures.

> **Harness note:** `<project-state-dir>` is harness-specific — e.g. `.claude/` for Claude Code, `.kimi/` for Kimi, `.agent/` for Cursor/Codex/Aider, or the project root when no agent-state directory exists.
```

---

## Fix loop protocol

When an acceptance test fails:

1. Read the full failure output
2. Identify the contract boundary where the failure originates
3. Fix the wiring at that boundary — do not refactor implementations
4. Re-run acceptance tests
5. Maximum **5 fix attempts** total

On the 5th failed attempt, stop and write to the project's shared progress state file:
```
integration: BLOCKED
attempts: 5
failing-test: <test name>
error: <paste exact error message>
boundary: <which contract boundary is broken>
requires: human review
```

Do not attempt a 6th fix. Do not simplify or skip the failing test. Escalate.

---

## Progress state file — format

Location: the project's shared progress state file (conventionally `<project-state-dir>/progress.md`)

This file is the shared state between all agents. It is written by agents, read by all. It is **never committed** (add to `.gitignore`) — it is a session artifact.

```markdown
# Progress: <spec goal>

## Status
in_progress | integration-complete | blocked | done

## Tasks

| ID | Contract | Agent | Status | Notes |
|---|---|---|---|---|
| 1 | auth | implementer | contract-tests-passing | — |
| 2 | user | implementer | contract-tests-passing | — |
| 3 | integration | integration | in_progress | — |

## Challenger findings (open WARNs)
- user.contract: missing rate limiting on login endpoint [WARN]

## Escalations
<empty unless blocked>

## Acceptance test results
<filled by integration agent>
  passing: 0/0
  failing: none yet
```

---

## What the integration agent must not do

- Modify locked contract files
- Modify files in `tests/contracts/`
- Refactor individual implementations (wire only — do not improve)
- Declare integration done before all acceptance tests pass
- Fix failing acceptance tests by modifying the tests
- Attempt more than 5 fix rounds
- Proceed past a BLOCKED escalation without human input
