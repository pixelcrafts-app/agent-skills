---
name: state-files
description: Glossary of every state file the core-standards skill pack uses. Maps each file to its owner, schema, lifecycle, and concurrency rules. Read this when you see a reference to .claude/audit-cache.json, .claude/verify-state.json, .claude/progress.md, or .claude/craft.json in another skill and need to know what owns it.
---

# State files used by core-standards

This is a reference, not a workflow — no actions to take, no decisions to make. It exists so that any skill referencing a `.claude/*.json` or `.claude/*.md` file can link here instead of redefining the schema. If you see one of these files mentioned anywhere and you don't know what it is, this is the answer.

## The four state files

| File | Owner | Read by | Lifecycle |
|---|---|---|---|
| `.claude/craft.json` | `craft-config` | `verification`, `verify-changes` | Persistent. Created once per project by `craft-config`. Edited by the operator. |
| `.claude/audit-cache.json` | `codebase-index` | `subagent-brief`, `verify-changes` | Persistent across sessions. Entries keyed by file blob hash. Invalidated per §3 below. |
| `.claude/verify-state.json` | `verify-changes` | `verify-changes` (resume), `subagent-brief` (cross-agent trust) | Per-run. `status: in_progress` while a run is active, `status: completed` when it ends. Overwritten on next fresh run. |
| `.claude/progress.md` | `challenger` (escalation only) | operator, future runs | Append-only. Records escalations after 3-round BLOCK persistence. |

---

## 1. `.claude/craft.json` — project configuration

**Owner:** `craft-config` skill. See its SKILL.md for the canonical schema.

**Used by:**
- `verification` (Step 0) — `stacks[]`, `features{}`, `disabled_rules[]`
- `verify-changes` (Phase 0, Phase 4.0) — same

**Lifecycle:**
- Created once by `craft-config` (or by hand) at the project root.
- Edited by the operator when stacks, features, or rule opt-outs change.
- Never overwritten by skills at runtime — read-only from the verifier's perspective.

**Git:** committed. This is project configuration, not session state.

---

## 2. `.claude/audit-cache.json` — per-file analysis cache

**Owner:** `codebase-index` skill. See its SKILL.md for the canonical schema and the read/write protocol.

**Shape (in-memory):**

```
{ <path>: { blob_hash, audited_dimensions[], findings[] } }
```

**Used by:**
- `subagent-brief` — parent extracts cache hits and pastes them into the CACHE CONTEXT section of a subagent brief, so the agent doesn't re-analyze unchanged files.
- `verify-changes` (Phase 0.3, Phase 4.1 step 1, Phase 4.1 step 6a) — load before run, skip cache-hit files during analysis, write findings back at end of each batch.

**Lifecycle:**
- Persistent across sessions. Lives across `verify-changes` runs.
- Keyed by file content hash (git blob hash), so file edits invalidate entries automatically.
- **Does not auto-invalidate on rule definition changes.** See §3 for the invalidation contract.

**Git:** typically `.gitignored`. This is local cache, not shared state.

---

## 3. Audit-cache invalidation contract

Cache entries are invalidated automatically when the **file content** changes (blob hash mismatch). They are **not** automatically invalidated when a skill's **rule definitions** change.

Three invalidation triggers:

| Trigger | Mechanism | Whose responsibility |
|---|---|---|
| File content changed | Blob hash mismatch → cache miss → re-analyze | Automatic (handled in `codebase-index` Step 2) |
| Rule definition changed (skill edited) | None — operator must clear cache manually | Operator |
| Cache schema version bumped | None — operator must clear cache manually | Operator |

**Operator action when a skill's rules change:**

```bash
rm .claude/audit-cache.json
```

Or, to clear only one dimension:

```bash
jq 'del(.. | .audited_dimensions? | select(. == ["<dimension-name>"]))' \
  .claude/audit-cache.json > .tmp && mv .tmp .claude/audit-cache.json
```

**Recommended:** when a skill rule is meaningfully changed in this repo, bump the skill pack version (semver minor or major) and document in the changelog that operators clear `audit-cache.json` after upgrade. Currently this is convention, not enforced.

---

## 4. `.claude/verify-state.json` — per-run verification state

**Owner:** `verify-changes` skill. See its SKILL.md §0.4 for the canonical schema.

**Used by:**
- `verify-changes` itself — resume capability (Phase 0.1), per-batch write-back (Phase 4.1 step 6), Phase 5 consolidated report.
- `subagent-brief` trust model — dimension-agent subagents write their findings here, parent reads from here rather than from agent prose.

**Lifecycle:**
- One file per active run. `run_id` identifies the run.
- `status: in_progress` between Phase 0 and Phase 5.
- `status: completed` set at end of Phase 5.
- A fresh run on a `status: completed` file overwrites the file.

**Concurrency:**
Two parallel `verify-changes` invocations against the same project clobber each other's state. **Mitigation:** the Claude CLI does not expose a stable session ID today, so the `run_id` collision is real. If you run two verify-changes in parallel terminals, expect data loss. Practical guidance: run sequentially per project, or accept that one terminal's run will be the survivor.

**Git:** `.gitignored`. Per-run, per-machine.

---

## 5. `.claude/progress.md` — escalation log

**Owner:** `challenger` skill (write path) — see its SKILL.md, re-review protocol section.

**Used by:**
- `challenger` — appends an entry when a BLOCK persists after 3 rounds.
- Operator — reads it to triage stuck items.

**Schema (markdown, append-only):**

```
task <N>: ESCALATED
reason: challenger BLOCK unresolved after 3 rounds
finding: <paste the BLOCK finding>
requires: human review
```

**Lifecycle:**
- Created on first escalation.
- Append-only — never overwritten by skills.
- Operator manually clears entries when items are resolved.

**Git:** convention is to commit it (or part of it), so escalations are visible to the team. Operator's choice.

---

## Why all four exist

| File | Why we need it |
|---|---|
| `craft.json` | Project-shape source of truth (stacks, features). Without it, every verification re-detects from scratch and the answer can drift. |
| `audit-cache.json` | Without per-file caching, every verify-changes run re-reads the entire codebase. Token cost grows linearly with project size. |
| `verify-state.json` | Multi-agent trust requires a shared truth layer that isn't the conversation thread. State file is that layer. |
| `progress.md` | Escalations need to outlive the session. Some BLOCKs require human judgment that can't be resolved in-loop. |

Four files, four problems, no overlap. If you find a fifth state file appearing in a skill, suspect duplication — file an issue before adding it.
