# agent-skills

**Teach your AI coding agent new skills.**

A *skill* is one Markdown file that hands your agent a real capability — how to build a production UI, design an API that holds up, plan before it codes, or check its own work instead of guessing. Drop it in, and the agent just knows how to do that job — your way, every time.

63 skills ready to use. Writing your own is one file.

![version](https://img.shields.io/badge/version-0.17.0-blue) ![license](https://img.shields.io/badge/license-MIT-green)

> Community project. Not affiliated with Anthropic, OpenAI, Google, or any harness vendor.

---

## What you're actually giving it

Without skills, your agent runs on generic instincts — it builds a screen with no loading state, writes an endpoint with no auth check, and says "done" without running anything. A skill replaces that guesswork with know-how. A few of the 63:

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

## The skills — 63 of them

| Pack | What the agent learns |
|------|-----------------------|
| **web** (13) | Next.js patterns, the craft-guide design system, premium signals, production-readiness, i18n |
| **flutter** (9) | Dart/widget engineering, forms, performance budgets, accessibility, observability |
| **api** (6) | NestJS + Prisma discipline, REST design, a code-quality audit, websockets, migrations |
| **mobile** (4) | Cross-platform craft, design tokens, precise iOS/Material values |
| **design** (5) | Design laws, WCAG 2.2, information architecture, brand research |
| **core** (22) | The engine — planning, verification, honesty, the spec→contracts→tests→integration pipeline, universal rules |
| **claude** (4) | Claude-only: `/full-setup`, context-budget, strategic-compact, docs-sync |

Browse every skill → **[docs/skills/catalog.md](docs/skills/catalog.md)**.

---

## How it works

Every skill lives once in `skills/`. One command turns it into the format each tool reads — edit a skill, re-run, every tool stays in sync.

```
                  skills/<category>/<name>/SKILL.md      ← one source (63 skills)
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
