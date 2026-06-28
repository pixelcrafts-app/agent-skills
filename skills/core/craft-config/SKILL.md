---
name: craft-config
description: Apply when setting up a new project or when project config (craft.json) is absent. Documents the craft.json schema, what each field activates, and disabled_rules transparency.
---

# Craft Config

`craft.json` tells verification which skills apply to this project (so it doesn't guess from file types). Lives at `<project-state-dir>/craft.json` (`.claude/`/`.kimi/`/`.agent/`/project root); committed to the repo, reviewed in PRs.

## Schema

```json
{
  "stacks": ["web", "api"],
  "features": { "auth": "jwt-refresh", "realtime": false, "i18n": false, "payments": false },
  "disabled_rules": []
}
```

**`stacks[]`** — project-mandatory domains: `web` → web-standards · `mobile` → mobile-standards · `flutter` → flutter-standards · `api` → api-standards. Two+ stacks auto-activate `cross-stack-contracts`.

**`features{}`** — conditional skills: `auth` (`jwt-refresh`/`oauth`/`session`/`true`/`false`) → `auth-flows` · `realtime` → `websockets` · `i18n` → `i18n` · `payments` → future. When `false`, the skill is inactive; if its trigger patterns appear in code anyway, verification emits **INFO, not FAIL**.

## `features.aesthetic` — opt-in taste enforcement

Design skills (`design-laws`, `premium-signals`) have two tiers: **RULES** (cited universals — always enforced) and **GUIDES** (taste — INFO-only by default). `aesthetic` is how a project commits to an aesthetic and promotes specific guides/signals to enforced rules. Absent/`active:null` → only RULES enforced (no project ships under an enforced aesthetic by accident).

```json
"aesthetic": {
  "active": "soft-clay",
  "definitions": {
    "soft-clay": {
      "enforced_guides":  ["design-laws:G3"],                          // GUIDE section IDs → enforced
      "enforced_signals": ["mobile/premium-signals:soft-clay-radius"], // catalog entries → enforced
      "bans":             ["gradient-text", "neon-accents"]            // pattern keys → FAIL on match
    },
    "alt-considered:utility-brutalist": { "...": "documents alternatives; not enforced" }
  }
}
```

Exactly one `active` aesthetic enforced; other definitions are an audit trail. Switching is one config edit, not a code change.

## `disabled_rules[]`

Escape hatch — each entry needs a reason: `{ "rule": "flutter-standards:observability", "reason": "..." }`. **Every verification report surfaces all disabled rules + reasons** (bypasses are never silent); a disabled rule with no reason → `WARN: add reason or re-enable`. Disabled ≠ deleted.

## Auto-generation (when planning finds no craft.json)

Detect stacks (extensions `.tsx`→web/`.dart`→flutter, `@nestjs`→api; manifests) and features (auth guards, socket imports, i18n packages) → present a draft inline → ask "correct?" → write on confirm; if skipped, note absence in the plan and fall back to auto-detection with an INFO notice. Manual review required before the file is authoritative.

## Maintenance

Update when a stack/feature is added. Don't delete a removed feature's key — set `false` so the absence is explicit. Verification reads `craft.json` in Step 0 as the authoritative source for project-mandatory skills; auto-detection is a fallback.
