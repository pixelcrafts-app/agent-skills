---
name: pc-planning
description: Apply when starting any delivery task — feature, fix, migration, or refactor. Use before writing any code. Also use when the user asks for a plan, routing decision, or task breakdown. Triggers on phrases like "plan this", "how should we approach", "break this down", or any multi-file implementation request.
---

# Planning

## Step 0 — Route the task (before anything else)

Before reading any files, classify the task by shape. This is the routing decision — inline or agents.

| Task shape | Route |
|---|---|
| 1 file, 1 concern, no consumers | Inline |
| 2–3 files, same module, known structure | Inline |
| Research across unknown codebase area | Spawn Explore agent → inline continues with findings |
| 3+ independent files across separate modules | Parallel agents — one per module partition |
| Task requires research AND implementation | Research agent first → implement inline with findings |
| Work spans 2+ independent layers or domains | Agent per domain, parallel |
| Large audit or multi-dimension verification | Run verification skill |
| Feature touching shared contracts (schema, auth, public API) | Sequential agents — contract layer first, feature after |

**The default is NOT inline.** Inline is for narrow, single-focus tasks. Anything multi-file, multi-concern, or spanning independent domains should route to agents first — not as a fallback when inline gets unwieldy.

**If the route is agents:** write the agent briefs now, before any inline work starts. State the routing decision explicitly:

```
Routing: <N> parallel agents / sequential — reason: <why inline is insufficient>
Agent 1: <scope>
Agent 2: <scope>
Dependency: <agent 2 waits for agent 1 result / independent>
```

## Before planning, understand

If the ask references code you haven't read, read the relevant files first. You cannot plan changes to code you don't understand.

## Starting from scratch (no files read yet)

When no files have been read — new session, new task — run discovery before planning:

1. Identify the entry point for the task
2. Read that file and the files it directly imports
3. Identify the stack from file extensions and package manifests
4. Locate one working example of the same pattern the task requires and read it
5. Check for `.kimi/AGENTS.md` at the project root. If absent: detect stacks from files, and note in the plan.
6. Only after steps 1–5: proceed to the planning steps below

## Planning Steps

1. **Restate the ask in one sentence.** If ambiguous, resolve before continuing.
2. **Read the relevant files.** Only after reading: list what will change in each file and what contracts or exports those changes affect. Mark unread files as TBD.
3. **Walk dependencies.** What imports the changed files? If a contract changes, what breaks? Use grep or search to find consumers — do not guess. Flag high-blast-radius changes.
4. **Name the unknowns.** List things you will only discover during implementation. Mark them TBD.
5. **List verification criteria.** What must be observable or tool-verifiable after the task is complete? Each criterion must be checkable with a specific tool call — not prose like "the screen renders."
6. **Confirm routing decision.** Step 0 made the routing decision — confirm it holds after reading the code. Re-route now if needed, not mid-implementation.
7. **Present the plan and wait for confirmation.** After confirmation, begin — and update the plan as you learn.

## Plan Block (required for all non-trivial tasks)

After the user confirms the plan, emit a structured plan block:

```
Plan:
Deliverables:
  - Description: "Short statement of what will exist when done"
    Files:
      - path/to/file.ts
    Verification: "Bash: <compile or type-check command> --noEmit"
  - Description: "..."
    Files:
      - path/to/other.ts
    Verification: "Bash: <test runner> <test-file-path>"
Scope Boundary: "What is explicitly NOT in scope"
```

Rules:
- Every deliverable must have a `Verification` field. Priority: (1) Bash command with binary exit code, (2) grep/Read only for concerns no tool covers.
- `Scope Boundary` must state what is explicitly excluded. "Everything else" is not a boundary.

## Trivial-task bypass

Single-file change that touches no exported symbols and no contracts. To qualify:
- Run grep for the changed symbol across the codebase — confirm zero consumers outside the file
- Run grep for the file path being imported anywhere — confirm zero imports

A declaration that a change is trivial is not sufficient. The grep results are the qualification.

## During implementation

- When you discover something the plan didn't account for: state it, revise the plan block, and continue.
- When a step turns out harder than expected: say so before spending more time on it.
- When implementation is complete: run verification before reporting done. Do not compress implementation and verification into one response.
