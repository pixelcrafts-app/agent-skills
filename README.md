# agent-skills

Harness-agnostic standards, skills, and rules for AI-assisted software development.

Works with Claude Code, Kimi Code CLI, Cursor, OpenAI Codex, and Aider.

![version](https://img.shields.io/badge/version-0.17.0-blue) ![license](https://img.shields.io/badge/license-MIT-green)

---

## What This Is

A single source of truth for reusable AI agent standards:

- **Core skills** — planning, verification, honesty, subagent briefs, universal rules
- **Stack skills** — web, API, mobile, Flutter, design
- **Harness adapters** — how each AI tool consumes the same skills

The skills are written to be harness-agnostic. Claude gets hooks and slash commands. Kimi gets global skills and `AGENTS.md`. Cursor gets `.cursor/rules`. Codex and Aider get exported convention files.

---

## Supported Harnesses

| Harness | Setup | Mechanism |
|---------|-------|-----------|
| Claude Code | [docs/agents/claude.md](docs/agents/claude.md) | Plugins, bash hooks, slash commands |
| Kimi Code CLI | [docs/agents/kimi.md](docs/agents/kimi.md) | `~/.kimi/skills/` + `.kimi/AGENTS.md` |
| Cursor | [docs/agents/cursor.md](docs/agents/cursor.md) | `.cursor/rules/*.mdc` |
| OpenAI Codex | [docs/agents/codex.md](docs/agents/codex.md) | `AGENTS.md` |
| Aider | [docs/agents/aider.md](docs/agents/aider.md) | `.aider/conventions.md` |

---

## Folder Structure

```text
agent-skills/
├── AGENTS.md                 # Generic entry point
├── README.md                 # This file
├── agent.yaml                # Harness-agnostic manifest
├── skills/                   # Reusable, harness-agnostic skills
│   ├── core/                 # work-principles, planning, verification, honesty, ...
│   ├── api/                  # nestjs, api-design, db-migrations, websockets, ...
│   ├── web/                  # nextjs, craft-guide, premium-signals, aesthetic-coherence, ...
│   ├── mobile/               # cross-platform mobile standards
│   ├── flutter/              # Flutter-specific skills (engineering, forms, observability, production-readiness, ...)
│   └── design/               # design-laws, accessibility, information-architecture, ...
├── harnesses/                # Per-harness adapters
│   ├── claude/               # .claude/, hooks, commands, plugin metadata
│   ├── kimi/                 # install.sh, .kimi/AGENTS.md.template
│   ├── cursor/               # export.sh
│   ├── codex/                # export.sh
│   └── aider/                # export.sh
├── docs/
│   ├── agents/               # Setup guide per harness
│   ├── skills/               # Skill authoring and catalog
│   └── harnesses/            # Architecture notes per harness
└── scripts/                  # Generic tooling
```

---

## Core Principles

1. **Skills own all knowledge.** Every standard lives in a `SKILL.md`.
2. **Engine owns orchestration.** Planning, delegation, verification — not stack details.
3. **Hooks own deterministic enforcement.** Bash hooks block dangerous actions.
4. **Non-destructive by default.** Detect → Check → Suggest.
5. **Evidence required.** Every verdict cites `file:line`.
6. **Cross-check before report.** Verify the plan was completed before saying "done".

---

## Quick Start

### Claude Code

```bash
/plugin marketplace add pixelcrafts-app/agent-skills
/plugin install core-hooks@pixelcrafts
/plugin install core-standards@pixelcrafts
```

### Kimi Code CLI

```bash
cd agent-skills
./harnesses/kimi/install.sh
```

Then create `.kimi/AGENTS.md` in your project. See [docs/agents/kimi.md](docs/agents/kimi.md).

### Cursor / Codex / Aider

```bash
cd agent-skills
./harnesses/cursor/export.sh /path/to/project
./harnesses/codex/export.sh /path/to/project
./harnesses/aider/export.sh /path/to/project
```

---

## Skill Catalog

See [docs/skills/catalog.md](docs/skills/catalog.md) for the full list of skills and when they fire.

---

## Contributing

See [docs/skills/contributing.md](docs/skills/contributing.md).

---

## License

MIT
