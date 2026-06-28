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

> Durable state belongs in a file, not in conversation memory. Every state file must have an owner, a schema, a lifecycle, and a clear concurrency policy.

## When to Apply

- A workflow spans multiple tool calls or agents
- Results must survive past the current response
- Subagents need a shared truth layer outside the conversation thread
- Work may be resumed in a later session

## Must-Do Checklist

- [ ] Name the owner skill or workflow for every state file
- [ ] Define the schema and include a sample
- [ ] Decide whether the file is committed or ignored
- [ ] Define the lifecycle: created, read, updated, deleted
- [ ] Document invalidation triggers
- [ ] State the concurrency policy

## Rules

### 1. One owner per file

Every state file has exactly one owner. Other skills may read it, but only the owner defines its schema and write path.

| Concern | Typical owner |
|---|---|
| Project configuration | Project bootstrap / config skill |
| Per-file analysis cache | Incremental analysis / cache skill |
| Per-run verification state | Verification workflow skill |
| Escalation log | Challenger / escalation skill |

### 2. Schema first

Define the schema before writing. Include:

- Required fields and types
- Example values
- Which fields are set by the owner and which by consumers

A state file without a documented schema becomes a dumping ground.

### 3. Lifecycle

For each state file, document:

- **Created** — when and by what action
- **Read** — which workflows read it and why
- **Updated** — append-only or overwrite; full or partial
- **Deleted / invalidated** — when it must be cleared or rebuilt

### 4. Commit or ignore?

| Type | Commit? | Reason |
|---|---|---|
| Project configuration | Yes | Shared team source of truth |
| Per-file analysis cache | No | Local, machine-specific, session-derived |
| Per-run verification state | No | Per-run, per-machine |
| Escalation log | Optional | Team visibility vs local noise |

### 5. Invalidation contract

State must be invalidated when its assumptions change.

| Trigger | Action |
|---|---|
| Underlying file content changed | Rebuild per-file cache entries |
| Rule definitions changed | Clear affected cache dimensions |
| Schema version bumped | Clear and rebuild the file |
| Run completed | Mark per-run state as completed, overwrite on next run |

### 6. Concurrency

Two parallel runs against the same state file can clobber each other. State the policy:

- Sequential only
- Lock file required
- Accept last-write-wins
- Partition by run ID

If no stable session ID is available, avoid relying on per-run state for parallel runs.

### 7. Trust boundary

Subagent prose is a summary for humans, not a verification signal. When subagents write state:

- The parent verifies by reading the state file
- Missing entries for assigned scope mean the agent failed its write-back contract
- Re-analyze inline when state is missing or inconsistent

## Verification Commands

- Read the state file and confirm it matches the documented schema
- Confirm committed state files are not machine-specific
- Confirm ignored state files are listed in the project's ignore rules

## Verdicts

- **VALID** — file owned, schema documented, lifecycle clear
- **ORPHANED** — file exists with no clear owner
- **STALE** — invalidation trigger fired but file not cleared
- **CONFLICT** — parallel writes risk data loss; policy undefined
