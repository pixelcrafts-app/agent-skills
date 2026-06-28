# Authoring a Skill

All skills in this repo are **harness-agnostic** and **self-contained**. They are consumed by Claude, Kimi, Cursor, Codex, and Aider through harness adapters.

## Start From the Template

Use [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md) as the starting point for every new skill.

## Skill Location

```
skills/<category>/<skill-name>/SKILL.md
```

Categories: `core`, `api`, `web`, `mobile`, `flutter`, `design`

## Required Structure

Every `SKILL.md` must include:

1. **Frontmatter** with `name`, `description`, `triggers`, `scope`, `outputs`
2. **Identity** — one-line purpose
3. **When to Apply** — exact trigger conditions
4. **Must-Do Checklist** — hard steps the agent completes
5. **Rules** — numbered, enforceable criteria
6. **Verification Commands** — exact terminal commands
7. **Verdicts** — PASS/FAIL/INFO semantics (if applicable)

## Writing Rules

- Use "The agent..." or "You..." — never "Claude..." or "Kimi..."
- Do not reference harness-specific features (hooks, slash commands, state files)
- Do not reference other skills — skills are independent
- Do not reference installation paths like `~/.kimi/skills/`
- Keep rules evidence-based
- Provide `file:line` citations when claiming facts
- Every rule must be checkable with a tool call (Read, Bash, grep)

## Forbidden Content

| Forbidden | Example |
|-----------|---------|
| Harness paths | `.claude/craft.json`, `.kimi/AGENTS.md` |
| Installation paths | `~/.kimi/skills/` |
| Skill cross-references | "See `codebase-index` skill" |
| Harness actor | "Claude decides" |
| Slash commands | "Run `/verify-changes`" |
| Hook behavior | "The hook will block..." |
| State files | "Write to `.claude/audit-cache.json`" |
| Vague criteria | "Make it good" |

## Allowed Generic Language

| Use | Example |
|-----|---------|
| Generic actor | "The agent reads the file" |
| Direct instruction | "You must run tests" |
| Tool-agnostic command | "Run the verification command" |
| Generic sequence | "Before editing, read..." |

## Harness-Specific Behavior

If a concept cannot be expressed harness-agnostically, it does not belong in a skill. Put it in the harness adapter:

- Claude hooks → `harnesses/claude/hooks/`
- Kimi install → `harnesses/kimi/install.sh`
- Cursor export → `harnesses/cursor/export.sh`

## Validation

Before committing a skill, run:

```bash
./scripts/validate-skills.sh
```

This checks for forbidden references and missing required sections.
