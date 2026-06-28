# Cursor Setup

Agent-skills can be exported to Cursor Rules v2 format (`.cursor/rules/*.mdc`).

## Export

```bash
cd agent-skills
./harnesses/cursor/export.sh /path/to/your-project
```

Outputs:
- `.cursor/rules/core-work-principles.mdc`
- `.cursor/rules/core-planning.mdc`
- `.cursor/rules/web-craft-guide.mdc`
- ... one `.mdc` per installed skill

## Limitations

- Cursor rules are static, not dynamic like Claude hooks
- No lifecycle enforcement
- No slash commands
- Best for coding standards, not autonomous verification

## Recommended Use

Use Cursor export for:
- Design system rules
- Code style enforcement
- Architecture conventions

Do not expect:
- Pre-tool blocking
- Automatic test running
- Multi-agent orchestration
