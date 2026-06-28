# kimi-craft

Kimi equivalent of claude-craft. Global skill packs that apply across all projects — no per-project copying of rules.

## How It Works

```
┌─────────────────────────────────────────────┐
│  GLOBAL (~/.kimi/skills/)                   │
│  Core standards + stack packs               │
│  (installed once, applies everywhere)       │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│  PROJECT (.kimi/AGENTS.md)                  │
│  Thin overlay: identity + stacks + bounds   │
│  (one file per project, ~30 lines)          │
└─────────────────────────────────────────────┘
```

## Core Skills (All Projects)

| Skill | Purpose |
|---|---|
| `pc-work-principles` | Detect→Check→Suggest, non-destructive, evidence-based |
| `pc-planning` | Task routing, plan blocks, verification criteria |
| `pc-universal-rules` | Security, testing, observability, engineering |
| `pc-verification` | Post-implementation audit mindset |
| `pc-subagent-brief` | How to write warm agent briefs |
| `pc-honesty` | No unsourced claims, evidence before "done" |

## Stack Skills (Per-Project via AGENTS.md)

| Skill | Stack | Status |
|---|---|---|
| `pc-api-standards` | NestJS / Prisma / backend | ⏳ Port from claude-craft |
| `pc-web-standards` | Next.js / React / frontend | ⏳ Port from claude-craft |
| `pc-flutter-standards` | Flutter / Dart | ⏳ Port from claude-craft |
| `pc-mobile-standards` | Cross-platform mobile | ⏳ Port from claude-craft |
| `pc-design-standards` | Design / craft / UI | ⏳ Port from claude-craft |

## Installation

```bash
# From claude-craft repo root
./kimi/install.sh
```

This syncs all skills from `kimi/skills/` to `~/.kimi/skills/`.

## Adding a New Project

1. Create `.kimi/AGENTS.md` in the project root
2. Copy from `kimi/PROJECT_TEMPLATE.md`
3. Fill in: project name, active stacks, boundaries, end-of-task checks
4. Done — no other files needed

## Differences from claude-craft

| Feature | claude-craft (Claude) | kimi-craft (Kimi) |
|---|---|---|
| Hooks | 13 bash hooks | ❌ Not supported |
| Enforcement | `.claude/enforcement.json` | ❌ Not supported — discipline via skills |
| Slash commands | `/parallelize`, `/verify-changes` | ❌ Not supported — use natural language |
| Skill packs | `core-standards`, `api-standards`, etc. | ✅ Same concept, pure SKILL.md |
| Per-project setup | `.claude/` + `CLAUDE.md` | ✅ Just `.kimi/AGENTS.md` |
| State files | `agent-traffic.log`, `verify-state.json` | ❌ Not supported |

## Porting a claude-craft Skill

1. Copy `SKILL.md` from `claude-craft/<pack>/skills/<name>/`
2. Remove hook references (e.g., "The protect-files hook will block...")
3. Remove slash command references (e.g., "Run `/verify-changes`...")
4. Replace with natural language triggers (e.g., "When the user asks to verify changes...")
5. Save to `kimi/skills/<name>/SKILL.md`
6. Run `./kimi/install.sh`

## Updating Skills

Edit in this repo → run `./kimi/install.sh` → all projects get the update instantly.
