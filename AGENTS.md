# Agent Skills

This repository contains harness-agnostic standards, skills, and rules for AI-assisted software development.

It is consumed by different AI coding tools through harness-specific adapters:

| Harness | Setup Guide | Key Mechanism |
|---------|-------------|---------------|
| **Claude Code** | [docs/agents/claude.md](docs/agents/claude.md) | Plugins + slash commands |
| **Kimi Code CLI** | [docs/agents/kimi.md](docs/agents/kimi.md) | Global skills + `.kimi/AGENTS.md` |
| **Cursor** | [docs/agents/cursor.md](docs/agents/cursor.md) | Exported `.cursor/rules/*.mdc` |
| **OpenAI Codex** | [docs/agents/codex.md](docs/agents/codex.md) | Exported `AGENTS.md` |
| **Aider** | [docs/agents/aider.md](docs/agents/aider.md) | Exported `.aider/conventions.md` |

## What Lives Where

- `skills/` — Harness-agnostic skills (single source of truth)
- `harnesses/` — Per-harness adapters and configuration
- `docs/agents/` — Setup instructions for each harness
- `docs/skills/` — How to write and port skills
- `docs/harnesses/` — Architecture notes per harness

## Core Principles

1. **Skills own all knowledge.** Every standard lives in a `SKILL.md`.
2. **Engine owns orchestration.** Planning, delegation, verification — not stack details.
3. **Non-destructive by default.** Detect → Check → Suggest.
4. **Evidence required.** Every verdict cites `file:line`.

## Quick Start

Pick your harness from the table above and follow its setup guide.

If you are unsure which to use:

- **Claude Code** → richest experience (plugins, slash commands, state)
- **Kimi Code CLI** → simplest setup (one `AGENTS.md` per project)
- **Cursor/Codex/Aider** → static rule export
