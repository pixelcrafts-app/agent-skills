---
name: planning
description: Apply before writing any code for a feature, fix, migration, or refactor.
triggers:
  - User asks for a new feature, bug fix, migration, or refactor
  - Starting work on any task that touches more than one file
scope: All delivery work
outputs: A clear plan with deliverables, verification commands, and scope boundary
---

# Planning

> A plan is a working hypothesis — a confirmed plan is permission to start, not permission to ignore what you discover. **Read before you plan; a plan written before reading the code is a guess with formatting.**

## Checklist

- [ ] Classify task shape → route (inline vs agents) before reading files
- [ ] Read relevant files; walk dependencies + consumers
- [ ] Name unknowns as TBD; list verification as runnable commands
- [ ] Present the plan and wait for confirmation before coding

## 1. Route first (choose once — don't start inline then switch)

| Task shape | Route |
|---|---|
| 1 file, 1 concern, no consumers · 2–3 files same module | Inline |
| Research across unknown area | Explore agent → continue inline with findings |
| 3+ independent files across modules · 2+ independent layers/domains | Parallel agents, one per partition |
| Research **and** implementation | Research agent first → implement inline |
| Large/multi-dimension audit | Verification agents per dimension |
| Touches shared contracts (schema, auth, public API) | Sequential agents — contract layer first |

Default is **not** inline (inline = narrow single-focus only). If using agents, write briefs first and state routing explicitly (`N parallel/sequential — reason; Agent N scope; dependencies`).

## 2. Discovery from scratch (new session/task, no files read)

Entry point → read it + its direct imports → identify stack from extensions/manifests (don't assume) → read one working example of the same pattern → then plan.

## 3. Planning steps

1. Restate the ask in one sentence; resolve ambiguity.
2. List per-file changes — only for files you've read; mark unread as TBD.
3. Walk dependencies; flag high-blast-radius (exported symbol removed/renamed, signature change, DTO/schema field, route path/method).
4. Name unknowns (TBD) and surface them.
5. List verification criteria — each checkable by a specific tool call.
6. Re-confirm the routing decision after reading code.
7. Present and wait for confirmation.

## 4. Plan block (emit after confirmation, every non-trivial task)

```
<!-- plan
 Deliverables:
   D1: <what will exist>   Files: path   Verification: Bash: <type-check/test cmd>
   D2: <pattern not covered by compiler/tests>   Verification: Grep: '<pattern>' path
 Scope boundary: <explicitly what is NOT in scope>
-->
```

Every deliverable has a verification field (prefer a Bash command with a binary exit code; Grep/Read only for what no tool covers). Scope boundary names specific exclusions ("everything else" is not a boundary). This block is the contract verification uses — don't restate it in prose.

## 5. Trivial-task bypass

A single-file change touching no exported symbols/contracts may skip the plan block **only after** grep proves zero consumers and zero imports of the file. The grep results are the qualification; any hit → full plan applies.

## 6. During implementation

Discover something the plan missed → state it, revise the block, continue. A step is harder than expected → say so before sinking more time. Complete → run the block's verification commands before reporting done.

## Verdicts

- **READY** — plan confirmed, route chosen, deliverables + verifications defined
- **BLOCK** — ambiguity/unknowns/scope unsettled; don't start coding
