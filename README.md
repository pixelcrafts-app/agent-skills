# agent-skills

You ask your AI agent to build a screen. It compiles — then you notice there's no loading state, the colors are hardcoded, an error just crashes the page, and the contrast fails. So you fix it by hand. Again.

**agent-skills fixes that.** It's a set of standards your agent reads *before* it writes — so you get code you'd actually ship, not demo code you have to rework. Write them once; they work in **Claude Code, Cursor, Codex, Gemini, and Kimi**.

![version](https://img.shields.io/badge/version-0.17.0-blue) ![license](https://img.shields.io/badge/license-MIT-green)

> Community project. Not affiliated with Anthropic, OpenAI, Google, or any harness vendor.

---

## What it actually does

By default, AI agents skip the boring-but-critical stuff. With agent-skills installed, your agent knows the bar and holds to it:

- **UIs that aren't just the happy path** — every screen handles loading / empty / error / content, uses design tokens instead of hardcoded values, and passes contrast.
- **APIs that survive production** — auth on every endpoint, validated input, no leaked secrets, typed errors. The things that bite you later, handled up front.
- **The "did you think about…" stuff, raised early** — rate limiting, error boundaries, logging, CSP. It surfaces them with trade-offs and lets *you* decide, instead of pretending they don't exist.
- **An agent you can trust** — it cites the `file:line` for what it claims, runs the test *before* it says "done," and plans before it codes. Less "trust me," more "here's the proof."

63 standards covering Next.js, NestJS, Flutter, mobile, and design — plus a stack-agnostic engine.

---

## The bigger headache it removes

Every tool wants your standards in a different place — Claude reads plugins, Cursor reads `.cursor/rules`, Codex reads `AGENTS.md`, Gemini reads `GEMINI.md`. Keep them in five places and they drift; copy-paste between tools and you've already lost.

Here you write a standard **once**, and one command pushes it wherever you work. Switch tools next month — your standards come with you.

---

## Get started — pick your tool

| Your tool | Run this | What happens |
|-----------|----------|--------------|
| **Claude Code** | `/plugin marketplace add pixelcrafts-app/agent-skills` then `/plugin install core-standards@pixelcrafts` (+ a stack pack) | Skills auto-load when they're relevant |
| **Cursor** | `./scripts/deploy.sh cursor ~/my-app [pack]` | Writes `.cursor/rules/*.mdc` |
| **OpenAI Codex** | `./scripts/deploy.sh codex ~/my-app [pack]` | Writes `AGENTS.md` |
| **Gemini CLI** | `./scripts/deploy.sh gemini ~/my-app [pack]` | Writes `GEMINI.md` |
| **Kimi** | `./scripts/deploy.sh kimi` | Installs to `~/.kimi/skills/` |

`pack` is `all` (default) or one of `core`, `api`, `web`, `mobile`, `flutter`, `design` — pick the one that matches your project. That's the whole setup; your agent now knows your standards.

---

## What's inside — 63 standards

| Pack | What it holds you to |
|------|----------------------|
| **web** (13) | Next.js patterns, the craft-guide design system, premium signals, production-readiness, i18n |
| **flutter** (9) | Dart/widget engineering, forms, performance budgets, accessibility, observability |
| **api** (6) | NestJS + Prisma discipline, REST design, a code-quality audit, websockets, migrations |
| **mobile** (4) | Cross-platform craft, design tokens, precise iOS/Material values |
| **design** (5) | Design laws, WCAG 2.2, information architecture, brand research |
| **core** (22) | The engine — planning, verification, honesty, the spec→contracts→tests→integration pipeline, universal rules |
| **claude** (4) | Claude-only: `/full-setup`, context-budget, strategic-compact, docs-sync |

See every one → **[docs/skills/catalog.md](docs/skills/catalog.md)**.

---

## How it works

One source of truth (`skills/`), one command to any tool. Edit a standard once; every tool stays in sync.

```
                  skills/<category>/<name>/SKILL.md      ← one source (63 standards)
                                 │
        ┌───────────┬───────────┼───────────┬──────────┐
     Claude        Cursor       Codex       Gemini      Kimi
     plugins      .cursor/     AGENTS.md   GEMINI.md   ~/.kimi/
                   rules/                              skills/
```

Each tool gets the *same standard text*; how strictly it's enforced depends on the tool (Claude Code is richest — sub-agents, slash commands, state; the others read the standards as guidance). Details → [docs/harnesses/cross-model-compatibility.md](docs/harnesses/cross-model-compatibility.md).

---

## Maintaining & contributing

Edit only `skills/` (the single source), then regenerate:

```bash
./scripts/build-claude.sh                  # Claude plugin marketplace
./scripts/build-kimi.sh                    # Kimi skill set
./scripts/deploy.sh <harness> ~/project    # re-export to a project
```

`.claude-plugin/` + `plugins/` are committed generated files (GitHub serves them to the marketplace) — never hand-edit. Want to add or change a standard? → **[docs/skills/contributing.md](docs/skills/contributing.md)**.

```text
skills/        the standards — one SKILL.md each (edit here)
harnesses/     per-tool adapters — machinery only, no standards
scripts/       deploy.sh + build-claude.sh / build-kimi.sh
plugins/ + .claude-plugin/   GENERATED — the Claude marketplace
docs/          setup per tool, the full catalog, architecture
```

---

## License

MIT
