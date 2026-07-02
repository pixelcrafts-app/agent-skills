---
name: pre-ship
description: Full quality gate before merge — lint then all installed web standards
argument-hint: [optional-path] [--fix]
---

Run the project lint command first (`npm run lint` / `pnpm lint`). If it fails and `--fix` is absent, report the command and failure, then stop. With `--fix`, fix lint output first, rerun lint, then emit the audit brief.

```
verify-changes brief:
  scope: $ARGUMENTS or "uncommitted working tree"
  dimensions: [nextjs, production-readiness, craft-guide]
  depth: direct+consumers
  fix: yes if --fix, else no
  source: web-standards:pre-ship
```

Emit this brief to `verify-changes` and stop; the engine runs the audit. Make edits only when `--fix` is present.
