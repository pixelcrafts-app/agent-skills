# Skills Catalog

Six plugins ship, 64 skills total. **Auto-invoke standards** load when Claude sees matching work; **`[cmd]`** skills are user-invoked via `/<pack>:<skill>`. Generated from the skill files — keep in sync via `docs-sync`.

Install a pack: `/plugin install <pack>@pixelcrafts` (after `/plugin marketplace add pixelcrafts-app/agent-skills`).

---

## flutter-standards

| Skill | What it covers |
|---|---|
| accessibility | Semantics, contrast, touch targets, text scaling, reduced motion, RTL |
| engineering | DRY, single source of truth, error handling, data pipeline, widget patterns |
| forms | Field anatomy, keyboard types, autofill, validation timing, multi-step |
| observability | One logger, level thresholds, crash hooks, PII discipline, consent |
| performance | Frame/cold-start budgets, lists, decode-at-size, isolates, memory |
| production-readiness | Detect→Check→Suggest: retry, lifecycle, deep links, push, force-update, secure storage, offline |
| `[cmd]` app-audit | Full Flutter audit — pre-ship + craft + screen states |
| `[cmd]` scaffold | Generate a feature/screen with correct structure |
| `[cmd]` scan | Hardcoded values, duplicate code, a11y patterns |

## api-standards (NestJS + Prisma)

| Skill | What it covers |
|---|---|
| api-design | REST principles — naming, HTTP semantics, status codes, pagination, errors, auth, versioning |
| nestjs | Module/controller/service/repository discipline, validated DTOs, error shape |
| code-quality | Binary checks A–I + Detect→Check→Suggest for production concerns (rate limit, idempotency, webhooks, …) |
| cross-stack-contracts | Error shape, pagination, auth header, versioning at the boundary |
| websockets | Connection auth, reconnect/backoff, event enum, schema versioning, room auth |
| db-migrations | Prisma schema change workflow |

## web-standards (Next.js + Tailwind + shadcn)

| Skill | What it covers |
|---|---|
| nextjs | App router, server/client boundary, tokens, shadcn, React Query, RHF+Zod |
| craft-guide | Tier-2 design contract (§0–§15 rule index: color, spacing, type, motion, states, …) |
| craft-invariants | Tier-1 universals (WCAG, CSS, Bringhurst) — PASS/FAIL |
| premium-signals | INFO catalog of precise market values (shadow, dark grays, easing, tabular-nums, …) |
| taste | Metric dials + anti-AI-slop rules + creative arsenal |
| performance | Web performance budgets and patterns |
| production-readiness | Detect→Check→Suggest §R1–R10 (error boundaries, Suspense, CSP, CWV, …) |
| i18n | Translation keys, plural rules, RTL, locale routing |
| `[cmd]` pre-ship | Full quality gate before merge |
| `[cmd]` premium-check | Craft audit of a component/page |
| `[cmd]` extract-tokens | Extract design tokens → `design-tokens.md` |
| `[cmd]` theme-audit | Light/dark parity, hydration flash, `color-scheme` |
| `[cmd]` aesthetic-coherence | Detect aesthetic mixing |

## mobile-standards (Flutter / RN / SwiftUI / Compose)

| Skill | What it covers |
|---|---|
| craft-guide | Tier-2 contract — IA, density, perception, motion, state, navigation continuity |
| craft-invariants | Tier-1 universals (PASS/FAIL) — targets, contrast, 60fps, safe areas, cold-start |
| design-tokens | Token completeness + naming + per-framework violation patterns |
| premium-signals | INFO catalog of precise iOS 26 / Material You values |

## design-standards (platform-agnostic)

| Skill | What it covers |
|---|---|
| design-laws | RULES (perceptual color, type scale, layout-anim perf) + GUIDES (taste, anti-slop) |
| accessibility | WCAG 2.2 AA across Web/iOS/Android — POUR + cross-platform map |
| information-architecture | Page structure, navigation, route hierarchy, content placement |
| brand-research | Verify product exists, collect assets logo→imagery→UI→color→font |
| creative-direction | What separates memorable, ownable UI from forgettable |

## core-standards (cross-stack engine — applies to every project)

**Engine & always-on:** work-principles · planning · universal-rules · verification · verify-changes · codebase-index · honesty (always-loaded) · subagent-brief · auth-flows · craft-config · search-first · state-files · codebase-onboarding · architecture-decision-records · docker-patterns · hexagonal-architecture · external-tools (prefer Bash over connectors; validate external output) · minimize-code (smallest maintainable diff after explicit requirements, safety, and correctness).

**Autonomous pipeline** (single prompt → verified delivery, each phase locked before the next): `spec-validator` → `contracts` → `contract-tests` → `integration` → `challenger` (adversarial review, fresh context).

**Claude-only** (ship in this plugin; need Claude's command/state features): `[cmd]` full-setup · `[cmd]` /spec (via spec-validator) · context-budget · docs-sync · strategic-compact.

---

## Use without Claude Code

Cursor, Codex, and Gemini CLI consume the same skills via static export:

```bash
git clone https://github.com/pixelcrafts-app/agent-skills
./agent-skills/scripts/deploy.sh <cursor|codex|gemini> /path/to/your-project [pack]
```

Outputs: Cursor → `.cursor/rules/<pack>-<skill>.mdc` · Codex → `AGENTS.md` · Gemini → `GEMINI.md`. Kimi installs globally via `./harnesses/kimi/install.sh`. Re-run anytime to refresh.
