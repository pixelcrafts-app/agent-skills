# agent-skills

Harness-agnostic standards, skills, and rules for AI coding agents — write a standard once, deploy it to every tool.

Works with **Claude Code, Cursor, OpenAI Codex, Gemini CLI, and Kimi Code CLI.**

![version](https://img.shields.io/badge/version-0.17.0-blue) ![license](https://img.shields.io/badge/license-MIT-green)

> Community project. Not affiliated with Anthropic, OpenAI, Google, or any harness vendor.

---

## The Problem

Every AI coding tool wants its standards in a different place and format — Claude reads plugins, Cursor reads `.cursor/rules`, Codex reads `AGENTS.md`, Gemini reads `GEMINI.md`, Kimi reads `~/.kimi/skills`. Maintain them separately and they drift.

**agent-skills solves this:** one source of truth (`skills/`), deployed to every harness by one command. Edit a skill once; every tool stays in sync.

---

## How It Works

```
                  skills/<category>/<name>/SKILL.md      ← single source (63 skills · 59 portable + 4 Claude-only)
                                 │
        ┌───────────┬───────────┼───────────┬──────────┐
     generate     export      export      export     install
        ▼           ▼           ▼           ▼          ▼
   .claude-plugin/ .cursor/   AGENTS.md   GEMINI.md   ~/.kimi/
   + plugins/      rules/     (codex)     (gemini)    skills/
   (claude)
```

- **Static export** (Cursor, Codex, Gemini) — strips each `SKILL.md` to its body and writes the harness's rules/context file into your project.
- **Plugin generate** (Claude) — `scripts/build-claude.sh` builds an installable plugin marketplace from `skills/`.
- **Install** (Kimi) — `install.sh` builds the Kimi skill set from `skills/` (via `build-kimi.sh`) and copies it into `~/.kimi/skills/`.

`skills/` holds two kinds of category: **portable** (`core`, `api`, `web`, `mobile`, `flutter`, `design`) exported to every harness, and **`claude/`** — Claude-only skills (slash commands, `/compact`, context budget) that ship only in the Claude plugins.

> **Content reuse, not behavioral parity.** Every harness receives all 59 portable skill texts, but a skill's *behavior* depends on the harness's capabilities. Skills that rely on sub-agents, slash commands, or state files (e.g. the autonomous pipeline) are richer on Claude Code and act as plain guidance on simpler harnesses. See [docs/harnesses/cross-model-compatibility.md](docs/harnesses/cross-model-compatibility.md).

---

## Quick Start

One entrypoint deploys to any harness:

```bash
./scripts/deploy.sh <harness> [target-project-path] [pack]
```

| Harness | Command | Produces |
|---------|---------|----------|
| **Claude Code** | `/plugin marketplace add pixelcrafts-app/agent-skills` then `/plugin install core-standards@pixelcrafts` | plugins (skills + slash commands) |
| **Cursor** | `./scripts/deploy.sh cursor ~/my-app [pack]` | `.cursor/rules/*.mdc` |
| **OpenAI Codex** | `./scripts/deploy.sh codex ~/my-app [pack]` | `AGENTS.md` |
| **Gemini CLI** | `./scripts/deploy.sh gemini ~/my-app [pack]` | `GEMINI.md` |
| **Kimi Code CLI** | `./scripts/deploy.sh kimi` | `~/.kimi/skills/` |

`pack` is one of `all` (default), `core`, `api`, `web`, `mobile`, `flutter`, `design`. Prefer a specific pack — `all` concatenates every skill into one large file.

---

## Skills

63 skills — 59 portable (exported to every harness) plus 4 Claude-only:

| Pack | Count | Exported to | Covers |
|------|-------|-------------|--------|
| `core` | 22 | all | planning, verification, honesty, contracts, subagent briefs, universal rules, external-tools |
| `web` | 13 | all | Next.js, craft-guide, premium-signals, production-readiness |
| `flutter` | 9 | all | engineering, forms, performance, accessibility, observability |
| `api` | 6 | all | NestJS, api-design, db-migrations, websockets |
| `design` | 5 | all | design-laws, accessibility, information-architecture |
| `mobile` | 4 | all | cross-platform craft, design-tokens, premium-signals |
| `claude` | 4 | Claude only | full-setup, context-budget, strategic-compact, docs-sync |

See [docs/skills/catalog.md](docs/skills/catalog.md) for the full list and when each fires.

---

## Maintaining It

The single source is `skills/`. After editing any `SKILL.md`:

```bash
./scripts/build-claude.sh          # regenerate the Claude plugin marketplace
./scripts/build-kimi.sh            # regenerate the Kimi skill set
./scripts/deploy.sh <harness> ...  # re-export to any project that consumes it
```

`.claude-plugin/` and `plugins/` are **committed generated artifacts** (GitHub serves them to the plugin marketplace) — never hand-edit; regenerate and commit. `harnesses/kimi/skills/` is also generated but **gitignored** — it's rebuilt by `install.sh` on each install, so it never clutters the tree.

> **Kimi note:** the Kimi skill set is generated from `skills/`. Six skills are hand-tuned for Kimi and kept as authored overrides in `harnesses/kimi/overrides/`, which win over generation.

---

## Folder Structure

```text
agent-skills/
├── skills/              # single source of truth — every standard is a SKILL.md
│   ├── core/ api/ web/ mobile/ flutter/ design/   # portable — exported everywhere
│   └── claude/          # Claude-only skills (ship only in Claude plugins)
├── harnesses/           # per-harness adapters — machinery only, NO skills
│   ├── claude/          # plugin manifest templates (skills delivered as plugins)
│   ├── cursor/  codex/  gemini/   # export.sh per harness
│   └── kimi/            # install.sh + overrides/ (authored Kimi adaptations)
├── scripts/
│   ├── deploy.sh        # single entrypoint → any harness
│   ├── build-claude.sh  # generate Claude plugin marketplace from skills/
│   ├── build-kimi.sh    # generate full Kimi skill set from skills/
│   └── export.sh        # master export delegator
├── plugins/             # GENERATED — Claude plugins built from skills/
├── .claude-plugin/      # GENERATED — Claude marketplace front door
└── docs/                # setup per harness, skill authoring, architecture
```

---

## Contributing

See [docs/skills/contributing.md](docs/skills/contributing.md). Author skills in `skills/` only — adapters and plugins regenerate from there.

---

## License

MIT
