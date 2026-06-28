---
name: craft-config
description: Apply when setting up a new project, or when the project config (craft.json) is absent and needs to be generated. Documents the craft.json schema, what each field activates, and how to maintain it. Also governs disabled_rules transparency rules.
---

# Craft Config

`craft.json` is the project-level configuration that tells the verification system which skills apply to this project. It removes the need for verification to guess from file types alone.

> **Harness note:** The file is conventionally named `craft.json`. Its directory is harness-specific — e.g. `.claude/` for Claude Code, `.kimi/` for Kimi, `.agent/` for Cursor/Codex/Aider, or the project root when no agent-state directory exists. This skill refers to it generically as `<project-state-dir>/craft.json`.

---

## Schema

```json
{
  "stacks": ["web", "api"],
  "features": {
    "auth": "jwt-refresh",
    "realtime": false,
    "i18n": false,
    "payments": false
  },
  "disabled_rules": []
}
```

### `stacks[]`

Which skill domains are PROJECT-MANDATORY for this codebase.

| Value | Activates |
|---|---|
| `"web"` | web-standards skills (craft-guide, nextjs, premium-signals, etc.) |
| `"mobile"` | mobile-standards skills (craft-guide, design-tokens, premium-signals) |
| `"flutter"` | flutter-standards skills (engineering, accessibility, etc.) |
| `"api"` | api-standards skills (nestjs, code-quality, etc.) |

Multiple stacks: `["web", "api"]` activates cross-stack-contracts automatically.

### `features{}`

Which conditional skills are active for this project.

| Key | Value options | Activates |
|---|---|---|
| `auth` | `"jwt-refresh"`, `"oauth"`, `"session"`, `true`, `false` | `auth-flows` |
| `realtime` | `true`, `false` | `websockets` |
| `i18n` | `true`, `false` | `i18n` |
| `payments` | `"stripe"`, `"other"`, `false` | (future skill) |
| `aesthetic` | object — see below | Promotes specific design GUIDES + premium-signals entries to enforced rules |

When a feature is `false`: the skill is inactive. Verification does not enforce it. If the feature's trigger conditions are detected in code anyway, verification emits `INFO` — not `FAIL`.

### `features.aesthetic{}` — opt-in design taste enforcement

Design skills (`design-laws`, `web/premium-signals`, `mobile/premium-signals`) ship with two tiers:

- **RULES** — industry-cited universals (WCAG contrast, tap-target minimums, perceptual color rules). Always enforced.
- **GUIDES** — taste / aesthetic recommendations (Linear's exact shadow values, soft-clay radius ranges, em-dash style preference, etc.). INFO-only by default — a project gets no FAIL on these unless it explicitly commits to an aesthetic.

`features.aesthetic` is how a project says "we have committed to this aesthetic — enforce these specific guides as rules for us." Until that commitment is made, no taste rule blocks the project.

```json
{
  "features": {
    "aesthetic": {
      "active": "<aesthetic-name>",
      "definitions": {
        "<aesthetic-name>": {
          "enforced_guides":  ["<skill>:<section-id>", "..."],
          "enforced_signals": ["<skill>:<section-id>", "..."],
          "bans":             ["<pattern-key>", "..."]
        }
      }
    }
  }
}
```

| Field | Meaning |
|---|---|
| `active` | The aesthetic this project has committed to (matches a key in `definitions`). Exactly one active aesthetic at a time. |
| `definitions[name].enforced_guides[]` | Section IDs from a design-skill's GUIDES section that should be promoted to enforced rules for this project. Format: `<skill-name>:<section-id>` — e.g. `design-laws:G6.gradient-text`. |
| `definitions[name].enforced_signals[]` | Section IDs from a `premium-signals` reference catalog that should be enforced. Format: `<skill-name>:<section-anchor>` — e.g. `premium-signals:bento-grid` or `premium-signals:dark-luxury`. |
| `definitions[name].bans[]` | Pattern keys (lowercase, kebab-case) that the project forbids — e.g. `gradient-text`, `pure-black-shadows`, `neon-accents`. The audit treats any match as FAIL with the ban key as the violation source. |

Multiple definitions can coexist; only the one named in `active` is enforced. The others serve as documentation of considered alternatives.

Example — a project committed to a soft-clay-flavored consumer app:

```json
{
  "features": {
    "aesthetic": {
      "active": "soft-clay",
      "definitions": {
        "soft-clay": {
          "enforced_guides": [
            "design-laws:G3",
            "design-laws:G6.modal-as-first-thought"
          ],
          "enforced_signals": [
            "mobile/premium-signals:soft-clay-radius",
            "mobile/premium-signals:haptic-timing"
          ],
          "bans": [
            "gradient-text",
            "neon-accents",
            "pure-black-shadows"
          ]
        },
        "alt-considered:utility-brutalist": {
          "enforced_guides": [
            "design-laws:G6.gradient-text",
            "design-laws:G8"
          ],
          "enforced_signals": [
            "web/premium-signals:utility-brutalist"
          ],
          "bans": ["bouncy-animations", "soft-shadows"]
        }
      }
    }
  }
}
```

In this project, `soft-clay` is the active aesthetic. The `utility-brutalist` definition is preserved as an audit trail of what else the team considered. Switching active aesthetics is one config edit, not a code change.

When `features.aesthetic` is absent or `active` is `null`: only the RULES tier of every design skill is enforced. GUIDES emit INFO at most. This is the default — no project ships under an enforced aesthetic by accident.

### `disabled_rules[]`

Escape hatch for rules that genuinely do not apply to this project. Each entry requires a reason.

```json
"disabled_rules": [
  {
    "rule": "flutter-standards:observability",
    "reason": "Third-party SDK requires synchronous init before async context is available"
  }
]
```

**Every verification report surfaces all disabled rules with their reasons.** This makes bypasses visible — they are not silent. If a disabled rule has no reason, verification flags it: `WARN: rule disabled without documented reason — add reason or re-enable.`

Disabled rules are not deleted rules. They appear in every report as a reminder that they are opted out.

---

## Auto-Generation

When planning detects no `<project-state-dir>/craft.json`:

1. Detect stacks from: file extensions (`.tsx` → web, `.dart` → flutter, `@nestjs` imports → api), package manifests (`package.json`, `pubspec.yaml`)
2. Detect features from: auth guard patterns → `auth`, socket imports → `realtime`, i18n packages → `i18n`
3. Generate a draft craft.json and present it inline
4. Ask: "Does this look correct for your project?"
5. If confirmed: write to `<project-state-dir>/craft.json`
6. If skipped: note in the plan block that config is absent; verification uses auto-detection with INFO notice

Auto-generation produces a reasonable default. Manual review is required before the file is authoritative.

---

## Maintenance Rules

- Update `craft.json` when a new stack or feature is added to the project
- Do not remove features from `craft.json` when removing the feature from the project — mark as `false` instead of deleting the key, so the absence is explicit
- `craft.json` is committed to the repo and reviewed in PRs — it is a project decision, not a personal preference file
- `<project-state-dir>/craft.json` is the path; the agent-state directory should be in `.gitignore` for secrets but `craft.json` should be committed (it contains no secrets)

---

## Verification Integration

The verification skill reads `craft.json` in Step 0 before detecting active skills. The 4-tier detection model uses it as the authoritative source for PROJECT-MANDATORY skills. Auto-detection is a fallback, not the primary mechanism.
