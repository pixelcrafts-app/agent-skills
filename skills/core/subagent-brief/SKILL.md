---
name: subagent-brief
description: Read this before spawning any subagent. Governs when to spawn, how many agents, and what goes in the prompt.
triggers:
  - Before calling a subagent, Task tool, or delegated agent
  - Planning work that may span multiple files or domains
scope: All agent delegation
outputs: A warm, self-contained brief that a fresh instance can execute without re-discovering context
---

# Subagent Brief Discipline

> Every delegated prompt must be warm: a fresh instance could complete the task using only what is in the prompt. Never delegate understanding. Delegate lookups, scoped audits, and narrow execution.

## When to Apply

- Before spawning any subagent
- When deciding whether to go inline or delegate
- When partitioning work across multiple agents

## Must-Do Checklist

- [ ] Decide spawn vs inline using the routing questions
- [ ] Include labeled GOAL, CONTEXT, SCOPE, and OUTPUT sections
- [ ] Paste excerpts the parent already has; do not name files the parent already read
- [ ] Keep scopes disjoint when running parallel agents
- [ ] Confirm the prompt contains enough information for a fresh instance to succeed

## Rules

### 1. Brief sections are mandatory

Every subagent prompt must contain labeled sections covering:

- **GOAL** — one sentence: the specific answer or outcome required
- **CONTEXT** — what the parent already knows; do not rediscover
- **SCOPE** — in-bounds and out-of-bounds paths or topics
- **OUTPUT** — return shape and how the parent will verify it

Optional sections: TASK, DELIVERABLE, BUDGET.

### 2. Excerpt contract

If the parent already read a file, paste the relevant lines into the brief. Do not tell the subagent to read it. Naming a file the parent already loaded makes the subagent pay again for something already in context.

```
Wrong — makes subagent re-read
  See src/auth/auth.controller.ts for the guard setup.

Right — transfers the cost to a few tokens
  src/auth/auth.controller.ts:17 — @UseGuards(AuthGuard) at controller level
  src/auth/auth.controller.ts:40 — @Query('limit') limit = '50' (no max validation)
```

### 3. Spawn or inline?

Before writing a prompt, answer these. The first yes kills the spawn.

| Question | If yes → |
|---|---|
| Can this be answered with at most a couple of inline searches or reads? | Inline |
| Is the target file already known? | Inline |
| Will the result inform the very next tool call? | Inline |
| Is the task open-ended or exploratory with no shape? | Reshape first |
| Will the parent re-read the same files to verify the output? | Inline |

Positive signals for spawning:
- Work spans many files across a subsystem not yet in the parent's context
- Scoped audit on one dimension of one folder
- Genuinely cross-cutting research where the answer is a summary, not an edit
- Can be stated as a specific question with a bounded output shape

If none apply, go inline.

### 4. How many agents?

The default is one. Fan out only when all three hold:

1. Independent work — one agent's findings do not alter another's scope
2. Disjoint scope — no two agents search the same files or patterns
3. Uniform output shape — results combine without a reconciliation step

Any failure of the three: one agent, or go inline.

| Work shape | Agents |
|---|---|
| Find one fact | 1 (usually inline) |
| Scoped audit on one dimension of one folder | 1 |
| Audit across many dimensions | N, one per disjoint dimension partition |
| Identical lookup across N disjoint folders | N (diminishing returns above ~4) |
| Research across a dependency graph where each finding narrows the next question | 1 (serial) |
| "Verify everything is fine" | 0 — not delegable; reshape or abandon |

### 5. Warmth scoring

A prompt is warm when a fresh instance could answer it using only what is in the prompt. Score it as a sanity check.

| Signal | Value |
|---|---|
| Labeled section (GOAL, CONTEXT, SCOPE, TASK, OUTPUT, DELIVERABLE, BUDGET) | 1 each |
| Code fence with pasted content | 1 |
| File path reference with optional line number | 1 each (cap 2) |

| Prompt length | Required score |
|---|---|
| < 400 tokens | 0 |
| 400–1500 tokens | 2 |
| ≥ 1500 tokens | 3 |

If the prompt fails the warmth test, add what is missing before spawning — not after.

### 6. Brief template

```
GOAL
  <one sentence: the specific answer required>

CONTEXT (what the parent already has — do not rediscover)
  - <path/file:line> — <pasted excerpt or one-line summary>
  - <fact> — <source>
  - <exclusions> — <paths the subagent must not investigate>

SCOPE
  - In: <paths or patterns>
  - Out: <explicit exclusions>

TASK
  <verb-first instruction>

OUTPUT
  <return shape — table, bullet list, word budget, line-ref list, etc.>
  <how the parent will verify the result>

BUDGET (optional)
  <tool-call cap or time limit>
```

## Anti-patterns

1. **Delegating understanding.** Spawn for findings; decide inline; edit or spawn narrowly for the fix.
2. **Unbounded brief.** A prompt with no goal, scope, or output shape causes the subagent to invent all three.
3. **Exploration without reshaping.** Replace open-ended prompts with a specific enumerated read set and shaped summary output.
4. **Spawn for trivial work.** Round-trip plus cold start costs more than a direct inline call.
5. **Overlapping parallel agents.** Agents with intersecting scope duplicate their work.
6. **Spawn then re-verify manually.** Re-reading the same files the subagent read is paying twice, not delegating.
7. **Name-drop brief.** Referring to a file by path instead of pasting the relevant excerpt forces the subagent to re-read context the parent already has.
8. **Trusting prose over evidence.** Accepting "I verified it and it's fine" without file:line evidence is not verification.

## Verification Commands

- Read the brief back before spawning. If the task cannot be completed using only what is in the prompt, neither can the subagent.
- After the subagent returns, verify outputs against the OUTPUT section criteria using Read or Grep.

## Verdicts

- **SPAWN** — task is bounded, scope is disjoint, and prompt passes warmth test
- **INLINE** — task is small, target is known, or verification would re-read the same files
- **RESHAPE** — task is open-ended; define the read set and output shape before delegating
