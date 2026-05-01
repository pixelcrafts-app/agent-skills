---
name: planning
description: Apply when starting any delivery task — feature, fix, migration, or refactor. Runs before any code is written.
---

# Planning

## The purpose of a plan

A plan is a working hypothesis — not a commitment. It updates as you learn. Confirming a plan is permission to start, not permission to ignore what you discover during implementation. When implementation reveals the plan was wrong, update the plan and surface the change before continuing.

## Step 0 — Route the task (runs before anything else)

Before reading any files, classify the task by shape. This is the routing decision — inline or agents. **Make it once, at the start. Do not start inline and switch to agents mid-task — that is not routing, that is giving up.**

| Task shape | Route |
|---|---|
| 1 file, 1 concern, no consumers | Inline |
| 2–3 files, same module, known structure | Inline |
| Research across unknown codebase area | Spawn Explore agent → inline continues with findings |
| 3+ independent files across separate modules | Parallel agents — one per module partition |
| Task requires research AND implementation | Research agent first → implement inline with findings |
| Work spans 2+ independent layers or domains | Agent per domain, parallel |
| Large audit or multi-dimension verification | `verify-changes` |
| Feature touching shared contracts (schema, auth, public API) | Sequential agents — contract layer first, feature after |

The routing unit is always structural — independent module, separate domain, shared contract. Never a technology name. The criteria apply to any codebase regardless of what it is built with.

**If the route is agents:** write the agent briefs now, before any inline work starts. State the routing decision explicitly:

```
Routing: <N> parallel agents / sequential — reason: <why inline is insufficient>
Agent 1: <scope>
Agent 2: <scope>
Dependency: <agent 2 waits for agent 1 result / independent>
```

**The default is NOT inline.** Inline is for narrow, single-focus tasks. Anything multi-file, multi-concern, or spanning independent domains should route to agents first — not as a fallback when inline gets unwieldy.

---

## Before planning, understand

If the ask references code you haven't read, read the relevant files first. You cannot plan changes to code you don't understand. A plan written before reading the code is a guess with formatting.

## Starting from scratch (no files read yet)

When no files have been read — new session, new task, autonomous mode — run discovery before planning:

1. Identify the entry point for the task — the file, module, or boundary the task touches first
2. Read that file and the files it directly imports
3. Identify the stack from file extensions and package manifests — do not assume or name one before reading
4. Locate one working example of the same pattern the task requires and read it
5. Check for `.claude/craft.json` at the project root. If absent: detect stacks from file extensions and package manifests, generate a draft craft.json, and note it in the plan block. Do not block work if the user skips config setup.
6. Only after steps 1–5: proceed to the planning steps below

Without completing discovery, any plan produced is fabrication.

## Steps

1. **Restate the ask in one sentence.** If ambiguous — or if reading the code changes your understanding of what was asked — resolve the ambiguity before continuing. Do not proceed with a misunderstood task.

2. **Read the relevant files.** Only after reading: list what will change in each file and what contracts or exports those changes affect. Do not list files you have not read — mark unread files as TBD.

3. **Walk dependencies.** What imports the changed files? If a contract changes, what breaks? Use grep or search to find consumers — do not guess. Flag any high-blast-radius change (exported symbol removed or renamed, function signature changed, DTO field added/removed, route path or method changed).

4. **Name the unknowns.** List things you will only discover during implementation. Mark them TBD. These are the points where the plan is most likely to need revision — surface them before starting, not after the user reports a problem.

5. **List verification criteria.** What must be observable or tool-verifiable after the task is complete? Each criterion must be checkable with a specific tool call (Read, Bash, grep) — not prose like "the screen renders" or "it works."

6. **Confirm routing decision.** Step 0 made the routing decision — confirm it holds after reading the code. If the task turned out to be more complex than the initial classification: re-route now, not mid-implementation. State any dependency changes explicitly.

7. **Present the plan and wait for confirmation.** This is the only question asked up front. After confirmation, begin — and update the plan as you learn.

## Plan Block (required for all non-trivial tasks)

After the user confirms the plan, emit a structured plan block at the end of your planning response. Verification reads this block in Phase 1 — not re-inferred prose.

```
<!-- craft:plan
deliverables:
  - id: D1
    description: "Short statement of what will exist when this is done"
    files:
      - path/to/file.ts
    verification: "Bash: <compile or type-check command> --noEmit"
  - id: D2
    description: "..."
    files:
      - path/to/other.ts
    verification: "Bash: <test runner> <test-file-path>"
  - id: D3
    description: "Pattern not covered by compiler or tests"
    files:
      - path/to/other.ts
    verification: "grep -n '<pattern>' path/to/file"
scope_boundary: "loading state only — auth layer not in scope for this task"
-->
```

Rules for the plan block:
- Every deliverable must have a `verification:` field. **Priority order:** (1) Bash tool command that produces a binary exit code — compile, type-check, scoped test run. (2) grep or Read only for concerns that no available tool covers. Never use grep when a compiler or linter would catch the same thing — the tool verdict is more reliable.
- If no tool command can be written and grep cannot verify it either, the deliverable is too vague — split or restate it first.
- `scope_boundary` must state what is explicitly NOT in scope. "Everything else" is not a boundary — name the specific areas excluded.
- The plan block is the contract Phase 1 uses. Do not restate it in prose after emitting it.

## Trivial-task bypass

Single-file change that touches no exported symbols and no contracts. Exempt from the plan block requirement. To qualify:
- Run grep for the changed symbol across the codebase — confirm zero consumers outside the file
- Run grep for the file path being imported anywhere — confirm zero imports

A declaration that a change is trivial is not sufficient. The grep results are the qualification. If either search returns hits, the change is not trivial and the full plan process applies.

Trivial tasks skip Phase 1 (no plan block to check). Phase 2 skill rules and Tier 1 ALWAYS-MANDATORY security rules still apply.

## During implementation

- When you discover something the plan didn't account for: state it, revise the plan block, and continue. Do not silently deviate from the plan or silently follow a wrong plan.
- When a step turns out to be harder or different than expected: say so before spending more time on it.
- When implementation is complete: run `core-standards:verification` before reporting done. Do not compress implementation and verification into one response — they are separate phases.
