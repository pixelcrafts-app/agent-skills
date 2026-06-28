---
name: spec-validator
description: Run before any implementation. Defines spec.md format and the validation protocol — challenges a spec for gaps and ambiguities, produces a locked acceptance-tests.md as the objective definition of done. No implementation begins until spec.md is locked.
---

# Spec Validator

> Implementation without a verifiable spec produces undecidable "done" — the implementer declares done when *its* tests pass, testing what it built, not what was needed. Enforce spec-first: challenge the spec for completeness, derive acceptance tests, and make those the only objective gate. Run before any implementation; if the spec file is missing or not `locked`, run this first.

Files live at `<project-state-dir>/{spec.md, acceptance-tests.md}` (`.claude/`/`.kimi/`/`.agent/`/project root).

## spec.md format

```markdown
# Spec: <goal in one line>
## What it does       <2–4 sentences, user-facing not implementation>
## Acceptance criteria  - [ ] <observable outcome a test can assert>
## Out of scope       - <explicit exclusion>
## Assumptions / Open questions
## Status             draft | validated | locked
```

Status: `draft` (not challenged) → `validated` (all questions answered) → `locked` (acceptance tests written + human-approved; implementation may begin).

## Validation protocol (when status is `draft`)

**Completeness:** every criterion assertable by a deterministic test (else rewrite) · implicit requirements covered (auth, error/loading/empty states, edge cases, platform) · "out of scope" explicit · no "properly/correctly/nicely" (not testable — make concrete).

**Ambiguity:** no undefined terms (define inline) · branching scenarios covered (X fails? empty input? offline?) · no assumed infrastructure that may not exist (auth service, API, table, SDK) · perf/platform constraints stated.

Output: surface gaps as **specific questions**, wait for answers, rewrite spec to incorporate, set `validated`.

## acceptance-tests.md (after `validated`, by a dedicated Test Writer — never the implementer)

```markdown
## Test: <criterion>
**Scenario / Given / When / Then:** <state → action → observable outcome the test asserts>
**Automated:** yes | manual   **File:** tests/acceptance/<name>.<ext>
```

Every spec criterion has ≥1 test entry. **Locking:** Test Writer creates → human checks coverage + adds `## LOCKED` → no agent may modify it; a later gap adds a new test block, never edits an existing one.

## Pipeline

`spec draft → validator challenges → human answers → validated → Test Writer writes acceptance-tests → human approves (LOCKED) → spec locked → Architect writes contracts → implementation begins.`

## Agents must not

Implement before spec is `locked` · write acceptance tests that match the implementation rather than the spec · modify a locked acceptance-tests file · declare done without all acceptance tests passing · rewrite a criterion to match broken behavior instead of fixing it.
