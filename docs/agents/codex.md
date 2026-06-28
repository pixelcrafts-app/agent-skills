# Codex / OpenAI SWE Setup

Agent-skills can be exported to a single `AGENTS.md` file for OpenAI Codex or SWE agents.

## Export

```bash
cd agent-skills
./harnesses/codex/export.sh /path/to/your-project
```

Outputs:
- `AGENTS.md` in the target project root

## Contents

The exported `AGENTS.md` contains:
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
