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

> A plan is a working hypothesis. Update it as you learn. A confirmed plan is permission to start, not permission to ignore what you discover during implementation.

## When to Apply

- Before writing or editing code for any non-trivial task
- When the task spans more than one file or one concern
- When the user asks "how should we do this?" or "plan this out"

## Must-Do Checklist

- [ ] Classify the task shape and choose inline vs agents before reading files
- [ ] Read relevant files before listing what will change
- [ ] Walk dependencies and identify consumers of changed contracts
- [ ] Name unknowns explicitly as TBD
- [ ] List verification criteria as runnable tool commands
- [ ] Confirm routing decision still holds after reading code
- [ ] Present the plan and wait for confirmation before coding

## Rules

### 1. Route first

Choose the execution route once, at the start. Do not start inline and switch to agents mid-task.

| Task shape | Route |
|---|---|
| 1 file, 1 concern, no consumers | Inline |
| 2–3 files, same module, known structure | Inline |
| Research across unknown codebase area | Spawn explore agent, then continue inline with findings |
| 3+ independent files across separate modules | Parallel agents — one per module partition |
| Task requires research AND implementation | Research agent first, then implement inline |
| Work spans 2+ independent layers or domains | Agent per domain, parallel |
| Large audit or multi-dimension verification | Spawn verification agents per dimension |
| Feature touching shared contracts (schema, auth, public API) | Sequential agents — contract layer first, feature after |

If using agents, write the briefs before any inline work starts. State the routing decision explicitly:

```
Routing: <N> parallel agents / sequential — reason: <why inline is insufficient>
Agent 1: <scope>
Agent 2: <scope>
Dependency: <agent 2 waits for agent 1 result / independent>
```

The default is not inline. Inline is for narrow, single-focus tasks only.

### 2. Read before planning

If the ask references code you have not read, read the relevant files first. You cannot plan changes to code you do not understand. A plan written before reading the code is a guess with formatting.

### 3. Discovery from scratch

When no files have been read yet — new session, new task, autonomous mode — run discovery before planning:

1. Identify the entry point for the task
2. Read that file and the files it directly imports
3. Identify the stack from file extensions and package manifests — do not assume or name one before reading
4. Locate one working example of the same pattern the task requires and read it
5. Only after steps 1–4: proceed to the planning steps below

### 4. Planning steps

1. Restate the ask in one sentence. Resolve ambiguity before continuing.
2. List what will change in each file. Only list files you have read; mark unread files as TBD.
3. Walk dependencies. Find consumers of changed files. Flag high-blast-radius changes:
   - Exported symbol removed or renamed
   - Function signature changed
   - DTO/schema field added/removed
   - Route path or method changed
4. Name unknowns. Mark them TBD and surface them before starting.
5. List verification criteria. Each must be checkable with a specific tool call.
6. Confirm routing decision still holds after reading code.
7. Present the plan and wait for confirmation.

### 5. Plan block

After confirmation, emit a structured plan block for every non-trivial task.

```
<!-- plan
 Deliverables:
   D1: <short statement of what will exist>
       Files: path/to/file.ts
       Verification: Bash: <compile or type-check command> --noEmit
   D2: <...>
       Files: path/to/other.ts
       Verification: Bash: <test runner> <test-file-path>
   D3: <pattern not covered by compiler/tests>
       Files: path/to/other.ts
       Verification: Grep: '<pattern>' path/to/file
 Scope boundary: <explicitly what is NOT in scope>
-->
```

Rules for the plan block:
- Every deliverable must have a verification field.
- Verification priority: (1) Bash command with binary exit code, (2) Grep or Read only for what no available tool covers.
- Scope boundary must name specific excluded areas. "Everything else" is not a boundary.
- The plan block is the contract verification uses. Do not restate it in prose after emitting it.

### 6. Trivial-task bypass

Single-file change that touches no exported symbols and no contracts may skip the plan block. To qualify:

- Run grep for the changed symbol across the codebase — confirm zero consumers outside the file
- Run grep for the file path being imported anywhere — confirm zero imports

The grep results are the qualification. If either search returns hits, the change is not trivial and the full plan process applies.

### 7. During implementation

- When you discover something the plan did not account for: state it, revise the plan block, and continue.
- When a step turns out harder or different than expected: say so before spending more time on it.
- When implementation is complete: run the verification commands from the plan block before reporting done.

## Verification Commands

- `git status --short` — confirm scope of changed files
- `grep -R "symbol_name" src/` — confirm zero consumers for trivial-task bypass
- Compile/type-check command from the project manifest
- Test command scoped to changed files

## Verdicts

- **READY** — plan confirmed, routing chosen, deliverables and verifications defined
- **BLOCK** — ambiguity, unknowns, or scope not settled; do not start coding
