---
name: verify-changes
description: Apply when the user asks to verify or audit a set of changes across any stack.
triggers:
  - "verify my changes"
  - "cross-check before confirming"
  - "audit what I did"
  - "is everything fine?"
  - Before a commit or PR
scope: Any set of changed files in any codebase
outputs: A consolidated verification report with pass/fail findings and a SAFE/BLOCK verdict
---

# Verify Changes

> Cross-stack verification workflow. Works on web, mobile, API, DB. Reads the installed skill standards and applies them to changed files. Pure prompt workflow — no persistent state, no execution hooks, no external infrastructure.

## When to Apply

- User asks to verify or audit changes
- End of a feature branch before PR
- After a batch of edits across multiple files
- Before user says commit, push, or ship

## Must-Do Checklist

- [ ] Confirm scope, dimensions, and depth with the user
- [ ] List changed files using git status or the user's provided list
- [ ] Build the dependency graph to find consumers
- [ ] Run project tools (type-check, lint, tests) scoped to changes
- [ ] Apply relevant skill rules in batches
- [ ] Cite file:line evidence for every finding
- [ ] Produce a consolidated report with a verdict

## Rules

### 1. Scope dialogue

Ask three questions. Do not guess.

**Scope of changes**

```
Which changes do I verify?
  a) Uncommitted working tree
  b) Last N commits on this branch
  c) A specific file or folder
  d) A feature / named area
  e) All of the above
```

**Dimensions to cover**

```
Which dimensions?
  a) ALL — every applicable standard
  b) Specific dimensions (craft, engineering, a11y, perf, testing, security, docs, ...)
  c) SMART — auto-pick based on what changed
```

**Depth**

```
How deep?
  a) Direct only
  b) Direct + consumers
  c) Full ripple
```

Default to uncommitted working tree, SMART dimensions, direct + consumers if the user says "just go." Echo the defaults before proceeding.

### 2. List changed files

- Uncommitted: `git status --short` + `git diff --name-status`
- Last N commits: `git log -n <N> --name-status --pretty=format:`
- Specific path: Glob
- No git repo: ask the user for the file list

Interpret git status codes:
- `M` — modified; verify against standards
- `A` — added; verify as a new file
- `D` — deleted; search codebase for remaining references
- `R` — renamed; check old path references and verify new file
- `??` — untracked; include if scope is uncommitted

Exclude build output: `node_modules/`, `dist/`, `build/`, `out/`, `coverage/`, lockfiles, binary assets, IDE clutter.

### 3. Build the dependency graph

For each changed file, find direct consumers using the stack's import/reference patterns. Union results across multiple passes.

Record the graph as:

```
<changed-file>
  → consumer-1
  → consumer-2
    → consumer-of-consumer (only if depth = full ripple)
```

### 4. Identify high-blast-radius changes

Flag any change that:
- Removed or renamed an exported symbol
- Changed a function signature
- Changed an ORM schema model
- Changed an environment variable name
- Modified a shared type (schema, DTO, shared interface)
- Touched a public API route path or method

These require every consumer verified, not a sample.

### 5. Run project tools first

Before applying skill rules, run the project's own tools. Use its manifest to detect commands.

- Type checker / analyzer: command from the manifest, scoped to changed files
- Linter: scoped to changed files
- Tests: only test files that map directly to changed files

Record results as authoritative where they apply. A tool FAIL for a concern cannot be overridden to PASS by judgment.

### 6. Apply standards in batches

Group work into batches by stack + dimension. Each batch should fit in one verification round.

For each batch:

1. Read only the files in the batch
2. Load only the relevant skill standard for that dimension
3. Iterate rule by rule. For every rule × file pair, produce:
   - Rule name
   - Evidence — direct quote with `path:line`, or `no occurrence`
   - Verdict — PASS, FAIL, N/A, INFO, REVIEW, or CONFLICT
   - Suggested fix — only on FAIL
4. Never skip a rule because it "seems unrelated" — record N/A with reason instead
5. Collect all failures; do not stop at the first FAIL

### 7. Stop conditions

Stop and report mid-run if:
- A hardcoded secret is found
- A protected route lost its auth or authorization check
- An env variable reference no longer exists
- A migration contains `DROP COLUMN` / `DROP TABLE` / a new `NOT NULL` without default
- A breaking public signature change will break a consumer
- You have found more dependencies than planned and are expanding scope uncontrollably

### 8. Optional fix loop

If the user asked to verify and fix:

1. Walk FAILs in priority order: critical first, then consumer breaks, then polish
2. Apply the smallest minimal fix
3. Re-verify only that rule × file pair
4. Track retries per pair; stop at 3 attempts and surface as stuck
5. Loop until all critical + consumer tasks pass or are stuck

## Report

```
Verification report — <date>
Scope: <what was covered>
Dimensions: <which standards>
Depth: <direct | direct+consumers | full ripple>

Totals
  Files in scope: X
  Files analyzed: X
  PASS: ...
  FAIL: ...

Critical failures (MUST FIX):
  [file:line — rule — evidence — suggested fix]

Polish failures (SHOULD FIX):
  [file:line — rule — evidence — suggested fix]

Consumer impact:
  [any consumer break]

Unverified / skipped:
  [any task that could not be run + reason]

Verdict:
  - 0 critical + 0 consumer-break → SAFE TO COMMIT
  - polish only → COMMIT IF DELIBERATE
  - any critical or consumer break → BLOCK
```

## Verification Commands

- `git status --short` / `git diff --name-status` — scope
- Project type-check / lint / analyze commands from manifest
- `grep -R "import.*<changed-symbol>" src/` — find consumers
- `grep -n "TODO\|FIXME\|HACK\|secret\|password" <changed-files>` — sweeps

## Verdicts

- **SAFE TO COMMIT** — 0 critical + 0 consumer-break failures
- **COMMIT IF DELIBERATE** — polish failures only
- **BLOCK** — any critical or consumer-break failure
