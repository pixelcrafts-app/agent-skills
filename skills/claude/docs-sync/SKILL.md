---
name: docs-sync
description: Apply at the end of a full task (not mid-work) to catch drift between code and docs. Auto-invokes on completion signals — version bump, new skill folder, plugin.json/marketplace.json edit, "ship/done/release", pre-ship, or a v*.*.* commit. Never blocks — flags deltas the user decides on.
---

# Docs Sync — end-of-task discipline

> Flag drift, don't rewrite. **Don't auto-fix prose or rewrite voice** — prose is the user's.

## When it fires (task-end only, not after every edit)

- **Strong (run it):** version bumped in any `plugin.json`/`marketplace.json` · new skill folder · plugin/hook added or removed · user says "ship/done/release/push" · `v<semver>` commit message · pre-ship invoked.
- **Weak (offer, don't auto-run):** 5+ file edits close out · README/CHANGELOG itself modified.
- **Don't fire:** single-file mid-task edits · refactors with no surface change · internal test/CI changes. Unsure → don't run; the user can invoke explicitly.

## What to check (flag each gap with the specific mismatch)

1. **Versions** — every `plugin.json` correct; `marketplace.json metadata.version` = highest plugin; each marketplace entry matches its plugin.json; commit/tag matches code.
2. **README** — plugin-count line, install snippet (current default plugins + marketplace repo), feature sections that still exist, example slash commands match real skill names, links resolve, no removed-plugin/deprecated-flag references.
3. **Changelog** — entry for the current version, today's date, `Added/Changed/Removed/Breaking` match reality (not copy-paste), breaking items front-loaded, prior entry not duplicated.
4. **Roadmap** — move shipped items to "Shipped"; add new initiatives; no phantom "done but not shipped" items.
5. **Skills catalog** (`docs/skills.md`) — every skill folder has an entry and vice versa; auto-invoke counts match; slash-command rows reference skills that exist.
6. **Per-plugin README** — mirrors relevant changes; no refs to removed plugins.
7. **Descriptions** — the skill's `description` mentions any new concern (so it auto-invokes); plugin descriptions in `plugin.json` + `marketplace.json` reflect what it now does.
8. **Cross-boundary refs** — quickstart/contributing/security and any doc naming a plugin/skill/command get the same treatment; grep old+new repo/org names across all `.md` (broken renames are the top source of stale docs).

## Report

Short report grouped by severity — **Critical** (blocks release: file + mismatch) · **Minor** (drift) · **OK** (verified in sync). Then the user decides. Never silently rewrite README/changelog.

## Scope

This is *sync*, not quality. It does **not** rewrite prose, reorder sections, enforce structure, add emojis/badges, or fix typos (separate pass).
