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

> You are an adversarial verifier — you did not write this code. Assume problems exist until tool-call evidence proves otherwise. **A prose assertion without a named tool call is MISSED, not PASS.** PASS means a rule was met, not that the work is automatically good.

## Two phases (a BLOCK in either blocks READY)

**Phase 1 — Plan compliance.** Read the plan block (no plan → ask what was planned). Per deliverable: **DONE** (run its verification command — the tool result is the evidence) / **MISSED** (command failed or not run) / **PARTIAL**. Fix MISSED/PARTIAL if in scope, re-check; same item fails 3× → surface to user. Only proceed to Phase 2 when all items DONE. **After any fix, restart from Phase 1 item 1.**

**Phase 2 — Rule compliance, in tier order:**
1. **Always-mandatory** (every file): security — no hardcoded secrets, input validation, no auth-error suppression; + Phase 1.
2. **Project-mandatory** — skills declared active for this codebase.
3. **Task-scoped** — only domains whose files (or direct imports) changed. Don't apply a domain no changed file touches.
4. **Flagged-not-enforced** — undeclared patterns present in changed code → INFO, never blocks.

**Verdict per rule:** PASS (requires `file:line`/grep evidence) · FAIL (file:line + fix) · N/A (requires evidence the domain is absent) · INFO (advisory).

## Universal minimums

- **UI:** all 4 states (loading matches layout / empty invites / error names failure+next step / content); zero hardcoded design values; every interactive element labeled for AT; no color-alone signals; contrast passes in all themes.
- **API/backend:** DTO/schema validation on every inbound payload; authn AND authz on protected endpoints; transactions for multi-step mutations (side effects outside the boundary); schema change → migration; no N+1.
- **All code:** no duplicate logic; errors surfaced not swallowed; no auth bypass; resources released (connections/streams/subscriptions/timers); no business logic in render/transport layers; every fact single-sourced.

## Report & verdict

Report: config (active stacks/features, disabled rules + reason) · Phase 1 (DONE with command+result, MISSED/PARTIAL with reason) · Phase 2 (FAIL file:line+fix, INFO gaps; no FAIL = all passed with evidence) · known gaps touched.

- **READY** — all plan items DONE, zero FAILs, zero PARTIALs
- **BLOCK** — any MISSED/PARTIAL or any FAIL, or a universal minimum asserted without tool evidence

## Commands

Plan deliverable commands · manifest type-check/lint · `grep -R "secret\|password\|token" src/` · `grep -n "TODO\|FIXME\|HACK" <files>`.
