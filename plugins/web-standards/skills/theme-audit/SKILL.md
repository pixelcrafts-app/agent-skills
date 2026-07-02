---
name: theme-audit
description: Verify theme completeness — every themeable value uses tokens, light and dark independently designed, no hardcoded bleed-through, SSR hydration flash prevented
argument-hint: [optional: scope — "app" | "components" | path] [--fix]
---

Check that design tokens exist first — read `design-tokens.md`, or scan `tailwind.config.*` and `:root` + `.dark` CSS vars. If no tokens found, stop and tell the user to establish tokens first (e.g., by running a token-extraction workflow).

```
verify-changes brief:
  scope: $ARGUMENTS or "app/ + components/"
  dimensions: [craft-guide:theme-system, craft-guide:contrast-dark-mode, craft-guide:selection-styling, craft-guide:caret-color, craft-guide:color-scheme-property, craft-guide:forced-colors, craft-guide:prefers-reduced-transparency]
  depth: direct
  fix: yes if --fix, else no
  source: web-standards:theme-audit
```

Emit this brief to `verify-changes` and stop; the engine runs the audit. Make edits only when `--fix` is present.
