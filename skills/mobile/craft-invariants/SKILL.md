---
name: craft-invariants
description: Tier-1 universal mobile UI rules — Apple HIG, Material, WCAG, and platform contracts (frame budget, safe areas, system reduced-motion) that hold for every mobile project regardless of brand/aesthetic/framework (Flutter, RN, SwiftUI, Compose, KMP). Citation-backed, PASS/FAIL/N_A. Project choices (base unit, radius, motion, palette) live in craft-guide (Tier-2).
requires:
  - verification
---

# Mobile Craft Invariants (Tier 1)

> Universal across mobile, cross-framework. Each rule cites a platform guideline or measurable contract. Iterated by `verify-changes` as PASS/FAIL/N_A (never INFO); disabling needs a documented reason in `craft.json.disabled_rules[]`. Specific values (8dp, 200ms) belong in tokens (`craft-guide`), not here. **If you load only one mobile UI skill, load this.**

- **R1 Tap targets** — iOS ≥44×44pt, Android ≥48×48dp (extend hit area with padding) — HIG / Material.
- **R2 Contrast (WCAG 1.4.3/1.4.11)** — body 4.5:1, large (≥17pt/18sp) 3:1, non-text 3:1; light+dark independent.
- **R3 Color never sole state signal** (WCAG 1.4.1) — icon/label/weight/position too. Verify grayscale.
- **R4 Respect system reduced-motion** (`isReduceMotionEnabled` / Android transition scale) — drop decorative, nav transitions ≤150ms no spring.
- **R5 60fps frame budget** — ≤16.6ms (≤8.3ms at 120Hz); heavy work (decode, layout, big rebuilds) off the main thread. Verify: profiler shows no dropped frames.
- **R6 Safe areas honored** — notch/island/home-indicator/status-bar/cutouts/keyboard via framework safe-area, not hardcoded padding.
- **R7 Keyboard moves content, doesn't hide it** — focused input + primary action stay visible (`ADJUST_RESIZE`).
- **R8 Animate transforms/opacity/compositing props**, not layout boxes (width/height/padding per frame = layout pass each frame).
- **R9 Platform back/nav honored** — tabs→root, sheets dismiss, deep nav pops one; override only for confirmed destructive.
- **R10 Accessibility label on every interactive element** naming the **action** ("Save changes", not "Button"). Verify VoiceOver/TalkBack.
- **R11 System font scaling respected** (Dynamic Type / Android font scale) — text scales + layout reflows, no clipping at largest.
- **R12 Single source of truth** — no hardcoded literals in screen code (`padding(12)` outside the token file = FAIL). Verify grep per-framework.
- **R13 Localization-ready** — no hardcoded user strings, RTL mirroring where shipped, locale-aware date/number formatters.
- **R14 Offline + slow-network states** — every data screen has loading (matches layout), offline (retry), error (names failure + next step). Verify with throttling.
- **R15 Cold start is a full journey** — every destination works as entry point (deep link/push/share/widget); cold-launch shows real content, not half-loaded.

## Enforcement & reading order

`verify-changes` iterates these on any touched mobile UI surface; Tier-2 contract checks run alongside in `craft-guide`. Order: **craft-invariants** → `craft-guide` (contract) → `design-tokens` (token audit) → `design-laws` (taste, opt-in) → `premium-signals` (product reference, opt-in).
