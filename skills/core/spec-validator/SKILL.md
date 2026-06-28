---
name: spec-validator
description: Run before any implementation. Defines spec.md format and the validation protocol — challenges a spec for gaps and ambiguities, produces a locked acceptance-tests.md that becomes the objective definition of done. No implementation may begin until spec.md is locked.
---

# Spec Validator

## What it solves

Implementation without a verifiable spec produces undecidable "done". The implementer declares done when its local tests pass — but those tests test what it built, not what was needed. This skill enforces spec-first: a spec is challenged for completeness before any code is written, and acceptance tests derived from it become the only objective gate.

## When to invoke

Before any implementation begins. If the project's spec file does not exist or its status is not `locked`, run this skill first.

---

## spec.md — format

Location: the project's spec file (conventionally `<project-state-dir>/spec.md`)

> **Harness note:** `<project-state-dir>` is harness-specific — e.g. `.claude/` for Claude Code, `.kimi/` for Kimi, `.agent/` for Cursor/Codex, or the project root when no agent-state directory exists.

```markdown
# Spec: <goal in one line>

## What it does
<2–4 sentences — user-facing description, not implementation detail>

## Acceptance criteria
- [ ] <verifiable criterion — observable outcome a test can assert>
- [ ] <...>

## Out of scope
- <explicit exclusion — ambiguity becomes scope creep>

## Assumptions
- <anything the spec assumes that isn't stated in the goal>

## Open questions
- <ambiguity that must be resolved before implementation>

## Status
draft | validated | locked
```

- `draft` — initial write, not yet challenged
- `validated` — all questions answered, no open ambiguities
- `locked` — acceptance tests written and human-approved; implementation may begin

---

## Validation protocol

When spec status is `draft`, challenge it with these questions before allowing implementation to start.

### Completeness checks

1. Can every acceptance criterion be asserted by a deterministic test? If not, rewrite it.
2. Are there implicit requirements the spec omits? (auth, error states, loading states, empty states, edge cases, platform constraints)
3. Is "out of scope" explicit? Unspecified scope becomes scope creep mid-implementation.
4. Does any criterion use "properly", "correctly", "well", "nicely"? These are not testable. Make them concrete and measurable.

### Ambiguity checks

5. Does the spec use undefined terms? Define them inline.
6. Are branching scenarios covered? (what if X fails? what if input is empty? what if network is offline?)
7. Does the spec assume infrastructure that may not exist? (auth service, external API, database table, third-party SDK)
8. Are performance or platform constraints stated? (response time, frame rate, minimum OS version)

### Validation output

- Surface gaps as specific questions, not general statements
- Wait for answers before changing status
- Rewrite spec to incorporate answers
- Set status to `validated`

---

## acceptance-tests.md — format

Location: the project's acceptance-tests file (conventionally `<project-state-dir>/acceptance-tests.md`)

Written AFTER spec is `validated`. Written by a dedicated Test Writer — never by the implementer.

```markdown
# Acceptance Tests: <goal>

## LOCKED
<!-- Add this line only after human approval. Locked files may not be modified by any agent. -->

---

## Test: <criterion name>
**Scenario:** <one sentence — what situation this tests>
**Given:** <initial system state>
**When:** <action taken>
**Then:** <observable outcome — what the test asserts>
**Automated:** yes | manual
**File:** tests/acceptance/<name>.<ext>

---
```

Every acceptance criterion in the spec file must have at least one test entry here.

### Locking

1. Test Writer creates the file
2. Human reviews — checks that every criterion is covered and tests are meaningful
3. Human adds `## LOCKED` header line to the file
4. No agent may modify a locked acceptance-tests file
5. If a gap is found later: add a new test block — never modify existing ones

---

## Pipeline position

```
spec.md (draft)
  → Spec Validator challenges it
  → open questions answered by human
  → spec.md (validated)
  → Test Writer writes acceptance-tests.md
  → human approves acceptance-tests.md
  → acceptance-tests.md (LOCKED)
  → spec.md status → locked
  → Architect may now write contracts
  → Implementation may now begin
```

---

## What agents must not do

- Begin implementation before the spec file status is `locked`
- Write acceptance tests that match the implementation rather than the spec criteria
- Modify the locked acceptance-tests file after it is locked
- Declare a feature done without all acceptance tests passing
- Rewrite a criterion to match broken behavior instead of fixing the behavior
