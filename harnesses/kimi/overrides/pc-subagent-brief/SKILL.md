---
name: pc-subagent-brief
description: Apply whenever spawning an Agent or subagent. Use to write warm briefs that set context, scope, and output expectations. Triggers on any Agent tool call or when the user asks to delegate work to agents.
---

# Subagent Brief

Every agent spawn must include a warm brief with these sections:

## GOAL

One sentence. What the agent must produce or decide.

## CONTEXT

What the parent has already read, decided, or verified. Include file paths that are relevant. Do not make the agent re-discover what the parent already knows.

## SCOPE

- What is IN scope: specific files, modules, or decisions
- What is OUT of scope: boundaries the agent must not cross
- What is UNKNOWN: things the parent has not checked — the agent should investigate these

## OUTPUT

- Expected deliverable format: file edits, report, decision, code snippet
- Success criteria: how the parent will judge completion
- Where to write findings: if the agent discovers something important, state it explicitly in the return

## TRUST STATE FILES, NOT PROSE

If the project has state files (plan blocks, verification logs, etc.), reference them by path. Do not inline their contents — the agent will read them.

## Examples

**Good brief:**
```
GOAL: Find all call sites of `exchangeFirebaseToken` across the mobile-apps/ directory.

CONTEXT: We are migrating 5 Flutter apps from Firebase ID tokens to platform JWTs. 
The function `exchangeFirebaseToken` exists in pixelcrafts-sdk/flutter/auth. 
We need to know which apps call it and how.

SCOPE:
- IN: grep for `exchangeFirebaseToken` in ~/Documents/ash/GitHub/mobile-apps/*/
- IN: Read the call site context (3 lines before/after)
- OUT: Do not modify any files
- UNKNOWN: Whether any apps have already migrated

OUTPUT:
- Return a table: App | File | Line | Context snippet
- Flag any app that does NOT call the function
```

**Bad brief:**
```
Find where exchangeFirebaseToken is used.    ← No context, no scope boundary, no output format
```
