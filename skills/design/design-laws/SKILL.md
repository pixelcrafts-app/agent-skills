---
name: design-laws
description: Platform-agnostic design laws. RULES (industry-backed invariants — perceptual color, type scale, layout-animation perf, scene-sentence method) → PASS/FAIL/N_A. GUIDES (taste from pbakaus/impeccable — color strategy, visual bans, anti-AI-slop tests) → INFO only, never FAIL. Apply before any design work on Web, iOS, or Android.
origin: pbakaus/impeccable
requires:
  - verification
---

# Frontend Design Laws

> Two kinds of claim, kept separate. **RULES** are standards/perceptual facts (`verify-changes` → PASS/FAIL/N_A). **GUIDES** are one designer's taste (→ INFO only, never FAIL). Promote a guide to a rule per-project via `craft.json features.aesthetic.<name>.enforced_guides[]` (or `.bans[]`).

## RULES (PASS / FAIL / N_A)

- **R1 No pure `#000`/`#fff` on UI surfaces** — tint neutrals toward the brand hue (chroma ~0.005–0.01). N_A only for declared OLED-dark/brutalist aesthetics.
- **R2 Perceptually-uniform color space** — define tokens in OKLCH/LCH, reduce chroma near L 0/100. Hardcoded RGB/HSL where a token system exists = FAIL.
- **R3 Scene sentence before dark vs light** — one physical-scene sentence (who/where/ambient/mood) that *forces* the answer (e.g. "SRE checking severity on a 27″ monitor at 2am in a dim room" → dark). No scene → FAIL.
- **R4 Body measure 45–75ch** (Bringhurst) — outside the window = FAIL.
- **R5 Type scale step ratio ≥1.2** — flat scales (14/15/16) collapse into monotony = FAIL.
- **R6 Don't animate layout props** (top/left/width/height/margin/padding) — use `transform`+`opacity` (layout/paint is O(n); transform is GPU-composited).

## GUIDES (INFO only — many premium products break them on purpose)

- **G1 Color strategy axis** — pick before picking colors:

| Strategy | Surface coverage | For |
|---|---|---|
| Restrained | tinted neutrals + 1 accent ≤10% | product UI default |
| Committed | one saturated color 30–60% | brand/identity pages |
| Full palette | 3–4 named roles | campaigns, data viz |
| Drenched | surface *is* the color | heroes, campaign pages |

(The "≤10% accent" applies only to Restrained — don't reflex-collapse everything to it.)

- **G2 Vary spacing for rhythm** (alternate dense/loose), not uniform padding.
- **G3 Cards are usually lazy** — use only when genuinely the best affordance; nested cards = missed IA. (Counter: Pinterest, App Store.)
- **G4 Avoid reflex containers** — most groupings carry on spacing + type, not a bordered `div`.
- **G5 Easing by context** — ease-out-expo/quart reads snappy (productivity); bounce/spring reads playful (consumer). Both valid.
- **G6 Visual bans** (overused patterns — counter-examples exist): side-stripe borders · gradient text (`background-clip:text`) · glass as default surface · hero-metric template · identical card grids · modal-as-first-thought. Forbid per-project via `bans[]`.
- **G7 Every word earns its place** — no restated headings/intros.
- **G8 Prefer commas/colons/parens over em dashes** (style, not rule).
- **G9 AI-slop tests:** (1) could someone say "AI made that" without doubt? (2) Category-reflex — can you guess theme+palette from the domain alone (observability→dark blue, finance→navy+gold)? If yes, rework the scene sentence (R3) + color strategy (G1) until it's no longer obvious.

## How verify-changes reads this

`## RULES` headings → PASS/FAIL/N_A; `## GUIDES` headings → INFO only (can't block READY) unless a project promotes a guide key (e.g. `G6.gradient-text`) via `enforced_guides[]`.
