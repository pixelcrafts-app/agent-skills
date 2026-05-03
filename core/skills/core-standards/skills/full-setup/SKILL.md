---
name: full-setup
description: One-command project setup. Run /full-setup in any project — new or existing. Detects stack and domain, generates the complete project layer (CLAUDE.md, .claude/rules/, agent files, settings.json hook wiring, craft.json, enforcement.json). After /full-setup, the project is ready for autonomous production development.
---

# Full Setup

## What it does

Bridges the gap between the generic claude-craft engine and a specific project. The engine provides universal rules and protocols. This command generates the project layer — everything that is specific to THIS codebase, THIS domain, THIS quality bar. Without this layer, agents have generic rules but no project context.

## Trigger

```
/full-setup "I am building a Superman flying game in Flutter"
```
or
```
/full-setup
```
Run with no args inside an existing project — reads the code to derive context.

---

## Step 1 — Detect stack

Read in order:
- `pubspec.yaml` → Flutter
- `package.json` → check dependencies: `next` → Next.js, `@nestjs/core` → NestJS, else → Node
- `build.gradle` / `settings.gradle` → Android (Kotlin/Java)
- `go.mod` → Go
- `Cargo.toml` → Rust
- `requirements.txt` / `pyproject.toml` → Python
- `*.xcodeproj` / `Package.swift` → iOS/Swift

For each detected stack, select the corresponding claude-craft pack:
| Detected | Pack |
|---|---|
| Flutter | `flutter-standards`, `mobile-standards` |
| Next.js | `web-standards` |
| NestJS | `api-standards` |
| React Native | `mobile-standards` |
| Any | `core-standards` (always) |

If both web + api detected: activate `cross-stack-contracts` enforcement.

---

## Step 2 — Detect domain (existing projects)

For existing projects, read:
- `src/` directory structure — what are the top-level modules/features?
- Key model or entity files — what are the core domain entities?
- Existing test patterns — what conventions are already in use?
- README.md if present — what does the project say it does?

For new projects: use the description provided.

---

## Step 3 — Generate project layer

Generate each file below. If a file already exists, preserve it — only generate what is missing. Never overwrite existing content unless explicitly asked.

### `CLAUDE.md` (project root)

```markdown
# <Project Name>

## What this is
<2–3 sentences — what the app does, who it's for, what platform>

## Stack
<detected stacks and key dependencies>

## Autonomous pipeline
This project uses the production autonomous pipeline. The pipeline order is mandatory:

1. **spec-validator** — spec.md validated and acceptance-tests.md locked before any code
2. **contracts** — all interfaces defined, Challenger-reviewed, and locked before implementation
3. **contract-tests** — tests generated from contracts by Test Writer before implementation
4. **implementer** — one contract at a time, makes contract tests pass, fix loop capped at 3
5. **challenger** — adversarial review after each phase, blocks on critical findings
6. **integration** — wires all implementations, runs acceptance tests, fix loop capped at 5
7. **reviewer** — fresh context, reads spec + acceptance test results, approves or creates gap tasks

## Definition of done

A task is done ONLY when:
- [ ] All contract tests for this task pass
- [ ] All unit tests pass
- [ ] No TODO / FIXME in any changed file
- [ ] verify-changes passes on all changed files
- [ ] progress.md updated to `contract-tests-passing`

A feature is done ONLY when:
- [ ] All acceptance tests pass
- [ ] Reviewer returns APPROVED
- [ ] No open WARN findings in progress.md

## Key conventions
<detected from codebase or inferred from stack — file naming, module structure, error format>

## Current milestone
<empty — filled when /spec is run>
```

### `.claude/rules/domain.md`

```markdown
# Domain Rules: <Project Name>

## Core entities
<list detected entities with key invariants — e.g., "User: id is UUID, email is unique">

## Business rules
<rules specific to this domain that are not covered by generic stack packs>

## Key constraints
<performance, platform, external integration constraints>
```

For a new project: derive from description.
For an existing project: derive from detected models, services, and existing comments.

### `.claude/rules/quality.md`

```markdown
# Quality Rules: <Project Name>

## Performance budget
<e.g., "API responses under 200ms p95", "UI renders at 60fps", "bundle under 200KB">

## Test coverage
- All business logic must have unit tests
- All API endpoints must have contract tests
- All acceptance criteria must have acceptance tests
- No untested public interfaces

## Platform requirements
<e.g., "iOS 15+, Android 8+", "Node 20+", "Flutter 3.x">

## Error handling
<e.g., "all API errors return {code, message}", "all UI errors show user-facing message">
```

### `.claude/agents/orchestrator.md`

```markdown
---
name: orchestrator
description: Coordinates the autonomous pipeline. Reads spec and progress, creates tasks, monitors completion. Never writes code.
---

# Orchestrator

Read at every start:
- CLAUDE.md (pipeline order)
- .claude/spec.md (current goal + status)
- .claude/acceptance-tests.md (definition of done)
- .claude/contracts/ (what is locked)
- .claude/progress.md (current state)

## Decision tree

1. spec.md missing or not locked → STOP: tell user to run spec-validator first
2. contracts missing or not locked → create tasks: architect, challenger review, human approval
3. contract-tests missing → create task: Test Writer generates tests for each locked contract
4. implementations incomplete → create one implementer task per unlocked contract
5. all contracts implemented (contract-tests-passing) → run Integration Challenger, then integration task
6. integration complete → create reviewer task
7. reviewer APPROVED → done
8. reviewer GAP → create new tasks for gaps → go to step 2

Write all tasks to progress.md using TaskCreate. Never write code. Never modify contracts.
```

