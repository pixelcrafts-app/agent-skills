---
name: subagent-brief
description: Read this before spawning any subagent. Governs when to spawn, how many agents, and what goes in the prompt.
triggers:
  - Before calling a subagent, Task tool, or delegated agent
  - Planning work that may span multiple files or domains
scope: All agent delegation
outputs: A warm, self-contained brief a fresh instance can execute without re-discovering context
---

# Subagent Brief Discipline

> Every delegated prompt must be **warm**: a fresh instance could complete it using only what's in the prompt. **Delegate lookups, scoped audits, narrow execution — never delegate understanding.**

## Spawn or inline? (first yes → don't spawn)

| Question | If yes |
|---|---|
| Answerable in a couple of inline searches/reads? | Inline |
| Target file already known? | Inline |
| Result informs the very next tool call? | Inline |
| Open-ended / no shape? | Reshape first |
| Parent will re-read the same files to verify? | Inline |

Spawn when: work spans many files not in context · scoped audit on one dimension/folder · cross-cutting research returning a summary (not an edit) · statable as a specific question with bounded output.

## How many agents (default 1)

Fan out only if all three hold: independent work · disjoint scope (no shared files/patterns) · uniform output shape (combine without reconciliation).

| Shape | Agents |
|---|---|
| Find one fact / scoped one-dimension audit | 1 (often inline) |
| Audit across many dimensions | N, one per disjoint dimension |
| Same lookup across N disjoint folders | N (diminishing returns >~4) |
| Findings narrow the next question | 1 (serial) |
| "Verify everything is fine" | 0 — reshape or abandon |

## Brief template (labeled sections mandatory)

```
GOAL     one sentence: the specific answer/outcome
CONTEXT  what the parent already knows — paste excerpts (path:line + the lines),
         don't name files for the subagent to re-read; list exclusions
SCOPE    In: <paths/patterns>   Out: <explicit exclusions>
TASK     verb-first instruction
OUTPUT   return shape (table/bullets/line-refs/word budget) + how the parent verifies
BUDGET   (optional) tool-call cap / time limit
```

**Excerpt contract:** if the parent already read a file, paste the relevant lines — never "see `src/auth/auth.controller.ts`". Naming a file makes the subagent pay again for context the parent has.

**Warmth check:** read the brief back — if you couldn't do the task from the prompt alone, neither can the subagent. Add what's missing *before* spawning. (Heuristic: ≥400-token prompts need labeled sections + pasted content + path:line refs.)

## Anti-patterns

Delegating understanding · unbounded brief (no goal/scope/output) · exploration without reshaping · spawning for trivial work (round-trip + cold start > inline) · overlapping parallel scopes · spawn-then-manually-re-verify (paying twice) · name-drop instead of paste · trusting "I verified it's fine" without `file:line`.

## Verdicts

- **SPAWN** — bounded, disjoint scope, prompt passes warmth check
- **INLINE** — small, target known, or verification would re-read the same files
- **RESHAPE** — open-ended; define the read set and output shape first
