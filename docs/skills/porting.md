# Porting Skills Between Harnesses

## From Generic Skill to Claude

1. Copy `skills/<category>/<skill>/SKILL.md` (or `skills/claude/` for Claude-only skills)
2. It ships automatically — `scripts/build-claude.sh` packages every skill into the plugin marketplace
3. Add a slash command in the skill if applicable

## From Generic Skill to Kimi

1. Copy `skills/<category>/<skill>/SKILL.md`
2. Rename with `pc-` prefix: `pc-<category>-<skill>/SKILL.md`
3. Remove hook references
4. Replace slash commands with natural language triggers
5. Save to `~/.kimi/skills/`

## From Generic Skill to Cursor

1. Copy `skills/<category>/<skill>/SKILL.md`
2. Add YAML frontmatter with scoped globs
3. Save as `.cursor/rules/<category>-<skill>.mdc`

## From Generic Skill to Codex / Aider

1. Copy `skills/<category>/<skill>/SKILL.md`
2. Append to `AGENTS.md` or `.aider/conventions.md`
3. Group by category

## What Cannot Port

- **Slash commands** — Claude-only
- **State files / audit cache** — Claude-only
- **MCP integration** — Claude-specific protocol

These are Claude-specific and are not expected to work elsewhere.