### `.claude/agents/implementer.md`

```markdown
---
name: implementer
description: Executes one implementation task at a time. Reads assigned contract, implements it, makes contract tests pass. Cannot modify contracts or contract tests.
---

# Implementer

Read at task start:
- CLAUDE.md (conventions, definition of done)
- .claude/rules/domain.md + quality.md (project rules)
- Assigned contract from .claude/contracts/
- Contract tests from tests/contracts/ (these define "done")
- Relevant existing files (use codebase-index — skip cached unchanged files)

## Protocol

1. Read the assigned contract completely — understand the full surface and invariants
2. Read the contract tests — these are what "done" means
3. Implement to make contract tests pass
4. After every file write: post-test hook runs automatically. If it exits 2, fix before writing next file.
5. Write unit tests in tests/unit/ for internal logic not covered by contract tests
6. Fix loop: if a test fails after a fix attempt, max 3 attempts before escalating
7. When all contract tests pass: update progress.md status to `contract-tests-passing`

## Escalation (3 fix attempts exhausted)

Write to progress.md:
```
task <N>: BLOCKED
contract: <name>
failing-test: <test name + error>
attempts: 3
requires: human review or Challenger input
```
Stop. Do not continue.

## Hard constraints

- Cannot modify .claude/contracts/ files
- Cannot modify tests/contracts/ files
- Cannot write files outside the scope of the assigned contract
- Cannot declare done until ALL contract tests pass
- Cannot skip, comment out, or delete failing tests
```

### `.claude/agents/challenger.md`

```markdown
---
name: challenger
description: Adversarial reviewer. Fresh context only. Reads output and asks what is wrong with it. BLOCK, WARN, or INFO. Feeds findings to Test Writer or Implementer.
---

# Challenger

Read core-standards:challenger for the full protocol and context injection format.

## Project-specific failure modes to prioritize
<generated from domain.md — e.g., for auth: "token reuse", "session invalidation on logout"; for game: "frame rate drops under load", "collision edge cases">

Always ask:
1. In what specific scenario does this break?
2. What assumption did the author make that is likely wrong?
3. What does the spec or contract require that is missing?

Return only findings with severity BLOCK | WARN | INFO.
Never suggest alternative implementations.
Never modify files.
```

### `.claude/agents/reviewer.md`

```markdown
---
name: reviewer
description: Final gatekeeper. Fresh context. Never saw the implementation. Reads spec + acceptance tests + test results. One question: does the output prove the spec is met?
---

# Reviewer

Read at start:
- .claude/spec.md (locked — the goal)
- .claude/acceptance-tests.md (locked — the criteria)
- .claude/contracts/ (locked — the interfaces)
- .claude/progress.md (integration test results)
- git diff (all changes in this session)

## One question

"Do all acceptance tests pass AND do they cover every criterion in spec.md?"

If YES → APPROVED. Write to progress.md: `status: done`

If NO → list each gap as a specific new task. Write to progress.md:
```
reviewer: GAP
gaps:
  - <criterion from spec.md that is not covered by a passing test>
  - <...>
new tasks created: <list>
```

## What NOT to review
- Code style, naming, formatting
- Internal implementation details
- Anything not in spec.md
- Performance (unless spec.md has a performance criterion)
```

### `.claude/agents/integration.md`

```markdown
---
name: integration
description: Wires all implementations together using locked contracts. Runs acceptance tests. Fix loop capped at 5. Fresh context — never saw individual implementations.
---

# Integration Agent

Read core-standards:integration for the full protocol and context injection format.

## Project-specific test commands
<generated by full-setup — e.g., "flutter test test/acceptance/" or "npm run test:acceptance">

## Integration points for this project
<derived from contracts dependency graph — which contracts depend on which>
```

---

## Step 4 — Generate config files

### `craft.json`

```json
{
  "stacks": [<detected stacks>],
  "features": {
    "auth": <true if auth detected | false>,
    "realtime": <true if websocket/socket.io detected | false>,
    "i18n": <true if i18n package detected | false>,
    "payments": false
  },
  "disabled_rules": []
}
```

### `enforcement.json`

```json
{
  "mandatory": [<selected packs from Step 1>],
  "gate_required": true
}
```

### `settings.json` — add PostToolUse hook wiring

Merge into existing `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/post-test.sh"
          }
        ]
      }
    ]
  }
}
```

### `.gitignore` additions

```
# Claude Code — session artifacts, do not commit
.claude/audit-cache.json
.claude/progress.md
.claude/verify-state.json
```

Note: `progress.md` is a session artifact. It changes every session and must not be committed.

---

## Step 5 — Output

```
/full-setup complete — <Project Name>

Stack detected:    <stacks>
Pack selection:    <packs>

Generated:
  CLAUDE.md                          ✓
  .claude/rules/domain.md            ✓
  .claude/rules/quality.md           ✓
  .claude/agents/ (5 agents)         ✓
  .claude/craft.json                 ✓
  .claude/enforcement.json           ✓
  settings.json — hooks wired        ✓
  .gitignore — session artifacts     ✓

Ready. Run /spec "<your goal>" to begin.
```

---

## Preservation rules

- If a file already exists: do not overwrite — generate only what is missing
- If `.claude/craft.json` exists: merge detected stacks; do not replace existing keys
- If `.claude/agents/` files exist: preserve them; only generate missing agents
- If `CLAUDE.md` exists: append a `## claude-craft pipeline` section; do not replace the file
