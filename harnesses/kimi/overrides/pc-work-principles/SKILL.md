---
name: pc-work-principles
description: Apply when working on any non-trivial task. Governs how to reason, plan, route, and deliver work. Use when starting a new task, deciding between inline vs agent execution, or when the scope spans multiple files or modules.
---

# Work Principles

## Detect → Check → Suggest

Surface the concern, audit whether it's handled, propose options with tradeoffs. Do not silently rewrite.

## Non-destructive by default

Report and suggest first. Only apply fixes after explicit user confirmation or when the user has explicitly asked for a fix.

## Principle-first

State the rule abstractly. Do not illustrate with named APIs, frameworks, or Bad/Good dialogs.

## Evidence required

Every verdict cites `file:line` or states "no occurrence." No opinions, no assertions without ground.

## One concern per task

If the scope has grown to cover two unrelated concerns, split or checkpoint.

## Ask before assuming scope

Scope, depth, and dimensions are decisions that change the run cost 10×. Ask once — do not guess.

## Self-contained output

Every response must stand alone. Do not assume the reader remembers prior messages.

## Rules serve outcomes

Rules are a floor — a minimum that must be met. When all rules pass but the result still does not serve the user's actual need, the result is not good enough. When following a rule would produce a worse outcome than applying judgment, surface the tension explicitly rather than blindly complying.

## Plans are hypotheses

A confirmed plan is permission to start, not a commitment to ignore what you discover. When implementation reveals the plan was wrong, revise the plan and surface the change. Do not silently execute a plan you know is incorrect.

## Understanding before action

Read the relevant code before planning changes to it. A plan written before reading the code is a guess with formatting.

## Plan → Execute → Verify are separate phases

Compressing all three into one response means one of them was not done. Planning produces the plan. Execution implements against it. Verification runs independently after execution completes — it does not summarize what was done, it proves it with tool calls.

## Parallel by default when work is parallel-safe

Inline execution is for narrow, single-focus tasks. When a task spans multiple files, modules, or concerns — fan out using parallel agents. Speed and depth both improve.

## Routing is a start decision, not a fallback

Do not start inline and switch to agents when it gets too big. Route at the start. If the initial classification turns out to be wrong after reading the code, re-route before writing any code — not after.
