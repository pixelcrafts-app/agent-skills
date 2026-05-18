---
description: Take a broad multi-file or multi-domain task and emit a parallel-agent plan in one shot — partition the work, write warm agent briefs, spawn the agents in a single batched response. Closes the "auto-spawn on broad tasks" gap with one explicit keystroke. Pass the task description as $ARGUMENTS.
---

# /parallelize

$ARGUMENTS

You are running the **parallelize protocol** for the task above. Follow it exactly — no improvisation.

## Step 1 — Read the task

Treat `$ARGUMENTS` as the task statement. If it's empty, ask the user for the task and stop.

## Step 2 — Apply planning:Step 0 routing

Consult `core-standards:planning` Step 0. Classify the task by structural shape using the routing table.

| Task shape | Route |
|---|---|
| 1 file, 1 concern, no consumers | Inline (refuse `/parallelize` — tell the user it's not parallel) |
| 2–3 files, same module, known structure | Inline (refuse) |
| 3+ independent files across separate modules | Parallel agents — one per module partition |
| Task requires research AND implementation | Sequential — research agent first, then implementation inline |
| Work spans 2+ independent layers or domains | Agent per domain, parallel |
| Feature touching shared contracts | Sequential — contract agent first, feature after |

If the task does **not** route to parallel or sequential agents: stop. Tell the user: *"This task fits inline work better than parallel agents. Routing decision: inline. Reason: <one-sentence reason>."* Do not spawn agents.

## Step 3 — Partition the work

For tasks that DO route to agents:

- **Independent partitions** = each agent's scope must not overlap another's files / modules / domains. Overlap pays twice (per `subagent-brief:106`).
- **Disjoint scope** = no two agents grep the same patterns.
- **Uniform output shape** = results combine without a reconciliation step.

If you cannot identify independent partitions, the task is actually sequential or inline. Re-classify.

## Step 4 — Emit the craft:plan block

Write the plan block in your response, BEFORE spawning any agents:

```
Routing: <N> parallel agents — reason: <one sentence: why inline is insufficient>

Agent 1: <module/domain scope> — <verb-first one-line task>
Agent 2: <module/domain scope> — <verb-first one-line task>
...
Agent N: <module/domain scope> — <verb-first one-line task>

Dependency: independent          (or: agent 2 waits for agent 1)

<!-- craft:plan
deliverables:
  - id: D1
    description: "<what Agent 1 will produce>"
    files: [<path>, <path>]
    verification: "<command or check>"
  - id: D2
    description: "<what Agent 2 will produce>"
    files: [<path>, <path>]
    verification: "<command or check>"
  ...
scope_boundary: "<what is explicitly NOT in scope>"
-->
```

The Routing line is mandatory — `core-hooks:plan-required` in strict mode blocks any plan with 3+ deliverables that omits it.

## Step 5 — Spawn the agents in a single batched response

In the **same** response that emitted the plan, make all `Agent` / `Task` tool calls in one message (Claude Code supports parallel tool calls in a single assistant turn). Each agent gets a warm brief per `core-standards:subagent-brief`:

```
GOAL
  <one sentence: the specific answer required>

CONTEXT (what the parent already has — do not rediscover)
  - <path:line> — <pasted excerpt or one-line summary>
  - <fact> — <source>

CACHE CONTEXT (file analysis only)
  Skip entirely — already audited:
    <path>  [<dimension> → <verdict> — <evidence>]
  Analyze these — cache miss or changed:
    <path>  [reason: in git diff | new file | dimension not yet covered]

SCOPE
  - In:  <paths or patterns>
  - Out: <explicit exclusions, plus the OTHER agents' scopes — never overlap>

TASK
  <verb-first instruction>

OUTPUT
  <return shape — table, bullet list, word budget, line-ref list>
  Write findings to .claude/audit-cache.json before returning.
  Return compact summary only — the parent reads the state file.
```

**Critical:** every brief explicitly excludes the OTHER agents' scopes (under `SCOPE → Out`). This is the non-overlap discipline that makes parallel agents cheaper than sequential.

## Step 6 — Wait for all agents to return, then consolidate inline

After all agents return:

1. Read `.claude/audit-cache.json` and `.claude/verify-state.json` (per `core-standards:subagent-brief:54-62` trust-state-files-not-prose).
2. Do **not** re-verify the agents' work by reading the same files. That's paying twice.
3. Synthesize the consolidated answer inline from the state file evidence.
4. If integration conflicts surface (overlapping changes, contract mismatches), invoke `core-standards:integration` skill — do not patch inline.

## Step 7 — Run verify-changes

After consolidation, run `core-standards:verify-changes` on the union of all agent file scopes. This catches anything the per-agent rule iteration missed.

If `enforcement.json` has `verify_required: "strict"`, this step is enforced by `post-edit-verify.sh` — you can't Stop the turn without it.

## Honest limits

`/parallelize` is **user-triggered**. There is no system mechanism to fan out tasks the user did NOT explicitly invoke this command for. The `parallel-hint.sh` UserPromptSubmit hook NUDGES toward this command on broad-wording tasks, but the actual spawn is still your decision.

If the task genuinely should not be parallelized (single file, contract-bound sequence, research first then implement), refuse the command per Step 2. Forcing fan-out on a non-parallelizable task wastes spawn budget and produces incoherent results.

## Anti-patterns this command prevents

| Anti-pattern | Why /parallelize prevents it |
|---|---|
| Going inline by reflex on a 10-file refactor | Routing decision in Step 2 forces classification |
| Spawning 5 agents that all read the same auth module | Step 3 partitioning + Step 5 brief exclusion enforce non-overlap |
| Spawning agents without pasting CONTEXT | Step 5 brief template requires it (per subagent-brief:25-37) |
| "Synthesize results" by re-reading the same files the agents read | Step 6 explicitly forbids this (state-file trust model) |
| Skipping verify-changes after parallel work | Step 7 + post-edit-verify hook |
