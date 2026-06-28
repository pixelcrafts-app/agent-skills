---
name: craft-invariants
description: Tier-1 universal web UI rules — industry standards (WCAG, WHATWG, CSS specs, Bringhurst) that hold for every project regardless of brand/aesthetic/framework. Citation-backed, PASS/FAIL/N_A. Project choices (base unit, breakpoints, palette, type scale) live in craft-guide (Tier-2), not here.
requires:
  - verification
---

# Web Craft Invariants (Tier 1)

> Universal, not taste — each rule has a published standard or measurable performance fact. Iterated by `verify-changes` as PASS/FAIL/N_A (never INFO). Disabling one needs a documented reason in `craft.json.disabled_rules[]`. If you're prescribing a specific value (8px, #0D0D0D), it belongs in tokens (`craft-guide`), not here. **If you can load only one UI skill, load this.**

- **R1 Contrast (WCAG 1.4.3/1.4.11):** body ≥4.5:1, large (≥18pt/14pt-bold) ≥3:1, non-text UI ≥3:1. Light and dark are independent checks. Verify: axe-core/pa11y/DevTools.
- **R2 Tap targets ≥44×44 CSS px** (WCAG 2.5.5) — extend hit area with padding even if visual is smaller.
- **R3 Color never the sole state signal** (WCAG 1.4.1) — pair with icon/label/shape/position. Verify: grayscale screenshot.
- **R4 Respect `prefers-reduced-motion`** (MQ L5 / WCAG 2.3.3) — drop decorative animation; functional transitions ≤~150ms, no overshoot.
- **R5 Animate only `transform`/`opacity`** — layout props (width/height/top/left/margin/font-size) trigger per-frame layout/paint. Verify: DevTools paint flashing.
- **R6 Focus visible + `:focus-visible`** (WCAG 2.4.7) — never `outline:none` unreplaced; use `:focus-visible` (keyboard), not `:focus`.
- **R7 Body line-height ≥1.5** (WCAG 1.4.12); display can be 1.0–1.2.
- **R8 Body measure 45–75ch** (Bringhurst §2.1.2) — below reads broken, above hurts comprehension.
- **R9 Semantic HTML** (WHATWG + ARIA APG): `<button>` actions / `<a>` nav; one `<h1>`, no skipped heading levels; `<label>` per control; `<img alt>` present (`alt=""` decorative); `<html lang>`.
- **R10 `color-scheme` declared** (CSS Color Adjustment L1) — so native controls/scrollbars match the theme.
- **R11 `forced-colors: active` honored** (MQ L5) — custom rings/borders/icons use system colors in High Contrast.
- **R12 Single source of truth** (W3C Design Tokens) — no hardcoded hex/px/ms/type literals in screen code; Tailwind arbitrary values (`p-[13px]`) count as hardcoded. Verify: grep raw literals in screen files.
- **R13 Font loading without CLS** (CSS Fonts L4 + CWV) — `font-display: swap`/`optional`, preload above-fold, matched fallback metrics (`size-adjust`/`ascent-override`).
- **R14 `tabular-nums` on aligned numeric columns** (CSS Fonts L4) — proportional digits jump as values change.
- **R15 Sub-44px adjacent targets ≥24px center-to-center** (WCAG 2.5.5 AA fallback).

## Enforcement & reading order

`verify-changes` iterates these on any touched UI surface; Tier-2 contract checks run alongside in `craft-guide`. Order: **craft-invariants** (universals) → `craft-guide` (project contract) → `design-laws` (taste, opt-in) → `premium-signals` (product reference, opt-in).
