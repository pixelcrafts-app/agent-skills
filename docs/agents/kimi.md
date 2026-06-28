# Kimi Code CLI Setup

Agent-skills works with Kimi Code CLI through global skills and a per-project `.kimi/AGENTS.md` file.

## Install

```bash
cd agent-skills
./harnesses/kimi/install.sh
```

This syncs all skills from `skills/` to `~/.kimi/skills/` with the `pc-` prefix.

## Project Setup

Create `.kimi/AGENTS.md` in your project root. Copy from `harnesses/kimi/.kimi/AGENTS.md.template`.

```markdown
# my-project — Kimi Instructions

Brief project description.

## Active Stacks

- web — `pc-web-standards` skill applies
- core — `pc-work-principles`, `pc-planning`, `pc-universal-rules`, `pc-verification`

## Scope Boundaries

- Auth lives in `pixelcrafts-api-auth`. Do not reimplement.
- AI calls go through `pixelcrafts-api-ai`.

## End-of-Task

- `npm run type-check` must pass
- `npm run lint` must pass
```

## What Works

- **Pure SKILL.md skills** — loaded automatically based on stack declarations
- **Natural language triggers** — say "verify my changes" instead of `/verify-changes`
- **Single-file project setup** — just `.kimi/AGENTS.md`

## What Is Kimi-Specific

- No slash commands (use natural language)
- No state files or persistent audit cache
- No plugin packaging — skills are installed globally to `~/.kimi/skills/`

## Differences from Claude

| Feature | Claude | Kimi |
|---------|--------|------|
| Skill delivery | Plugin marketplace | Global `~/.kimi/skills/` |
| Slash commands | `/verify-changes` | Natural language |
| Per-project files | `.claude/` + `CLAUDE.md` | `.kimi/AGENTS.md` only |
| State files | `verify-state.json`, `audit-cache.json` | Not supported |
