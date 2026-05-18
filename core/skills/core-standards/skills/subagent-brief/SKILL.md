---
name: subagent-brief
description: Read this BEFORE calling the Task or Agent tool. Governs three decisions — should I spawn at all, how many agents, what goes in the prompt. Defines the warm-brief format and warmth scoring that determines whether a spawn is allowed.
requires:
  - codebase-index   # cache pass-through + write-back contracts reference this skill's protocol
---

# Subagent Brief Discipline

## RULE

Every Task/Agent prompt must contain labeled sections covering GOAL, CONTEXT, SCOPE, and OUTPUT. Prompts missing these must not be spawned.

---

## Contracts — non-negotiable for file analysis delegation

These three apply whenever a subagent will read, analyze, or audit files. They are not advisory.

### 1 — Cache pass-through

Before spawning, load `.claude/audit-cache.json` and extract cache hits for the agent's file scope. Include them explicitly in the brief under a `CACHE CONTEXT` section. An agent without cache context re-reads every file from scratch — this is the primary source of token waste in multi-agent work.

See `codebase-index` Multi-agent protocol for the exact extraction and injection format.

### 2 — Excerpt contract (never name, always paste)

If the parent already read a file, paste the relevant lines into the brief. Do not tell the subagent to read it. Naming a file the parent already loaded makes the subagent pay again for something already in context.

```
# Wrong — makes subagent re-read
CONTEXT
  See src/activity/activity.controller.ts for the auth guard setup.

# Right — transfers the cost to a few tokens
CONTEXT
  src/activity/activity.controller.ts:17 — @UseGuards(AuthGuard) at controller level (all endpoints protected)
  src/activity/activity.controller.ts:40 — @Query('limit') limit = '50' (no max validation)
```

### 3 — Write-back contract

If the agent analyzes files, it must write findings to `.claude/audit-cache.json` before returning. Include this instruction explicitly in the OUTPUT section:

```
OUTPUT
  Write findings to .claude/audit-cache.json (codebase-index Step 3) for each file analyzed.
  Return compact summary only: files analyzed, cache hits skipped, top findings.
```

The parent verifies by reading the state file — not by re-reading the agent's prose. An agent that returns a prose summary but writes nothing to the cache has not completed its contract.

---

## Trust model — state files, not prose

Subagent output is a summary for humans. It is not a verification signal.

After every agent returns:
- Check `.claude/audit-cache.json` — are findings written for the agent's assigned files?
- Check `.claude/verify-state.json` — are batch records present (if running verify-changes)?
- Any file in scope with no cache entry = agent failed the write-back contract → re-analyze inline.

"I checked the auth module and it looks correct" with nothing written to the cache is not a PASS. Evidence lives in state files.

---

## GUIDE — advisory judgment calls

Everything below is judgment. Claude decides.

---

## Decision 1 — Spawn or inline?

Before writing a prompt, answer these. The first **yes** kills the spawn.

| Question | If yes → | Why |
|---|---|---|
| Can this be answered with at most a couple of inline searches or reads? | Inline | Round-trip and cold-start costs exceed the direct calls |
| Is the target file already known? | Inline | Edit directly; spawning to "find it" when you already know is waste |
| Will the result inform the very next tool call? | Inline | Round-trip latency exceeds the saving |
| Is the task open-ended or exploratory with no shape? | **Reshape first** | Open-ended briefs waste the spawn |
| Will the parent re-read the same files to verify the subagent's output? | Inline | That's not delegation; that's paying twice |

### Positive signals — when spawning is the right call

- The work spans many files across a subsystem not yet in the parent's context.
- The work is a **scoped audit** on one dimension of one folder, and would otherwise pollute the main thread with many Reads.
- The work is **genuinely cross-cutting research** where the answer is a summary, not an edit.
- The work can be **stated as a specific question** with a bounded output shape.

If none apply, go inline.

### The hardest rule

**Never delegate understanding.** A subagent without understanding will invent it and return prose that sounds correct. Delegate *lookups*, *scoped audits*, and *narrow-scope execution*. Understanding stays with the parent.

---

## Decision 2 — How many agents?

### The default is one

Fan out only when all three hold:

1. **Independent work** — one agent's findings do not alter another's scope.
2. **Disjoint scope** — no two agents search the same files or patterns. Overlap pays twice.
3. **Uniform output shape** — results combine without a reconciliation step.

Any failure of the three: one agent, or go inline.

### Count guidance

| Work shape | Agents |
|---|---|
| Find one fact | 1 (usually inline) |
| Scoped audit on one dimension of one folder | 1 |
| Audit across many dimensions | N, where each agent owns a disjoint partition of dimensions |
| Identical lookup across N disjoint folders | N (diminishing returns above ~4) |
| Research across a dependency graph where each finding narrows the next question | 1 (serial) |
| "Verify everything is fine" | 0 — not delegable; reshape into specifics or abandon |

Beyond ~4 parallel agents, the coordination tax (merging heterogeneous outputs) usually outweighs the parallelism gain.

