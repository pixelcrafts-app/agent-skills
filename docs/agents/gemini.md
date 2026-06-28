# Gemini CLI Setup

Agent-skills can be exported to a single `GEMINI.md` file, which Gemini CLI auto-loads as its hierarchical context.

## Export

```bash
cd agent-skills
./scripts/deploy.sh gemini /path/to/your-project [pack]
```

Outputs:
- `GEMINI.md` in the target project root

`pack` is one of `all` (default), `core`, `api`, `web`, `mobile`, `flutter`, `design`. Prefer a specific pack — `all` concatenates every skill into one large file.

## Contents

The exported `GEMINI.md` contains:
- Core work principles
- Universal rules
- Stack-specific standards
- End-of-task checks

## Limitations

- No hooks or slash commands
- Static instructions only
- Agent may not follow all rules in long sessions

## Recommended Use

Best for:
- Consistent coding style
- Security guardrails
- Review checklists
