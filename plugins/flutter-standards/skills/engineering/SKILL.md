---
name: engineering
description: Apply when writing or reviewing any Dart or Flutter code — reusability, single source of truth, no hardcoded values, centralized cross-cutting concerns, consistent error handling, data-pipeline verification, widget patterns. Auto-invoke on any Flutter code change.
---

# Flutter Engineering

> Shared code knows nothing about features; features never know each other. Every fact lives in one place. Specific values below are sensible defaults — adjust to the project.

## Reusability & single source of truth

- Reused in 2+ widgets/features → extract to `lib/shared/widgets/` (pure, no Flutter deps → `lib/shared/utils/`). Used once and <10 lines → inline.
- **One source per fact:** colors, typography, spacing, radius, routes, models, mappers, storage, sync keys each live in exactly one file/class. Found in two places → delete one, import the other.
- **No hardcoded values** for spacing/radius/color/type/duration/threshold — reference the design system or a named constant. Only bare literals allowed: `0 1 -1 '' [] true false` and map keys.

## Centralize cross-cutting concerns

Anything 2+ features need is infrastructure, not feature code: auth, API client, persistence, sync, connectivity, notifications, purchases, and the shared loading/error/empty/button widgets. Features never call auth providers, the API client, or storage directly. A screen's `build()` mostly composes existing widgets.

## Architecture & state scope

- `shared/` → `features/`, one-directional. Screens display; logic lives in the state layer; only rebuild what changed.
- App-wide state (auth, theme, connectivity): root providers, never disposed. Feature/screen state: `.autoDispose`. Never store UI state app-wide.

## Error handling (one pattern per project)

1. Data layer returns result types (`Result<T,Failure>` or `AsyncValue<T>`) — never throws unhandled. Pick one, use it everywhere.
2. Repositories translate HTTP errors into typed failures (`Network/Auth/NotFound/Server`).
3. Providers expose `AsyncValue`; screens use `.when(loading, error, data)` with a specific message + recovery action.
4. Auth errors → session-expiry flow. Retry only idempotent ops on transient errors (timeout, 502/503/504) — never 4xx.

Forbidden: silent `catch (_) {}`, generic "Something went wrong", errors with no next step.

## Data pipeline verification

When data doesn't appear, verify each layer in order — `flutter analyze` at the screen does **not** validate the rest: **source** (exists/published/flagged) → **API** (returns it) → **mapper** (handles the real shape) → **model** (fields match) → **provider** (exposes it) → **screen** (renders it, all 4 states: loading/empty/error/content).

## Data layer

- **Mappers:** check the actual API response first (never assume shape); handle nested sub-objects + field aliases; default every optional field; never crash on missing data.
- **Models:** immutable + `copyWith`; `fromJson` handles cache *and* live formats and round-trips with `toJson`; type-safe defaults.
- **API client:** services/repos only — never features. Timeouts on every call. `401` → refresh token, retry once, then session-expiry. Returns result types.
- **Repositories:** parse via mappers (never raw JSON inline); own the cache-vs-live decision; sole network access.

## Widget patterns

- **Dart:** `const` constructors; `final` over `var`; named params past 2; `switch` expressions; `withValues(alpha:)` not `withOpacity()`.
- **Safety:** `mounted` check before `setState` in async; null-safe provider access (no force-unwrap); dispose controllers/subscriptions/`AnimationController`/`FocusNode`.
- **Keys:** `ValueKey(id)` on reorderable list items; `PageStorageKey` on scrollables in tabs; never index-as-key for dynamic lists.
- **Touch targets:** ≥48×48dp (enforce with `SizedBox`/`ConstrainedBox`), ≥8dp apart.
- **Text resilience:** `maxLines`+`ellipsis` on anything that can overflow; never `maxLines:1` for user content (≥2); assume user text 3× longer than test data; locale-aware numbers; relative time ("2h ago"), not raw ISO.
- **Layout:** `SafeArea`/`MediaQuery.padding` for notch/island/home-indicator; keyboard via `viewInsets.bottom`.
- **Feedback (example values):** tap → scale ~0.96 (~100ms) then spring back (~200ms); haptics `light/medium/heavy/selectionClick` by weight, ~10–50ms after the visual; respect the user's haptic setting.
- **Loading:** skeleton matches final layout; one loading style per app; never a blank screen.
- **Destructive:** undo `SnackBar` (~3–5s) for delete; confirmation dialog for irreversible.

## Checklist

- [ ] No duplicated widget/helper/provider/mapper; every fact single-sourced
- [ ] No hardcoded design values; cross-cutting concerns centralized
- [ ] One error pattern; typed failures; every screen handles 4 states
- [ ] Data pipeline verified end-to-end, not just `flutter analyze`
- [ ] Controllers/subscriptions disposed; correct keys; ≥48dp targets; text overflow-safe