### Serial, not parallel — common miss

Work is serial whenever a later agent's scope depends on an earlier agent's output. Mapping then auditing, discovering then verifying, surveying then deep-diving — these are sequences, not fan-outs. Running them in parallel just means both agents guess.

---

## Decision 3 — What goes in the prompt?

A prompt is warm when a fresh instance could answer it using only what is in the prompt. The warmth scoring below defines what counts.

### Warmth signals

| Signal | Value | Form |
|---|---|---|
| Labeled section | 1 each | A marker keyword as a section label, with or without trailing colon; heading, bold, or plain form all accepted. Keywords: `GOAL`, `CONTEXT`, `SCOPE`, `TASK`, `OUTPUT`, `DELIVERABLE`, `BUDGET`. |
| Code fence | 1 | Any triple-backtick block. Presence of pasted content is the strongest warmth signal. |
| File path reference | 1 each (cap 2) | Any `dir/file.ext` pattern with optional `:line`. Language-agnostic. Must contain `/` so bare dotted names do not count. |

### The scope-scaled bar

| Prompt length | Required score | Meaning |
|---|---|---|
| `<400` | 0 | Trivial lookup — no ceremony |
| `400–1500` | 2 | Medium spawn — any mix of labels and pasted context |
| `≥1500` | 3 | Heavy spawn — full warm brief expected |

These signals are proxies for a real test: could a fresh instance answer from the prompt alone? If not, neither can the subagent.

### The brief template

```
GOAL
  <one sentence: the specific answer required>

CONTEXT (what the parent already has — do not rediscover)
  - <path/file:line> — <pasted excerpt or one-line summary>
  - <fact> — <source>
  - <exclusions> — <paths the subagent must not investigate>

CACHE CONTEXT (file analysis tasks only — omit for pure research/lookup)
  Skip entirely — already audited, content unchanged:
    <path>  [<dimension> → <verdict> — <one-line evidence>]
    ...
  Analyze these — cache miss or changed:
    <path>  [reason: in git diff | new file | dimension not yet covered]
    ...

SCOPE
  - In:  <paths or patterns>
  - Out: <explicit exclusions>

TASK
  <verb-first instruction>

OUTPUT
  <return shape — table, bullet list, word budget, line-ref list, etc.>
  [If file analysis]: Write findings to .claude/audit-cache.json before returning.
  [If file analysis]: Return compact summary only — the parent reads the state file, not this summary.

BUDGET  (optional — set when capping spend matters)
  <e.g. tool-call cap>
```

### The highest-leverage habit

Paste the excerpt the parent already has into the prompt, rather than naming the file. Naming the file makes the subagent re-read what the parent already loaded — the exact failure this skill exists to prevent. Pasting transfers the cost from the subagent to a handful of tokens in the prompt.

---

## Anti-patterns

1. **Delegating understanding.** Spawn for findings; decide inline; edit (or spawn narrowly) for the fix.
2. **Unbounded brief.** A prompt with no goal, no scope, and no output shape causes the subagent to invent all three.
3. **Exploration without reshaping.** Replace open-ended exploration prompts with a specific enumerated read set and a shaped summary output.
4. **Spawn for trivial work.** Round-trip plus cold start costs more than a direct inline call.
5. **Overlapping parallel agents.** Agents with intersecting scope duplicate their work — the same file read by two agents is always wasted.
6. **Spawn then re-verify manually.** Re-reading the same files the subagent read is paying twice, not delegating.
7. **Name-drop brief.** Referring to a file by path instead of pasting the relevant excerpt forces the subagent to re-read context the parent already has.
8. **No cache pass-through.** Sending a file analysis agent without cache context makes it re-read and re-analyze every file the cache already has answers for.
9. **Trusting prose over state.** Accepting "I verified it and it's fine" without checking `.claude/audit-cache.json` or `.claude/verify-state.json` is not verification.
10. **No write-back instruction.** If the OUTPUT section does not say "write to cache", the agent will not write. Findings that exist only in the agent's response text are lost when the context window clears.

---

## When a subagent returns

- Response much longer than needed → output shape was underspecified; tighten it next time.
- Subagent asks clarifying questions → brief was underspecified; answer inline, do not respawn.
- Subagent reports work beyond the brief → scope creep; push back.

---

## Budget reality

Cost anchored to the inline equivalent, not absolute tokens:

| Task | Spawn vs inline |
|---|---|
| Narrow lookup | Roughly equal; savings are in avoiding main-thread context pollution |
| Scoped single-dimension audit | Often cheaper when inline would force many Reads into the main thread |
| Cross-cutting research | Nearly always cheaper — the spawn's best case |
| Explain-this-module | Comparable; go inline unless the explanation itself would be long |
| Open-ended | Always worse — reshape or do not spawn |

A spawn that spends more than the inline equivalent indicates a bad brief, not a bad tool.

---

## Final rule

Before calling Task or Agent: write the prompt, then read it. If the task cannot be completed using only what is in that prompt, neither can the subagent. Add what is missing before spawning — not after.
