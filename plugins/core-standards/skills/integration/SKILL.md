---
name: integration
description: Integration phase protocol. Runs after all contracts are implemented and contract tests pass. Wires implementations together using locked contracts as the spec, runs acceptance tests, with an automatic fix loop and a hard cap. Integration agent has fresh context — never saw the implementation process.
---

# Integration

> Each implementation passes its own contract tests in isolation, but those test one side of a boundary. Integration wires them together and runs **acceptance tests** — the only proof the whole system works end-to-end. Trigger when all tasks in the progress state show `contract-tests-passing`.

(`<project-state-dir>` = `.claude/`/`.kimi/`/`.agent/`/project root.)

## Integration agent brief (fresh context)

```
GOAL  Wire all implemented contracts into a working system; make all acceptance tests pass.
CONTEXT  paste full content of every locked contract + acceptance-tests.md;
         per-task status from progress state; exact acceptance + contract test commands.
SCOPE  In: src/, tests/integration/, tests/acceptance/
       Out (do not modify): contracts/, tests/contracts/
TASK   read contracts → wire (connect services, inject deps, configure entry points) →
       run acceptance tests → per failure, fix only the violated boundary → repeat to cap →
       update progress state.
OUTPUT write progress state before returning; return acceptance pass/total + remaining failures.
```

## Fix loop (cap 5)

Per failing test: read full failure → identify the contract boundary it originates from → fix **only the wiring** at that boundary (never refactor implementations) → re-run. **Max 5 attempts.** On the 5th failure, stop and write to progress state:
```
integration: BLOCKED · attempts: 5 · failing-test: <name> · error: <exact> · boundary: <which> · requires: human review
```
No 6th fix; never simplify or skip the test; escalate.

## Progress state (`<project-state-dir>/progress.md` — shared agent state, gitignored, never committed)

```markdown
# Progress: <goal>
## Status: in_progress | integration-complete | blocked | done
## Tasks: | ID | Contract | Agent | Status | Notes |
## Challenger findings (open WARNs)
## Escalations
## Acceptance test results: passing X/Y, failing <list>
```

## Integration agent must not

Modify locked contracts or `tests/contracts/` · refactor individual implementations (wire only) · declare done before all acceptance tests pass · fix a failing test by editing the test · exceed 5 fix rounds · proceed past a BLOCKED escalation without human input.
