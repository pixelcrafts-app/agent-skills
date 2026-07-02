# agent-skills

**Teach your AI coding agent new skills.**

A *skill* is one Markdown file that hands your agent a real capability — how to build a production UI, design an API that holds up, plan before it codes, or check its own work instead of guessing. Drop it in, and the agent just knows how to do that job — your way, every time.

64 skills ready to use. Writing your own is one file.

![version](https://img.shields.io/badge/version-0.19.0-blue) ![license](https://img.shields.io/badge/license-MIT-green)

> Community project. Not affiliated with Anthropic, OpenAI, Google, or any harness vendor.

---

## What you're actually giving it

Without skills, your agent runs on generic instincts — it builds a screen with no loading state, writes an endpoint with no auth check, and says "done" without running anything. A skill replaces that guesswork with know-how. A few of the 64:

- **When it builds UI** — it now handles loading / empty / error / content on every screen, uses your design tokens instead of hardcoded values, and passes contrast.
- **When it writes an API** — auth on every endpoint, validated input, no leaked secrets, typed errors, cursor pagination.
- **On any task** — it plans before it codes, runs the test *before* claiming "done," and cites `file:line` for what it tells you.
- **Specialist knowledge on tap** — Next.js, NestJS + Prisma, Flutter, cross-platform mobile, and design craft, each as its own skill the agent loads only when it's relevant.

The payoff is code that's ship-ready instead of demo-ready. The skills are *how* you get there — and you can edit any of them, or add your own, because each is just a Markdown file you control.

---

## Use them in whatever tool you're in

A skill is just Markdown, so the same one works across **Claude Code, Cursor, Codex, Gemini, and Kimi**. Write a skill once; it follows you between tools instead of living in five different config files that slowly drift apart.

---

## Get started — pick your tool

| Your tool | Run this | What happens |
|-----------|----------|--------------|
| **Claude Code** | `/plugin marketplace add pixelcrafts-app/agent-skills` then `/plugin install core-standards@pixelcrafts` (+ a stack pack) | Skills auto-load when they're relevant |
| **Cursor** | `./scripts/deploy.sh cursor ~/my-app [pack]` | Writes `.cursor/rules/*.mdc` |
| **OpenAI Codex** | `./scripts/deploy.sh codex ~/my-app [pack]` | Writes `AGENTS.md` |
| **Gemini CLI** | `./scripts/deploy.sh gemini ~/my-app [pack]` | Writes `GEMINI.md` |
| **Kimi** | `./scripts/deploy.sh kimi` | Installs to `~/.kimi/skills/` |

`pack` is `all` (default) or one of `core`, `api`, `web`, `mobile`, `flutter`, `design` — pick the one that matches your project. That's the whole setup.

---

## The skills — 64 of them

Each skill is a focused `SKILL.md` your agent loads when it's relevant. To show what "a skill" actually means — **`code-quality`** (api) alone holds your agent to: every route guarded or explicitly `@Public`, DTOs validated, zero `as any`, no `console.log` in feature code, tests for the happy path *and* auth/validation failures — then a Detect→Check→Suggest pass on rate limiting, idempotency, webhook verification, graceful shutdown, health endpoints, and DB-pool sizing. That's **one** of 64.

### web (13) — Next.js + Tailwind + shadcn
- **nextjs** — App Router, Server Components by default, RSC/client boundary pushed deep, structured React Query keys, RHF + Zod, no barrel files, no `any`/`as`
- **craft-guide** — the design-system contract (§0–§15): color + contrast + harmony, spacing rhythm, type scale, motion, every UI state, theme discipline
- **craft-invariants** — WCAG / CSS / Bringhurst universals, PASS/FAIL
- **premium-signals** — exact market values (2-layer shadows, OKLCH dark-gray scale, expo-out easing, tabular-nums)
- **taste**, **performance**, **production-readiness** (§R1–R10), **i18n**
- commands: `/pre-ship` `/premium-check` `/extract-tokens` `/theme-audit` `/aesthetic-coherence`

### flutter (9)
- **engineering** (DRY, single source of truth, data pipeline), **accessibility** (Semantics, contrast, 48dp targets, text scaling), **performance** (16ms frame budget, isolates, decode-at-size), **forms**, **observability** (one logger, PII discipline) — commands: `/app-audit` `/scaffold` `/scan`

### api (6) — NestJS + Prisma
- **nestjs** (thin controllers → services → repos, validated DTOs), **code-quality** (the audit above), **api-design** (REST semantics, pagination, errors), **cross-stack-contracts**, **websockets**, **db-migrations**

### mobile (4) — Flutter / RN / SwiftUI / Compose
- **craft-guide** (IA, density, navigation continuity), **craft-invariants** (HIG/Material/60fps, PASS/FAIL), **design-tokens** (per-framework violation patterns), **premium-signals** (iOS 26 / Material You exact values)

### design (5) — platform-agnostic
- **design-laws** (perceptual color, type scale + anti-AI-slop tests), **accessibility** (WCAG 2.2 across Web/iOS/Android), **information-architecture**, **brand-research**, **creative-direction**

### core (22) — the cross-stack engine, applies everywhere
- **how the agent works**: planning (route + plan before code), verification & verify-changes (adversarial, tool-evidence required), honesty (cite `file:line`, run the test before "done"), subagent-brief, universal-rules, external-tools
- **autonomous pipeline**: spec-validator → contracts → contract-tests → integration → challenger (each phase locked before the next)
- plus auth-flows, hexagonal-architecture, docker-patterns, codebase-onboarding, ADRs, state-files, craft-config

### claude (4) — Claude-only
- `/full-setup` (bootstrap a project), context-budget, strategic-compact, docs-sync

Every skill, with when each fires → **[docs/skills/catalog.md](docs/skills/catalog.md)**.

---

## How it works

Every skill lives once in `skills/`. One command turns it into the format each tool reads — edit a skill, re-run, every tool stays in sync.

```
                  skills/<category>/<name>/SKILL.md      ← one source (64 skills)
                                 │
        ┌───────────┬───────────┼───────────┬──────────┐
     Claude        Cursor       Codex       Gemini      Kimi
     plugins      .cursor/     AGENTS.md   GEMINI.md   ~/.kimi/
                   rules/                              skills/
```

Each tool gets the same skill text; how strictly it's applied depends on the tool (Claude Code is the richest — sub-agents, slash commands, state; the others read skills as guidance). Details → [docs/harnesses/cross-model-compatibility.md](docs/harnesses/cross-model-compatibility.md).

---

## Maintaining & contributing

Edit only `skills/` (the single source), then regenerate:

```bash
./scripts/build-claude.sh                  # Claude plugin marketplace
./scripts/build-kimi.sh                    # Kimi skill set
./scripts/deploy.sh <harness> ~/project    # re-export to a project
```

`.claude-plugin/` + `plugins/` are committed generated files (GitHub serves them to the marketplace) — never hand-edit. Adding or changing a skill? → **[docs/skills/contributing.md](docs/skills/contributing.md)**.

```text
skills/        the skills — one SKILL.md each (edit here)
harnesses/     per-tool adapters — machinery only, no skills
scripts/       deploy.sh + build-claude.sh / build-kimi.sh
plugins/ + .claude-plugin/   GENERATED — the Claude marketplace
docs/          setup per tool, the full catalog, architecture
```

---

## License

MIT
