# Project Template: .kimi/AGENTS.md

Place this file at `<project-root>/.kimi/AGENTS.md`. It is the ONLY file you need per project.

All reusable standards live in global skills (`~/.kimi/skills/`). This file is only for:
- Project identity and purpose
- Active stack declarations (which global skills apply)
- Project-specific boundaries and rules
- Links to external docs

---

## Example: API Project (NestJS + Prisma)

```markdown
# lavamgam-api-core — Kimi Instructions

This is the core API for LavaMGam. NestJS + Prisma + PostgreSQL.

## Active Stacks

- api (NestJS/Prisma) — `pc-api-standards` skill applies
- core — `pc-work-principles`, `pc-planning`, `pc-universal-rules`, `pc-verification`

## Scope Boundaries

- Auth lives in `pixelcrafts-api-auth`. Do NOT reimplement auth here.
- Prisma schema is MANAGED BY api-news. Do not edit directly — use `npm run sync:schema`.
- AI calls go through `pixelcrafts-api-ai`. No direct OpenAI/Anthropic SDK usage.

## Project-Specific Rules

- Pagination: clamp with `Math.min(Math.max(limit, 1), 100)`
- All outbound fetch calls use `AbortSignal.timeout()`
- API keys compared with `crypto.timingSafeEqual`
- Archived code goes to `_unused/` (gitignored), never deleted

## End-of-Task

- `npx tsc --noEmit` must pass
- `npm test` must pass
- Do not push without explicit instruction
```

---

## Example: Flutter Project

```markdown
# interviewace-app — Kimi Instructions

Flutter app for AI-powered interview practice. Stack: Riverpod + GoRouter + Hive + Firebase.

## Active Stacks

- flutter — `pc-flutter-standards` skill applies
- mobile — `pc-mobile-standards` skill applies
- core — `pc-work-principles`, `pc-planning`, `pc-universal-rules`, `pc-verification`

## Scope Boundaries

- Auth uses `pixelcrafts_auth` SDK. Do not reimplement Firebase auth flows.
- Voice recording uses `pixelcrafts_audio` SDK. Do not reimplement VAD/recording.
- Backend APIs live in `pixelcrafts-api-ai` and `pixelcrafts-api-auth`.

## Project-Specific Rules

- Use `AppConfig` from `lib/core/config/app_config.dart` for all env-dependent values
- Screen files go in `lib/screens/<feature>/`
- Data models go in `lib/data/models/`
- State management: Riverpod `StateNotifier` for complex, `StateProvider` for simple

## End-of-Task

- `flutter analyze` must pass
- `flutter test` must pass
- Do not push without explicit instruction
```

---

## Example: Web Project (Next.js)

```markdown
# pixelcrafts-web — Kimi Instructions

Marketing + dashboard web app. Next.js 14 + Tailwind + shadcn/ui.

## Active Stacks

- web — `pc-web-standards` skill applies
- core — `pc-work-principles`, `pc-planning`, `pc-universal-rules`, `pc-verification`

## Scope Boundaries

- Auth delegates to `pixelcrafts-api-auth`. No local auth state.
- API calls go through the shared fetch wrapper in `lib/api/`.

## End-of-Task

- `npm run type-check` must pass
- `npm run lint` must pass
- Do not push without explicit instruction
```
