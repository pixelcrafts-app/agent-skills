---
name: craft-invariants
description: Tier 1 universal rules for mobile UI — Apple HIG, Material Design, WCAG, and platform contracts (iOS, Android, frame budget, safe areas, system reduced-motion) that hold for every mobile project regardless of brand, aesthetic, or framework (Flutter, React Native, SwiftUI, Compose, KMP). Every rule is citation-backed and produces PASS/FAIL/N_A. Anything that is a project's choice (base unit, radius scale specifics, motion scale, color palette) belongs in craft-guide (Tier 2), not here.
requires:
  - verification   # verdict semantics — these are PASS/FAIL rules, not INFO
---

# Mobile Craft Invariants — Tier 1

> Every rule below is universal across mobile projects. Cross-framework
> by design: Flutter, React Native, SwiftUI, Jetpack Compose, KMP. Each
> rule cites either a platform guideline (Apple HIG, Material) or a
> measurable platform contract.
>
> Where this skill ends and `craft-guide` begins: invariants live here,
> *contracts* (the project's base unit, radius scale, color palette,
> motion scale) live in `craft-guide`. If you find yourself prescribing
> a specific value (8dp, 200ms, #0D0D0D), it belongs in the project's
> tokens, not in this file.

## Verdict semantics

Every rule is iterated by `verify-changes` as PASS / FAIL / N_A. `INFO` is never appropriate here — these are invariants. A project disabling one of these requires a documented reason in `craft.json.disabled_rules[]`.

---

## R1 — Tap targets meet platform minimums

| Platform | Minimum hit area |
|---|---|
| iOS | **44 × 44 pt** |
| Android | **48 × 48 dp** |

Use padding to extend the hit area when the visual is smaller. Never rely on visual size to match hit area.

Citation: Apple Human Interface Guidelines — Layout & Organization, "Tap target size." Material Design 3 — Layout, "Touch targets."
Verification: framework-specific inspector or layout debug overlays.

## R2 — Color contrast meets WCAG 2.1 AA

Same ratios as web — mobile devices vary in ambient light and brightness more than desktops, so contrast headroom is more critical, not less.

| Surface | Minimum ratio |
|---|---|
| Body text | 4.5 : 1 |
| Large text (≥ 17pt iOS / ≥ 18sp Android) | 3 : 1 |
| Non-text UI | 3 : 1 |

Citation: WCAG 2.1 SC 1.4.3 + 1.4.11. Apple HIG references the same numbers under "Color & Effects > Contrast." Material references them under "Accessibility > Color contrast."
Verification: tool-driven contrast check on every theme. Light and dark are independent passes.

## R3 — Color is never the sole signal of state

Same principle as web. Error / success / warning / selected / disabled must use icon + label / weight / position alongside color.

Citation: WCAG 2.1 SC 1.4.1.
Verification: grayscale screenshot review.

## R4 — System reduced-motion is respected

When the OS reports reduced-motion (iOS: `UIAccessibility.isReduceMotionEnabled`, Android: `Settings.Global.TRANSITION_ANIMATION_SCALE == 0` or `ACCESSIBILITY_REDUCE_MOTION_ENABLED`, OS-level Settings), decorative animations are removed; navigation transitions are reduced (≤ 150 ms, no overshoot / spring physics).

Citation: Apple HIG — Motion. Material 3 — Motion accessibility.
Verification: toggle the OS setting; review animations.

## R5 — 60 fps frame budget — no jank on the main thread

Every frame must complete its update in **≤ 16.6 ms** at 60 fps (or **≤ 8.3 ms** at 120 fps on ProMotion / high-refresh displays). Heavy work (image decoding, expensive layout, large list rebuilds) belongs on background threads / isolates / coroutines.

Citation: iOS Core Animation refresh contract. Android Frame Metrics API. Material's "GPU profiling" guidance.
Verification: framework profiler (Flutter DevTools timeline, Xcode Instruments, Android GPU profiler) shows zero dropped frames during interaction.

## R6 — Safe areas are honored

Notches, Dynamic Island, home indicator, status bar, gesture areas, keyboard insets, and Android display cutouts must not overlap content or interactive surfaces. Use the framework's safe-area mechanism, not hardcoded paddings.

Citation: Apple HIG — Layout & Organization, "Safe areas." Android — `WindowInsets`.
Verification: visual test on a device with each insetting kind (notched iOS, foldable, etc.).

## R7 — Keyboard moves content, doesn't hide it

When the soft keyboard appears, focused inputs and primary actions must remain visible. Content scrolls / resizes; it doesn't get obscured.

Citation: Apple HIG — Inputs > Onscreen keyboards. Android — `WindowSoftInputMode.ADJUST_RESIZE`.
Verification: focus each input in a long form; confirm visibility.

## R8 — Don't animate layout properties

Animate transforms / opacity / framework-native compositing properties. Resizing layout boxes per frame (width, height, padding, margin) causes the framework's layout pass to run every frame — O(n) work in the subtree.

Citation: iOS Core Animation contract — implicit-transform animations are GPU-composited; bounds animations are not. Flutter `RepaintBoundary` + `Transform` semantics. Compose `graphicsLayer { ... }`.
Verification: framework profiler shows compositing-only frames during the animation.

## R9 — Platform back / navigation conventions are honored

Back gesture (Android predictive, iOS edge-swipe) and the system back button do what the user expects: tabs return to root, modal sheets dismiss, deep navigation pops one screen. Don't override unless the action is destructive (and confirmed).

Citation: Apple HIG — Navigation. Android — Predictive back gesture guidance.
Verification: navigate forward 3 screens, back-swipe; verify the pop order.

## R10 — Accessibility labels on every interactive element

Every tappable element has an accessibility label that names its action — not its element type.

| ✗ | ✓ |
|---|---|
| "Button" | "Save changes" |
| "Image" | "Profile photo" |
| "Icon" | "Delete this item" |

Citation: Apple HIG — Accessibility > Labels. Material 3 — Accessibility > Descriptive text.
Verification: screen reader walkthrough (iOS VoiceOver, Android TalkBack). Every step makes sense aurally.

## R11 — System font scaling respected

When the user has system-level large text enabled (iOS Dynamic Type, Android font scale), the app's text must scale and the layout must reflow. No `text-overflow: clip` at default sizes. No min-height containers that clip scaled text.

Citation: iOS Dynamic Type. Android Settings > Display > Font size.
Verification: set system font scale to largest; review every screen.

## R12 — Single source of truth for design values

No hardcoded design literals (color, spacing, radius, duration, font size) in screen code. Every value comes from a named token. Inline literals (Flutter: `SizedBox(width: 12)`; SwiftUI: `.padding(12)`; Compose: `Modifier.padding(12.dp)`) are FAIL outside the token file.

Each framework declares its token file location and naming convention in the project config; screen code must import values only from those files.

Citation: Design Tokens Community Group (W3C); industry convention.
Verification: grep for raw-number patterns matching the per-framework adapter list.

## R13 — Localization-ready by default

- No hardcoded user-facing strings outside the localization resource(s).
- Layout must work in RTL languages where the app ships those locales (mirror padding, alignment, icons that imply direction).
- Date / time / currency / number formatting goes through the platform's locale-aware formatters, not string concatenation.

Citation: Apple HIG — Inclusion > Internationalization. Material 3 — Internationalization.
Verification: switch device locale; spot-check screens. Run app in RTL pseudolocale.

## R14 — Offline + slow-network states designed

Mobile apps live on flaky networks. Every screen that requests data has:

- A loading state matching the final layout (not a full-screen spinner)
- An offline state with retry affordance
- An error state naming the failure + a concrete next step

Citation: Apple HIG — Patterns > Loading. Material 3 — Patterns > Empty states.
Verification: enable Network Link Conditioner (iOS) / network throttling (Android Studio); manually disable network mid-fetch.

## R15 — Cold start is a full journey

Every navigation destination must work as the entry point (deep link, push notification, share extension, widget tap). Cold-start the app directly into a deep screen; confirm it shows real content rather than a half-loaded state.

Citation: Apple HIG — Patterns > Launching. Android — App startup performance guidance.
Verification: build a deep link for every primary destination; cold-launch each.

---

## Where to enforce

`verify-changes` iterates these rules on any touched file in a UI surface (screen, view, widget, fragment, route). The Tier-2 contract checks (does the project have a declared base unit? do all spacing values resolve to tokens?) live in `craft-guide` and run alongside.

## Reading order with related skills

1. **`craft-invariants`** (this file) — universals, every mobile project.
2. `craft-guide` — the project's design contract (declared tokens, scales). Tier 2.
3. `design-tokens` — token completeness audit + per-framework adapter patterns.
4. `design-laws` GUIDES — taste; opt-in via `craft.json features.aesthetic`.
5. `premium-signals` — reference catalog of specific products' values; opt-in via `enforced_signals[]`.

If you're auditing a mobile project and only have time to load one skill, load this one.
