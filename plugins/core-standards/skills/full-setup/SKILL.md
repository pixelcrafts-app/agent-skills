---
name: full-setup
description: One-command project setup. Run /full-setup in any project — new or existing. Detects stack and domain, generates the complete project layer (CLAUDE.md, .claude/rules/, agent files, craft.json). After /full-setup, the project is ready for autonomous production development.
requires:
  - craft-config
  - planning
---

# Full Setup

Bridges the generic engine and a specific project: the engine gives universal rules; this generates the project layer (THIS codebase, domain, quality bar). Trigger `/full-setup "<goal>"` for a new project, or `/full-setup` with no args inside an existing one (reads code to derive context).

## Step 1 — Detect stack

Read in order: `pubspec.yaml`→Flutter · `package.json` (`next`→Next.js, `@nestjs/core`→NestJS, else Node) · `build.gradle`→Android · `go.mod`→Go · `Cargo.toml`→Rust · `requirements.txt`/`pyproject.toml`→Python · `*.xcodeproj`/`Package.swift`→iOS. Pack per stack: Flutter→`flutter-standards`+`mobile-standards` · Next.js→`web-standards` · NestJS→`api-standards` · RN→`mobile-standards` · always `core-standards`. Web+api → `cross-stack-contracts`.

## Step 2 — Detect domain (existing projects)

Read `src/` structure, key model/entity files, existing test patterns, README. New projects: use the description.

## Step 3 — Generate project layer (preserve existing files; generate only what's missing)

**`CLAUDE.md`** (project root):
```markdown
# <Project Name>
## What this is   <2–3 sentences: app, audience, platform>
## Stack          <detected stacks + key deps>
## Autonomous pipeline (mandatory order)
1 spec-validator → 2 contracts → 3 contract-tests → 4 implementer (fix cap 3) →
5 challenger (blocks on critical) → 6 integration (fix cap 5) → 7 reviewer (approves or gaps)
## Definition of done
Task: contract tests pass · unit tests pass · no TODO/FIXME · verify-changes passes · progress.md = contract-tests-passing
Feature: acceptance tests pass · reviewer APPROVED · no open WARNs
## Honesty contract
Evidence before any claim (cite path:line or read it now); run the verification command before saying fixed/done — the runner is truth, not your diff. Full rules: core-standards:honesty.
## Key conventions   <file naming, module structure, error format>
## Current milestone  <filled by /spec>
```

**`.claude/rules/domain.md`** — Core entities (+ invariants) · Business rules (not in generic packs) · Key constraints (perf/platform/integration). Derive from description (new) or detected models (existing).

**`.claude/rules/quality.md`** — Performance budget · Test coverage (logic→unit, endpoints→contract, criteria→acceptance) · Platform requirements · Error handling shape.

**`.claude/agents/`** (5 files):
- **orchestrator** — coordinates the pipeline; reads CLAUDE.md/spec/acceptance/contracts/progress; decision tree (spec not locked→stop; contracts missing→architect+challenger+approval; tests missing→Test Writer; impl incomplete→one implementer per contract; all passing→Integration Challenger→integration; integration done→reviewer; APPROVED→done; GAP→new tasks). Writes tasks via TaskCreate. Never writes code.
- **implementer** — one contract at a time; reads contract + contract tests (=done); implement→pass→run fast tests per write→unit tests→fix cap 3 then escalate to progress.md (BLOCKED). Cannot modify contracts/`tests/contracts/`, write out of scope, or skip/delete failing tests.
- **challenger** — fresh context; `Read core-standards:challenger` for protocol; prioritize project-specific failure modes (from domain.md); ask the 3 questions; return BLOCK/WARN/INFO; never suggest alternatives or modify files.
- **reviewer** — fresh context; reads locked spec/acceptance/contracts + progress + git diff; one question: "do all acceptance tests pass AND cover every spec criterion?" YES→APPROVED (`status: done`), NO→list each gap as a new task. Don't review style/internals/anything not in spec.
- **integration** — `Read core-standards:integration` for protocol; project test commands + contract dependency graph.

## Step 4 — Config

**`craft.json`**: `{ "stacks":[<detected>], "features":{ "auth":<detected>, "realtime":<detected>, "i18n":<detected>, "payments":false }, "disabled_rules":[] }`.
**`.gitignore`** additions (session artifacts, never commit): `.claude/audit-cache.json`, `.claude/progress.md`, `.claude/verify-state.json`.

## Step 5 — Output

Summary of stack, packs, and generated files; then "Run `/spec \"<goal>\"` to begin, or `/parallelize` for fan-out." If the project later commits to an aesthetic, see `core-standards:craft-config` `features.aesthetic`.

## Preservation rules

Never overwrite an existing file — generate only what's missing. `craft.json` exists → merge detected stacks, don't replace keys. Agent files exist → keep, add only missing. `CLAUDE.md` exists → append a `## agent-skills pipeline` section, don't replace.
