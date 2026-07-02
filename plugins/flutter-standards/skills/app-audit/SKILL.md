---
name: app-audit
description: "Run full Flutter app audit: pre-ship checks, craft quality, screen states. Explicit command only."
argument-hint: [optional-path] [--fix]
---

Run `flutter analyze` first. If it fails and `--fix` is absent, report the command and failure, then stop. With `--fix`, fix analyzer output first, rerun analyze, then emit the audit brief.

```
verify-changes brief:
  scope: $ARGUMENTS or "uncommitted working tree"
  dimensions:
    - engineering correctness      # rules: flutter-standards:engineering
    - craft quality                # rules: mobile-standards:craft-guide (states, hierarchy, motion)
    - screen completeness          # loading / empty / error / content states
    - production readiness         # rules: flutter-standards:production-readiness
    - accessibility                # rules: flutter-standards:accessibility
    - performance                  # rules: flutter-standards:performance
  depth: full-ripple
  fix: yes if --fix, else no
  source: flutter-standards:app-audit
```

Emit this brief to `verify-changes` and stop; the engine runs the audit.
