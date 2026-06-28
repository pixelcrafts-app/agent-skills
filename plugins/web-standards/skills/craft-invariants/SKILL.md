---
name: craft-invariants
description: Tier 1 universal rules for web UI — industry standards (WCAG, WHATWG, CSS specs, Bringhurst typography) that hold for every web project regardless of brand, aesthetic, framework, or design system. Every rule is citation-backed and produces PASS/FAIL/N_A. Anything that is a project's choice (base unit, breakpoints, color palette, type scale specifics) belongs in craft-guide (Tier 2 — project contract), not here.
requires:
  - verification   # verdict semantics — these are PASS/FAIL rules, not INFO
---

# Web Craft Invariants — Tier 1

> Every rule below is universal across web projects. They are not the
> author's taste. Each has a published standard or measurable performance
> fact behind it.
>
> Where this skill ends and `craft-guide` begins: invariants live here,
> *contracts* (the project's declared base unit, breakpoint set, color
> palette, type scale, motion scale) live in `craft-guide`. If you find
> yourself prescribing a specific value (8px, 1280px, #0D0D0D), it belongs
> in the project's tokens, not in this file.

## Verdict semantics

Every rule in this file is iterated by `verify-changes` as PASS / FAIL / N_A. `INFO` is never appropriate here — these are invariants, not preferences. A project disabling one of these requires a documented reason in `craft.json.disabled_rules[]`.

---

## R1 — Color contrast meets WCAG 2.1 AA

| Surface | Minimum ratio |
|---|---|
| Body text (< 18pt regular or < 14pt bold) | **4.5 : 1** |
| Large text (≥ 18pt regular or ≥ 14pt bold) | **3 : 1** |
| Non-text UI (icons, focus rings, form borders, status indicators) | **3 : 1** |

Citation: WCAG 2.1 Success Criteria 1.4.3 (text contrast) and 1.4.11 (non-text contrast).
Verification: any computed-contrast tool — `axe-core`, `pa11y`, browser DevTools accessibility audit.
**Light mode and dark mode are independent checks.** A pass in one is not a pass in the other.

## R2 — Tap targets ≥ 44×44 CSS pixels

Every interactive element (button, link, form control, custom-clickable) must occupy a hit area of at least 44 × 44 CSS pixels, even if the visual is smaller. Use padding to extend the hit area when needed.

Citation: WCAG 2.1 Success Criterion 2.5.5 (Target Size) — AAA at 44px, AA at 24px with adjacent-target spacing. We adopt 44 as floor.
Verification: query selector tests, or visual debug overlays.

## R3 — Color is never the sole signal of state

State (error, success, warning, selected, disabled, required) must be conveyed by at least one channel besides color — icon, label, position, shape, weight.

Citation: WCAG 2.1 Success Criterion 1.4.1 (Use of Color).
Verification: grayscale screenshot review; every state distinguishable when desaturated.

## R4 — Reduced motion is respected

When the user has `prefers-reduced-motion: reduce` set, decorative animations are removed. Functional transitions (navigation, modal presentation) may stay but must be reduced (typically ≤ 150 ms, no overshoot).

Citation: CSS Media Queries Level 5 + WCAG 2.1 Success Criterion 2.3.3 (Animation from Interactions).
Verification: emulate via DevTools rendering panel; visible animations should pause/shorten.

## R5 — Don't animate layout properties

Animate `transform` and `opacity` only. Animating `width`, `height`, `top`, `left`, `margin`, `padding`, `font-size`, or other layout-trigger properties causes layout/paint per frame — O(n) work in the layer subtree. `transform` and `opacity` are GPU-composited.

Citation: Web rendering pipeline — Chrome DevTools "Rendering" panel "Paint flashing" and "Layer borders" demonstrations.
Verification: DevTools "Performance" recording — no green paint flashes on animated areas.

## R6 — Focus is visible AND uses `:focus-visible`

Every interactive element has a visually distinct focus indicator (not `outline: none` without replacement). Use `:focus-visible` (keyboard-only) — not `:focus` (also fires on click).

Citation: WCAG 2.1 SC 2.4.7 (Focus Visible) + CSS Selectors Level 4 (`:focus-visible`).
Verification: tab through every interactive element; outline appears on each.

## R7 — Body line-height ≥ 1.5

Body text line-height is at least 1.5× the font size. Display sizes can use tighter line-heights (typically 1.0–1.2).

Citation: WCAG 2.1 SC 1.4.12 (Text Spacing) — minimum 1.5 line-height.
Verification: computed style on body type tokens.

## R8 — Body measure 45–75 characters per line

Body text line length stays within 45–75 characters per line at the design viewport. Below 45ch reads as broken; above 75ch reduces comprehension.

Citation: Robert Bringhurst, *The Elements of Typographic Style*, §2.1.2. Widely adopted in web typography (Smashing, A List Apart, MDN guide to fluid type).
Verification: `getComputedStyle()`'s `max-width` on body containers vs `1ch` of the body font.

## R9 — Semantic HTML

Use HTML elements for their semantic meaning:

- `<button>` for actions, `<a>` for navigation
- `<h1>` once per page; no skipped heading levels in the outline (no `<h2>` directly followed by `<h4>`)
- `<label>` associated with every form control
- `<img>` has `alt` (`alt=""` for decorative; the attribute must be present)
- `<html lang="...">` declared

Citation: WHATWG HTML Living Standard + WAI-ARIA Authoring Practices 1.2.
Verification: axe-core / pa11y rules; document outline tools.

## R10 — `color-scheme` declared

The root or theme container declares `color-scheme: light dark` (or just `light` / just `dark`) so the browser renders form controls, scrollbars, and built-in UI in the matching palette.

Citation: CSS Color Adjustment Module Level 1.
Verification: native form controls (date picker, scrollbar) match the page theme.

## R11 — High-contrast / forced-colors honored

`forced-colors: active` (Windows High Contrast Mode, similar systems) must render the UI legibly. Custom focus rings, borders, and icons must use system colors when forced-colors is active.

Citation: CSS Media Queries Level 5 + Microsoft High Contrast spec.
Verification: emulate via DevTools rendering panel.

## R12 — Single source of truth for design values

No hardcoded design literals (color hex, spacing px, radius px, duration ms, type size) in screen code. Every such value comes from a named token defined once. Tailwind arbitrary values (`p-[13px]`, `text-[1.0625rem]`) count as hardcoded.

Citation: Design Tokens Community Group (W3C) format spec; industry convention since Salesforce Theo (2014).
Verification: grep for raw hex / px / ms / rgba literals in screen files; should hit only token source files.

## R13 — Font loading without CLS

Custom fonts use `font-display: swap` (or `optional`). Above-fold critical fonts are preloaded (`<link rel="preload" as="font">`). Fallback metrics are matched (`size-adjust`, `ascent-override`, `descent-override`, `line-gap-override`) so the layout doesn't shift when the custom font arrives.

Citation: CSS Fonts Module Level 4 + Web Vitals CLS guidance.
Verification: Lighthouse CLS score on first contentful render.

## R14 — Tabular numerals on aligned numeric columns

Numbers in columns (tables, dashboards, money, timestamps, scoreboards) use `font-variant-numeric: tabular-nums`. Proportional digits jump horizontally as values change.

Citation: CSS Fonts Module Level 4. Standard typographic practice.
Verification: visual review of numeric columns under live updates.

## R15 — Touch target spacing

When tap targets are adjacent and smaller than 44×44, gap between centers must be ≥ 24px (WCAG 2.5.5 AA fallback for sub-44 targets).

Citation: WCAG 2.1 SC 2.5.5.
Verification: inter-target spacing review.

---

## Where to enforce

`verify-changes` iterates these rules whenever a touched file is in a UI surface (route, page, component, layout). Tier-2 contract checks (does the project have a base unit? do all spacing values resolve to a token? etc.) live in `craft-guide` and run alongside.

## Reading order with related skills

1. **`craft-invariants`** (this file) — universals, every project.
2. `craft-guide` — the project's design contract (declared tokens, scales). Tier-2.
3. `design-laws` GUIDES — taste recommendations; opt-in promotion to enforced via `craft.json features.aesthetic`.
4. `premium-signals` — reference catalog of specific products' values; opt-in promotion to enforced via `craft.json features.aesthetic.<name>.enforced_signals[]`.

If you're auditing a project's UI and only have time to load one skill, load this one.
