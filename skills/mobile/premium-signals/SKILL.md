---
name: premium-signals
description: Reference catalog of precise mobile design values from shipped premium products (iOS 26, Material You, Things 3, Superhuman, Arc Mobile, Apple Design Award winners). INFO-only — documented references, not enforced rules. Opt in via craft.json features.aesthetic.<name>.enforced_signals[].
verdict_mode: INFO_ONLY
requires:
  - verification
---

# Mobile Premium Signals (reference catalog)

> **INFO-only.** `verify-changes` never FAILs on these. Precise values from named shipped products; a Flutter Material 3 or RN Paper app will correctly violate many. Enforce via `craft.json features.aesthetic.<name>.enforced_signals[]`.

## Platform-native motion

- **iOS springs** (over tween/ease): standard `spring(response:.35, damping:.7)` · snappy `(.25,.8)` · gentle modal `(.5,.75)`.
- **Android:** predictive back scales destination `0.95→1.0`, velocity-matched on release. `FastOutSlowIn` enter / `FastOutLinearIn` exit / `LinearOutSlowIn` incoming. Never `AccelerateDecelerate` on UI.
- Timing: micro `100–200ms` · transitions `300–400ms` · entrances `400–600ms` · list stagger `50–100ms`/item (cap 400ms). Never >3 concurrent without stagger.

## iOS Liquid Glass (iOS 26 / visionOS)

- Tab bar: `.ultraThinMaterial`/`.regularMaterial` (never solid — glass needs the blur), continuous corner radius `28`, `tabBarMinimizeBehavior(.onScrollDown)`.
- Nav bar: `.toolbarBackground(.ultraThinMaterial)` + `.automatic` visibility (translucent at top, solid once content scrolls under — like Calendar/Photos/Messages).
- Specular highlight: 3–8% white radial gradient from top-left (CoreMotion parallax if native).

## Material You (Android)

- Dynamic color from wallpaper (Android 12+) with a brand fallback — never crash/gray on older.
- **Tonal elevation** (primary tint by level, not shadow — shadows are invisible on dark): surface 0% · +1 5% · +2 8% · +3 11% · +4 12% · +5 14%.

## Bottom sheets & modals

- iOS detents intentional to content: `.fraction(0.15)` persistent utility · `0.5` secondary · `.large` primary. `presentationDragIndicator(.visible)` always; corner radius `28`.
- Backdrop: dark `rgba(0,0,0,.5)`, light `.25`; never colored. Dismiss on swipe-down AND backdrop tap (if disabled, show a top-right close button).

## Haptics

- Fire `10–50ms` **after** the visual (never simultaneous — that reads as one blunt tap). Check `supportsHaptics` first; silent fail otherwise.

| Action | iOS | Android |
|---|---|---|
| toggle/selection/picker | impact `.light` | `CLICK` |
| confirm action | impact `.medium` | `HEAVY_CLICK` |
| destructive/milestone/error | impact `.heavy` | `DOUBLE_CLICK` |
| slider/digit ticks | selection generator | waveform `[0,20],[80]` |
| success | notification `.success` | `TICK` |

## Scroll & buttons

- Scroll-linked transition toward `.isIdentity` (in-viewport): e.g. opacity 1→0.3, scale 1→0.85, blur 0→3 on exit. Everything appearing fully-formed-at-rest reads as template.
- Button press: web hover `100ms ease-out` / press `60ms ease-in` `scale(0.97)` / release `100ms`. iOS press `scale 0.96–0.97` `spring(.2,.7)`.

## Typography (market-sourced)

| Role | Size | LH | Wt | Tracking |
|---|---|---|---|---|
| hero/display | 32–40 | 1.05–1.1 | 700–800 | −.03em |
| headline | 24–28 | 1.15–1.2 | 700 | −.02em |
| title | 18–20 | 1.25–1.3 | 600 | −.01em |
| body | 16 (14 for power-user apps) | 1.5 | 400 | 0 |
| label | 12 | 1.3 | 600 | +.03em |
| caption | 11 | 1.3 | 400 | +.02em |

iOS via `UIFontMetrics`/`dynamicTypeSize` (never hardcoded pt); test xL/xxL/xxxL. Android `sp` units; test 130% + 200% scale.

## Color (mobile)

- OKLCH for token definitions where supported; map to framework-native colors otherwise.
- Dark = independent design, never invert: bg warm-neutral (not `#000`), text `rgba(255,255,255,.87)` primary / `.65` secondary, 5-step lighter elevation.
- Neutrals carry 5–15% saturation of the primary hue (pure gray reads dead): e.g. `hsl(260 8% 12%)`.

## Empty state formula

Three elements only: monochrome illustration (stroke matched to icon library; never stock/3D/AI) + one sentence (what's missing + the benefit) + one specific-verb CTA ("Create your first project", not "Get started"). No subtext, no secondary buttons.
