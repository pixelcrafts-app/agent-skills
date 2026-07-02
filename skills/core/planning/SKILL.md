---
name: planning
description: Apply before implementation when work is non-trivial, ambiguous, risky, multi-file, or the user asks for a plan. Use tiered planning: skip visible plans for trivial changes, keep small clear changes lightweight, present concise plans for non-trivial work, and wait for confirmation only when scope, risk, cost, or user intent is unsettled.
triggers:
  - User asks for a plan, feature, bug fix, migration, or refactor
  - Starting work that may touch multiple files, contracts, data, or public behavior
scope: Planning delivery work before implementation
outputs: A fit-for-scope plan with deliverables, scope boundary, and verification checks when needed
---

# Planning

> Plan enough to stay focused. Do not turn planning into the work.

## Priority

Read enough current context before planning. A plan is a hypothesis: revise it when discovery proves it wrong. Planning must reduce risk or clarify execution; if it adds ceremony without changing the work, keep it internal.

## Task Tiers

| Tier | Use When | Planning Behavior |
|---|---|---|
| **Trivial** | One local edit, docs/text tweak, no exported symbols, no contracts, no consumers | No visible plan. Read the target, make the change, verify appropriately. |
| **Small Clear** | One concern, known files/pattern, low blast radius | Keep an internal plan. Proceed after reading relevant code. |
| **Non-Trivial** | Multiple files, new behavior, refactor, migration, or shared code | Present a concise visible plan with deliverables, scope boundary, and verification. |
| **Confirm First** | Ambiguous requirement, destructive action, public API/schema/auth change, external side effect, high cost, or user asked for plan-only | Ask and wait before implementation. |

## Discovery

Before a visible plan, read the entry point, direct imports or consumers, and one nearby working example when available. Do not invent file lists from naming alone. Mark unread areas as `TBD` instead of pretending certainty.

## Plan Shape

For non-trivial work, use this shape:

```md
Plan:
- Deliverables: <specific outcomes>
- Files/areas: <read files first; TBD for unread areas>
- Scope boundary: <specific exclusions>
- Verification: <runnable checks or concrete inspection>
```

Keep plans short. Name decisions and risks; do not narrate obvious steps like "open file" or "edit code" unless they affect risk.

## During Implementation

- If discovery changes the plan, state the change and continue when scope/risk is unchanged.
- If scope, risk, cost, or user-visible behavior changes, checkpoint before proceeding.
- Do not expand into adjacent cleanup, refactors, or documentation unless it is required for the planned deliverable.

## Verdicts

- **PROCEED** — plan tier fits the task and no confirmation gate is active
- **CONFIRM** — ambiguity, risk, cost, or user intent requires waiting
- **REPLAN** — discovery invalidated the plan or scope boundary
