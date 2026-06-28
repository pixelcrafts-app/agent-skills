# Contributing

Thanks for considering a contribution. This is a short guide — edit flow, naming, review checklist.

## Repo layout

```
skills/                               Generic, harness-independent skills (single source of truth)
  core/                               Cross-stack engine skills — verify-changes, codebase-index, planning, universal-rules, verification, subagent-brief
  api/                                API-standards skills
  web/                                Web-standards skills
  mobile/                             Cross-platform mobile skills
  flutter/                            Flutter-specific skills
  design/                             Platform-agnostic design skills
harnesses/                            Per-harness adapters
  claude/                             .claude-plugin/ manifest templates
  kimi/                               install.sh, AGENTS.md template, overrides/
  cursor/                             export.sh
  codex/                              export.sh
  gemini/                             export.sh
scripts/                              Generic install + export scripts
agent.yaml                            Harness-agnostic manifest
```

Rules live **inside** `SKILL.md` bodies — not as separate `*.md` files. The frontmatter `description:` on a standards skill drives auto-invocation; the body is what Claude reads.

## Naming

- **Marketplace source** — `pixelcrafts-app/agent-skills`
- **Plugin per stack** — `<stack>-standards` (`flutter-standards`, `api-standards`, `web-standards`)
- **Cross-stack** — `core-standards` (skills only); no stack prefix — applies to every language
- **Slash commands** — namespaced per pack: `/flutter-standards:pre-ship`, `/api-standards:sync-migrate`, `/web-standards:premium-check`

## Editing a skill

One copy. No build step. Edit and commit:

1. Edit the skill file — the path depends on the skill scope:
   - Generic stack skill: `skills/<stack>/<name>/SKILL.md`
   - Generic cross-stack skill: `skills/core/<name>/SKILL.md`
   - Claude-only skill: `skills/claude/<name>/SKILL.md`
2. If a Claude plugin bundle needs a version bump, edit the relevant `harnesses/claude/.claude-plugin/*.json` file
3. Add a line to [docs/changelog.md](changelog.md)
4. Update the skill row in [docs/skills/catalog.md](catalog.md) if behavior changed
5. Open a PR

## Adding a standards skill (auto-invoke)

Create `skills/<category>/<name>/SKILL.md`:

```yaml
---
name: <name>
description: One-line description that drives auto-invocation. Start with "Apply when…" or "Use when…" and list the triggering contexts clearly.
---
```

Do **not** set `disable-model-invocation: true` — auto-invoke is the whole point of standards skills.

Then: add a row to `docs/skills/catalog.md`, bump versions, add a changelog line.

## Adding an audit slash command — the thin-wrapper pattern

**Audit commands do not reimplement the engine.** If the command's job is "walk the rules, report pass/fail, maybe fix" (e.g. `premium-check`, `pre-ship`, `theme-audit`), it must delegate to `core-standards:verify-changes`. Reimplementing iteration loops, batching, task metadata, or report formatting is a correctness regression — keep that in one place.

A thin-wrapper audit command is ~20-40 lines. The body:

```markdown
---
name: <command-name>
description: <one-line — what this command audits>
argument-hint: [path or file to audit]
---

# <Command Title>

<One-paragraph purpose — who runs this, when, what they get>

## How to run

This command delegates to `core-standards:verify-changes` (the cross-stack audit engine) with a pre-filled brief. Emit the brief and hand off:

    verify-changes brief:
      scope: $ARGUMENTS                        # or a sensible default if $ARGUMENTS is empty
      dimensions: [<skills this command covers>]
      depth: <direct | direct+consumers>
      fix: <yes | no>
      source: <stack>-standards:<command-name>

Then stop. The engine runs Phases 2-6.

## What you get back

<2-3 bullet points describing the report shape the user will see — the engine's Phase 5 report, scoped to the dimensions above>
```

**Picking dimensions.** The wrapper's one real responsibility. Examples:

- `web-standards:premium-check` → `dimensions: [craft-guide]`, `depth: direct`, `fix: no`
- `web-standards:theme-audit` → `dimensions: [craft-guide:theme-system]`, `depth: direct`, `fix: no`
- `web-standards:pre-ship` → `dimensions: [ALL web-standards skills]`, `depth: direct+consumers`, `fix: no`
- `flutter-standards:premium-check` → `dimensions: [craft-guide, widget-rules, accessibility, performance]`

When a command audits a **subset** of a skill, use the named section reference notation (`craft-guide:theme-system`, `craft-guide:aesthetic-coherence`). The dimension must match a section heading in the target SKILL.md — see the "Rule references" section below.

**When NOT to thin-wrap.** If the command does something the engine can't express — setup workflows (`extract-tokens`), generative scaffolds (`scaffold-feature`), stack-specific regex scans that don't map to rule IDs (`find-hardcoded`, `find-duplicates`), cross-signal classification (`aesthetic-coherence`) — keep the command standalone. The wrapper pattern is for rule-walking audits, not for everything.

