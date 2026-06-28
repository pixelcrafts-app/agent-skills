---
name: state-files
description: Apply when a workflow needs to persist state across tool calls, agent spawns, or sessions.
triggers:
  - Designing a multi-step workflow
  - Sharing state between a parent agent and subagents
  - Resuming work across sessions
scope: Any workflow that needs durable state
outputs: A clear ownership and lifecycle policy for each state file
---

# State Files

> Durable state belongs in a file, not conversation memory. Every state file needs an **owner, schema, lifecycle, and concurrency policy.**

## 1. One owner per file

Exactly one owner defines the schema + write path; others may read. (config → bootstrap skill · per-file cache → analysis skill · per-run state → verification skill · escalation log → challenger.)

## 2. Schema first

Define before writing: required fields + types, example values, which fields the owner sets vs consumers. No schema → it becomes a dumping ground.

## 3. Lifecycle

Document created (when/by what), read (which workflows + why), updated (append vs overwrite, full vs partial), deleted/invalidated (when cleared/rebuilt).

## 4. Commit or ignore?

| Type | Commit? |
|---|---|
| Project config | Yes — shared team source of truth |
| Per-file cache · per-run verification state | No — local/session-derived |
| Escalation log | Optional (team visibility vs local noise) |

## 5. Invalidation

| Trigger | Action |
|---|---|
| Underlying file changed | rebuild per-file cache entries |
| Rule definitions changed | clear affected dimensions |
| Schema version bumped | clear + rebuild |
| Run completed | mark done; overwrite next run |

## 6. Concurrency

Parallel runs can clobber a shared file. State the policy: sequential-only · lock file · last-write-wins · partition by run ID. No stable session ID → don't rely on per-run state for parallel runs.

## 7. Trust boundary

Subagent prose is a human summary, not a verification signal. When subagents write state, the **parent verifies by reading the file**; missing entries for assigned scope = failed write-back → re-analyze inline.

## Verdicts

- **VALID** — owned, schema documented, lifecycle clear
- **ORPHANED** — file with no clear owner
- **STALE** — invalidation trigger fired but file not cleared
- **CONFLICT** — parallel writes risk data loss; policy undefined
