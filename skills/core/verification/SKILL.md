---
name: verification
description: Apply after completing any delivery task before reporting done.
triggers:
  - User says "verify" or "check"
  - Before reporting a task complete
  - After finishing a non-trivial batch of edits
scope: All delivered code, any stack
outputs: READY or BLOCK verdict with tool-call evidence
---

# Verification

> You are an adversarial verifier. You did not write this code. Assume problems exist until tool-call evidence proves otherwise. A PASS verdict means a rule was met — not that the work is automatically good.

## When to Apply

- After completing any task, before saying "done"
- When the user explicitly asks for verification
- Before committing or shipping a change

## Must-Do Checklist

- [ ] Re-read the plan and confirm every deliverable was executed
- [ ] Run the verification command for each deliverable
- [ ] Apply the universal minimums for the domains touched
- [ ] Cite file:line or grep evidence for every PASS and FAIL
- [ ] Restart verification from the first item after any fix
- [ ] Report READY only when all items pass with evidence

## Rules

### 1. Two-phase verification

Run both phases. A BLOCK in either phase blocks READY.

- **Phase 1 — Plan compliance:** confirm every planned deliverable was executed and verified.
- **Phase 2 — Rule compliance:** confirm the change meets applicable standards.

### 2. Phase 1 — Plan compliance

Read the plan block from the conversation. If no plan exists, ask the user what was planned before proceeding.

For each deliverable:

- **DONE** — run the verification command from the plan. The tool result is the evidence.
- **MISSED** — the verification command failed or was not run
- **PARTIAL** — the command partially passed; explain what is there vs what is missing

Rules:
- Every MISSED or PARTIAL item: attempt to fix it if within scope, then re-check.
- If the same item fails 3 times: stop and surface it to the user.
- Only continue to Phase 2 when all plan items are DONE.
- After any fix, restart verification from Phase 1 item 1.

### 3. Phase 2 — Rule compliance tiers

Apply rules in this order.

**Tier 1 — Always-mandatory**
Apply to every task on every file, regardless of project config or scope.

- Security: no hardcoded secrets, input validation, no auth error suppression
- Plan compliance from Phase 1

**Tier 2 — Project-mandatory**
Apply skills declared active for this codebase.

- Example: a web stack declared active means web standards apply to web files
- Example: an auth feature declared active means auth-flow rules apply

**Tier 3 — Task-scoped**
Apply only if the task modified files in that domain. Use changed files and their direct imports to detect scope.

Do not apply rules from a domain if no changed file touches it.

**Tier 4 — Flagged-not-enforced**
Gap zones not declared but whose patterns exist in changed code. Emit as INFO, not FAIL. Do not block READY.

### 4. Verdict per rule

- **PASS** — tool-call evidence required: file:line or grep result confirming compliance
- **FAIL** — file:line, rule violated, fix required
- **N/A** — rule genuinely does not apply. Requires grep or Read result confirming the domain is absent
- **INFO** — advisory only, never blocks

A prose assertion without a named tool call is MISSED, not PASS.

### 5. Universal minimums — UI work

- All 4 states present: loading, empty, error, content
- Loading: meaningful placeholder matching final layout
- Empty: invites action, not "No data found"
- Error: names the specific failure and gives a concrete next step
- Zero hardcoded color, spacing, radius, typography, or duration values
- Every interactive element labeled for assistive technology
- No color as the sole signal for any state
- Contrast meets minimum thresholds in all themes

### 6. Universal minimums — API/backend work

- Every inbound payload has DTO/schema validation
- Every protected endpoint has authentication AND authorization
- Multi-step mutations use transactions; side effects outside transaction boundaries
- Schema change accompanied by a migration
- No N+1 queries

### 7. Universal minimums — all code

- No duplicate logic
- Errors surfaced, not swallowed
- No auth or authorization bypasses
- Resources released: connections, streams, subscriptions, timers, handles
- No business logic in rendering or transport layers
- Every fact lives in one place

### 8. After a fix

1. Re-run the exact failed rule against the modified file using a tool call
2. A description of the fix is not a PASS — the re-evaluation result is the PASS
3. Restart from Phase 1 item 1

## Report

```
Step 0 — Config
  Active stacks: [...]
  Active features: [...]
  Disabled rules: [...] (reason required per entry)

Phase 1 — Plan
  DONE: [item — verification command run, result]
  MISSED/PARTIAL: [item — reason]

Phase 2 — Skill Rules
  FAIL: [file:line — rule — fix required]
  INFO: [gap zone detected]
  (No FAIL entry = all rules passed with tool-call evidence)

Known gaps touched by this task:
  [list any unowned areas the task touched]

Verdict:
  READY — all plan items DONE, zero FAILs, zero PARTIALs
  BLOCK — [specific items or rule failures preventing completion]
```

Never report READY with any MISSED or PARTIAL plan item, any FAIL, or any universal minimum asserted without tool-call evidence.

## Verification Commands

- Plan deliverable commands as declared in the plan block
- Project type-check / lint / analyze commands from its manifest
- `grep -R "secret\|password\|token" src/` — hardcoded credential sweep
- `grep -n "TODO\|FIXME\|HACK" <changed-files>` — unfinished work

## Verdicts

- **READY** — all plan items DONE, zero rule FAILs, zero PARTIALs
- **BLOCK** — any MISSED/PARTIAL plan item or any FAIL rule
