# Aider Setup

Agent-skills can be exported to Aider-compatible convention files.

## Export

```bash
cd agent-skills
./harnesses/aider/export.sh /path/to/your-project
```

Outputs:
- `.aider/conventions.md`

## Limitations

- Aider reads convention files as system context
- No enforcement beyond prompt influence
- No hooks, slash commands, or state files

## Recommended Use

Best for:
- Coding conventions
- Architecture guidelines
- Testing expectations
