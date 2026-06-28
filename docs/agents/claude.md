# Claude Code Setup

Agent-skills works with Claude Code through the Claude plugin system and project-level `.claude/` configuration.

## Install

### Plugin marketplace

```bash
/plugin marketplace add pixelcrafts-app/agent-skills
/plugin install core-hooks@pixelcrafts
/plugin install core-standards@pixelcrafts
/plugin install web-standards@pixelcrafts      # web projects
/plugin install api-standards@pixelcrafts      # API/backend projects
/plugin install design-standards@pixelcrafts   # any UI work
/plugin install mobile-standards@pixelcrafts   # mobile projects
/plugin install flutter-standards@pixelcrafts  # Flutter projects
```

### Team install via settings.json

Commit `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "pixelcrafts": { "source": { "source": "github", "repo": "pixelcrafts-app/agent-skills" } }
  },
  "enabledPlugins": {
    "core-hooks@pixelcrafts": true,
    "core-standards@pixelcrafts": true,
    "web-standards@pixelcrafts": true
  }
}
```

## What Works

- **Bash hooks** — deterministic pre/post tool enforcement
- **Slash commands** — `/verify-changes`, `/full-setup`, `/spec`, `/parallelize`
- **State files** — `.claude/agent-traffic.log`, `.claude/verify-state.json`
- **Enforcement config** — `.claude/enforcement.json`
- **Project config** — `.claude/craft.json`

## What Is Claude-Specific

- Hooks run only in Claude Code (bash lifecycle events)
- Slash commands require Claude's command system
- Plugin marketplace metadata is Claude-specific

## Project Setup

Run `/full-setup` to generate the project layer for any project.
