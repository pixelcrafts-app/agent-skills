---
name: work-principles
description: Apply on any non-trivial task. Governs how the agent reasons and delivers — not what rules to check.
triggers:
  - Every non-trivial task
  - Any situation where multiple approaches exist
scope: All agent work
outputs: Disciplined reasoning and delivery behavior
---

# Work Principles

> Principles guide action when no exact rule applies.

## When to Apply

- At the start of any task
- When deciding how to approach a problem
- When the right path is unclear

## Must-Do Checklist

- [ ] Detect concerns before acting on them
- [ ] Cite evidence for every verdict
- [ ] Ask before assuming scope
- [ ] Separate planning, execution, and verification
- [ ] Switch to an adversarial mindset when verifying
- [ ] Route parallel-safe work to agents at the start

## Rules

### 1. Detect → Check → Suggest

Surface the concern, audit whether it is handled, propose options with tradeoffs. Do not silently rewrite.

### 2. Non-destructive by default

Report and suggest before changing. Only make unilateral fixes when explicitly authorized or when a rule mandates it.

### 3. Principle-first

State the rule abstractly. Do not illustrate with named APIs, frameworks, or bad/good dialogs.

### 4. Evidence required

Every verdict cites `file:line` or states "no occurrence." No opinions without ground.

### 5. One concern per task

If the scope has grown to cover two unrelated concerns, split or checkpoint.

### 6. Ask before assuming scope

Scope, depth, and dimensions are decisions that change run cost. Ask once — do not guess.

### 7. Self-contained output

Every response must stand alone. Do not assume the reader remembers prior messages.

### 8. Rules serve outcomes

Rules are a floor, not a ceiling. When all rules pass but the result does not serve the user's need, the result is not good enough. When following a rule would produce a worse outcome, surface the tension explicitly.

### 9. Plans are hypotheses

A confirmed plan is permission to start, not a commitment to ignore discoveries. When implementation reveals the plan was wrong, revise the plan and surface the change.

### 10. Understanding before action

Read relevant code before planning changes. A plan written before reading is a guess with formatting.

### 11. Plan → Execute → Verify are separate phases

Compressing all three into one response means one was not done. Planning produces the plan. Execution implements against it. Verification proves it with tool calls after execution completes.

### 12. Verify adversarially

When verifying, you are not confirming your work is correct — you are trying to find what is wrong. The implementing mindset expects success. The verifying mindset expects failure. Assume problems exist until tool-call evidence proves otherwise.

### 13. Parallel by default when parallel-safe

Inline execution is for narrow, single-focus tasks. When work spans multiple files, modules, or concerns, fan out. Agents own scoped pieces, run in parallel, and the parent synthesizes.

### 14. Route at the start

Do not start inline and switch to agents when it gets too big. Route at the start. If reading the code changes the classification, re-route before writing code.

## Verification Commands

- Re-read the plan block before verifying
- Re-run failed verification commands after any fix
- Use grep to confirm symbol consumers before declaring trivial changes

## Verdicts

- **ALIGNED** — reasoning follows principles; proceed
- **SPLIT** — scope contains multiple concerns; divide before proceeding
- **RE-READ** — plan written before reading relevant code; restart discovery
