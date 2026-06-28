# Cross-Model Compatibility Analysis

> Question: Does the generic `agent-skills` structure work automatically for every model — Claude, Kimi, Codex, Cursor, Aider?

**Short answer: No.**

The generic skill structure is a good single source of truth, but it does **not** work automatically across models. Each AI coding tool has different capabilities, and those differences are fundamental.

---

## What the Generic Structure Actually Solves

| Problem | Solved? |
|---------|---------|
| One place for all standards | ✅ Yes |
| Avoid duplicating rules per harness | ✅ Yes |
| Easy to add new skills | ✅ Yes |
| Easy to see what each skill does | ✅ Yes |
| Same behavior across all tools | ❌ No |

The value is **content reuse**, not **behavioral parity**.

---

## Capability Matrix

| Capability | Claude Code | Kimi Code CLI | Cursor | Codex | Aider |
|------------|-------------|---------------|--------|-------|-------|
| Bash hooks (PreToolUse / PostToolUse / Stop) | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |
| Slash commands | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |
| Plugin marketplace | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |
| State files / audit cache | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |
| Multi-agent orchestration | ✅ Yes | ⚠️ Limited | ❌ No | ❌ No | ❌ No |
| Per-project config directory | `.claude/` | `.kimi/` | `.cursor/` | none | `.aider/` |
| Global skill install | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| Static rules export | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Natural language triggers | ✅ Yes | ✅ Yes | ⚠️ Partial | ⚠️ Partial | ⚠️ Partial |
| Deterministic enforcement | ✅ Yes | ❌ No | ❌ No | ❌ No | ❌ No |

---

## What Works Automatically

These things work with minimal adaptation:

1. **Skill content reuse** — the same markdown instructions can be copied to any harness.
2. **Rule semantics** — PASS/FAIL/INFO tiers are understood by any LLM if prompted clearly.
3. **Project identity** — project name, stack, boundaries can be expressed in any format.
4. **End-of-task checks** — "run tests before finishing" works in any tool if included in instructions.
5. **Coding standards** — naming, structure, patterns are universal concepts.

---

## What Does NOT Work Automatically

### 1. Bash Hooks
**Claude-only.**

Hooks like `protect-files.sh`, `post-test.sh`, `cite-or-read.sh` run because Claude Code exposes a bash lifecycle (PreToolUse, PostToolUse, Stop). No other tool exposes these events.

**Impact:**
- Kimi cannot block edits to `.env`
- Cursor cannot auto-run tests after every edit
- Codex cannot enforce a turn-end citation check

**Workaround:**
- Rely on skill-based discipline
- Add explicit manual verification steps
- Use CI/CD for enforcement instead of tool hooks

### 2. Slash Commands
**Claude-only.**

`/verify-changes`, `/full-setup`, `/spec`, `/parallelize` are Claude command system features.

**Impact:**
- Other tools require natural language triggers: "verify my changes", "set up this project", "validate the spec"
- Users may not know the trigger phrases
- No guaranteed routing to the right skill

**Workaround:**
- Document natural language triggers per harness
- Use `.kimi/AGENTS.md` to tell Kimi what phrases to watch for
- Cursor rules are static, so triggers don't apply

### 3. State Files
**Claude-only.**

`.claude/agent-traffic.log`, `.claude/verify-state.json`, `.claude/audit-cache.json` rely on Claude being able to read/write project-local state across turns.

**Impact:**
- No persistent audit cache in Kimi
- No agent traffic logging in Cursor
- Cannot skip unchanged files on repeat audits

**Workaround:**
- Re-read files each time (higher token cost)
- Use git status/diff to detect unchanged files
- Accept that non-Claude tools are less stateful

### 4. Multi-Agent Orchestration
**Claude-best, others limited or none.**

The autonomous pipeline (`spec-validator → contracts → contract-tests → integration → challenger`) depends on spawning subagents with warm briefs and observing their output.

**Impact:**
- Kimi has Agent/Task/Explore tools but no hook observation
- Cursor has Composer but different semantics
- Codex/Aider are single-agent

**Workaround:**
- Run the pipeline as a single long prompt
- Break into manual phases
- Accept lower autonomy on non-Claude tools

### 5. MCP Integration
**Claude-specific protocol.**

Model Context Protocol servers are a Claude Code convention.

**Impact:**
- Skills referencing MCP (e.g., Figma, GitHub) won't work elsewhere
- Kimi may have its own tool protocol later

**Workaround:**
- Mark MCP-dependent skills as Claude-only
- Provide fallback instructions for other tools

---

## Per-Harness Reality

### Claude Code
- **Best experience.** Full hooks, slash commands, state, multi-agent.
- Gets 100% of what `agent-skills` can offer.

### Kimi Code CLI
- **Good for pure skill instructions.**
- Loses: hooks, slash commands, state files, deterministic enforcement.
- Gains: simpler setup (one `AGENTS.md` per project).
- Requires: Kimi-adapted skills that remove Claude-specific references.

### Cursor
- **Static rules only.**
- Gets: design system rules, code style, architecture guidelines.
- Loses: everything dynamic (hooks, verification loops, state).
- Cursor Rules v2 are applied based on file globs — no runtime reasoning.

### OpenAI Codex / SWE
- **Single-file instructions.**
- Gets: a long `AGENTS.md` with all rules.
- Loses: structured skill loading, hooks, commands, state.
- The agent may ignore parts of the instructions in long sessions.

### Aider
- **Convention files.**
- Gets: coding conventions and review checklists.
- Loses: all dynamic enforcement.

---

## What This Means for the Product

### The Generic Structure Is Worth It
Because:
- One place to maintain rules
- Easy to port to new harnesses
- Clear documentation of what works where

### But "Works Automatically" Is False Marketing
You cannot claim that `agent-skills` works the same across all tools. The honest positioning is:

> **"One source of truth for agent standards, adapted to each tool's capabilities."**

### Recommended Messaging

| Don't Say | Do Say |
|-----------|--------|
| "Works with every AI model" | "Skills are portable; capabilities depend on the harness" |
| "Automatic across Claude, Kimi, Cursor" | "Claude gets full hooks; Kimi gets pure skills; Cursor gets exported rules" |
| "Same behavior everywhere" | "Same standards, adapted delivery" |

---

## Recommended Next Steps

1. **Keep skills harness-agnostic** — continue the generic structure.
2. **Maintain per-harness adapters** — one adapter per supported tool.
3. **Document limitations honestly** — every harness guide should say what is lost.
4. **Invest in Kimi** — it is the closest to Claude in terms of skill loading.
5. **Deprioritize Cursor/Codex/Aider parity** — static export is good enough.
6. **Do not promise automatic behavior** — promise content reuse + best-effort adaptation.

---

## Verdict

| Claim | Verdict |
|-------|---------|
| Generic structure improves maintainability | ✅ True |
| Generic structure enables multi-harness support | ✅ True |
| Generic structure works automatically for every model | ❌ False |
| Each harness gets the best experience its platform allows | ✅ True, with explicit adapters |

**Bottom line:** Build the generic skill library, but market it as "standards with harness-specific adapters," not "universal automatic AI behavior."
