---
name: pc-verification
description: Apply after implementation is complete, before declaring a task done. Use when the user asks to verify changes, check work, or run a pre-ship audit. Also use automatically after completing any multi-file or non-trivial task. Switch mindset from implementer to verifier.
---

# Verification

## Mindset switch

You are not confirming your own work is correct — you are trying to find what is wrong with it. The implementing mindset expects success. The verifying mindset expects failure. Assume problems exist until tool-call evidence proves otherwise.

## Phase 1 — Check the plan

If a plan block exists: verify every deliverable was completed. If not, report what is missing.

## Phase 2 — Run stack-specific checks

Based on the project's stack (declared in `.kimi/AGENTS.md` or detected from files):

**TypeScript / Node.js:**
- `npx tsc --noEmit` must pass
- `npm test` (or equivalent) must pass

**Flutter / Dart:**
- `flutter analyze` must pass
- `flutter test` must pass

**General:**
- No `console.log` in production paths
- No hardcoded constants in providers/business logic
- Every DB query filters by tenant/app_id if multi-tenant

## Phase 3 — Rule audit

Run the universal-rules security scan on every file touched:
- §1.1 No hardcoded secrets
- §1.2 Input validation at boundaries
- §1.3 Auth errors surfaced, not swallowed

## Phase 4 — Evidence

Report PASS/FAIL per check with:
- The exact command run
- The output (truncated if verbose)
- `file:line` references for any FAIL

If all checks pass: state "Verification complete — all checks pass."
If any check fails: state what failed, why, and the fix. Do not declare the task done until fixed or explicitly waived by the user.