## Rule references in standards skills

Rules in standards skills are identified by their **section heading**, not by positional number. A dimension reference like `craft-guide:aesthetic-coherence` maps to the `## Aesthetic Coherence` (or similar) section heading in `craft-guide/SKILL.md`. This survives skill edits — positional numbers (`§9`, `§4.2`) break silently when sections are inserted.

When adding rules to these skills, use a descriptive `##` or `###` heading. The heading becomes the stable identifier. Cross-references from other skills use `skill-name:section-heading` format — e.g. `universal-rules:security`, `craft-guide:aesthetic-coherence`. Do not use `§N.M` notation in new skills or when updating existing ones.

## Adding an explicit skill (slash command)

Same file location. Frontmatter:

```yaml
---
name: <name>
description: <one-line description>
argument-hint: [optional-arg]
---
```

Keep the description narrow and explicit so it does not fire on ambient context — these skills are user-invoked via `/<stack>-standards:<name>`.

Then: add a card to `docs/skills/catalog.md`, bump versions, add a changelog line.

## Adding a new pack

A new pack is a new category folder under `skills/` (`database/`, `rust/`, etc.):

1. Create `skills/<category>/<name>/SKILL.md` files (standards + explicit skills)
2. Add a plugin manifest template `harnesses/claude/.claude-plugin/<category>-standards.json`
3. Register the plugin in `scripts/build-claude.sh` (`PLUGINS` array + `plugin_category`)
4. Add `<category>` to the export loops in `harnesses/{cursor,codex,gemini}/export.sh` and `scripts/build-kimi.sh`
5. Document the pack in `docs/skills/catalog.md`
6. Run `scripts/build-claude.sh`, bump version, add a changelog entry

Before duplicating universal content (DRY, testing pyramid, observability, security) into a new pack, check if it already lives in `core-standards` first (`universal-rules:security`, `universal-rules:testing`, etc.). Add a reference to the relevant named section rather than copying the rules.

## Design principles

- **Pack-universal** — a rule belongs in a pack only if every project using that stack would reasonably want it. Anything narrower (one client's style, one app's workflow) belongs in the consumer project's `CLAUDE.md`, not here.
- **Non-destructive by default** — a standards skill reports and suggests, it does not silently rewrite. Follow Detect → Check → Suggest: name the gap, show options with tradeoffs, let the user decide. Skills that *do* mutate code (scaffolds, fix passes) must be explicit slash commands with narrow descriptions — never auto-invoke standards. Control invocation scope through description design, not flags.
- **Principle-first** — state the rule abstractly enough that a capable reader can apply it to any codebase in the pack's stack. Reach for a concrete example only when the abstraction alone is genuinely ambiguous; default is no example. Avoid "Bad: X / Good: Y" dialogs, named-API illustrations, and scenario narratives — they bias readers toward the illustrated case and read as condescending.
- **Description as trigger** — an auto-invoke skill's `description` frontmatter is what Claude matches against to load the skill. Write it as a condition Claude can recognise from file type or task intent ("Apply when editing …", "Use when …"), not as marketing copy. If the description can't be phrased as a matcher, the skill probably wants to be an explicit slash command instead.
- **Self-contained** — a SKILL.md must stand alone. Do not assume other skills are installed, and do not cross-reference skill internals by `§N.M` from outside the owning skill unless that ID is explicitly documented as stable.
- **No PII, no downstream-consumer names** — this is a public repo. The marketplace owner (`pixelcrafts`) is part of the repo identity and fine to use. What must never appear: real client names, internal product codenames, names/emails of real users, or any data that could be traced to a specific consumer project.
- **One concern per skill** — if a standards skill reads like two rulebooks glued together, split it. A skill's `description` should be expressible in one sentence without an "and".

## Review checklist

- [ ] Version bumped (plugin.json + marketplace.json)
- [ ] Changelog entry added
- [ ] `docs/skills/catalog.md` updated if behavior changed
- [ ] README / ROADMAP reflect any user-facing change (run `core-standards:docs-sync` if unsure)
- [ ] No project-specific names leaked into content
- [ ] Slash command (if new) works end-to-end in a test project

## Versioning

- **Patch** (`0.x.Y`) — doc fixes, typos, clarifications that don't change behavior
- **Minor** (`0.Y.0`) — new skill, new pack, expanded content
- **Major** (`Y.0.0`) — breaking change to a skill's output format, slash command namespace, or marketplace layout

Tag every release as `v<marketplace-version>` so `/plugin marketplace update pixelcrafts` resolves cleanly.

## Reporting issues

- Bug in a skill (wrong output, crash) → open an issue with the input that triggered it
- Disagreement with a standard → open a discussion, not an issue. Standards are opinionated by design; changing them is a policy decision.
- Security issue → see [SECURITY.md](../../SECURITY.md)
