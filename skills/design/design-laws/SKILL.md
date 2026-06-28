---
name: design-laws
description: Platform-agnostic design laws. Two sections — RULES (industry-backed invariants — perceptual color, type-scale, layout-animation perf, scene-sentence methodology) produce PASS/FAIL/N_A. GUIDES (taste recommendations from pbakaus/impeccable — color strategy axis, absolute visual bans, anti-AI-slop tests, copy preferences) produce INFO only, never FAIL. Apply before any design work on Web, iOS, or Android.
origin: pbakaus/impeccable
requires:
  - verification   # verdict taxonomy: RULES → PASS/FAIL/N_A; GUIDES → INFO only
---

# Frontend Design Laws

## Triggers

- Starting any UI design or redesign task
- Reviewing a design that feels generic or "AI-made"
- Choosing colors, theme (dark/light), layout, or motion
- Any surface where category alone predicts the aesthetic

---

## RULES — universals (PASS / FAIL / N_A)

These hold regardless of brand, aesthetic, or framework. Each is backed by either a published standard or a perceptual / performance fact. `verify-changes` iterates these as PASS / FAIL / N_A.

### R1 — Color: avoid pure black / pure white on UI surfaces

`#000` and `#fff` on body surfaces read as un-designed in most non-OLED, non-brutalist contexts. Tint every neutral toward the brand hue (chroma 0.005–0.01 is enough to break the reflex). Exception: OLED-dark and committed brutalism aesthetics — declare them in `craft.json features.aesthetic` and this rule becomes N_A.

### R2 — Color: use perceptually uniform color space for token definitions

Use OKLCH (or LCH) for color tokens. Reduce chroma as lightness approaches 0 or 100 — high chroma at extremes is garish. RGB / HSL hardcoded values are FAIL when a token system exists.

### R3 — Theme: scene-sentence before choosing dark vs light

Write one sentence of physical scene before choosing dark or light: who, where, ambient light, mood. If the sentence does not force the answer, add detail until it does. Theme chosen without a scene sentence is FAIL.

```
✗  "Observability dashboard"
✓  "SRE checking incident severity on a 27" monitor at 2am in a dim room"  → forces dark
```

### R4 — Typography: body measure 45–75ch

Body line length outside the 45–75 character window is FAIL. Reference: Bringhurst, *The Elements of Typographic Style*.

### R5 — Typography: type scale uses a ≥ 1.2 step ratio

Adjacent type-scale steps below a 1.2 ratio collapse into visual monotony. Modular-scale conventions (1.2, 1.25, 1.333, 1.414, 1.5, golden) all satisfy. Flat scales (e.g., 14 / 15 / 16) FAIL.

### R6 — Motion: don't animate CSS layout properties

`top`, `left`, `width`, `height`, `margin`, `padding` animations are FAIL on any rendering path that has more than a couple of elements. Use `transform` (translate / scale) and `opacity`. Reason: layout / paint are O(n); transform / opacity is GPU-composited.

---

## GUIDES — taste recommendations (INFO only)

These are opinion-flavored craft heuristics, sourced from `pbakaus/impeccable`. They are **not** universal — many premium products break them deliberately. `verify-changes` surfaces these as INFO; they never FAIL a project.

To **promote** any of these to enforced rules for a specific project, list the rule key in `craft.json features.aesthetic.<your-aesthetic>.enforced_guides[]`.

### G1 — Color strategy axis (commitment framework)

Pick a color strategy before picking colors. Four positions on the commitment axis:

| Strategy | Surface coverage | Use for |
|----------|-----------------|---------|
| **Restrained** | Tinted neutrals + one accent ≤10% | Product UI default; brand minimalism |
| **Committed** | One saturated color at 30–60% | Brand pages, identity-driven surfaces |
| **Full palette** | 3–4 named roles, used deliberately | Brand campaigns; data viz |
| **Drenched** | Surface IS the color | Hero sections, campaign pages |

"One accent ≤10%" applies only to Restrained — Committed / Full palette / Drenched exceed it on purpose. Don't collapse every design to Restrained by reflex.

### G2 — Layout: vary spacing for rhythm

Same padding on every element is monotony. The fix is *rhythm* — alternating dense and loose sections — not "always different padding." Reference, not rule.

### G3 — Layout: cards are usually lazy

A card grid is the path of least design effort and the most common mediocre UI. Use cards only when they're the genuinely-best affordance for the content. Nested cards almost always indicate a missed information-architecture decision. Reference, not rule — Pinterest, App Store, Dribbble are correct counter-examples.

### G4 — Layout: avoid reflex containers

Wrapping every group in a `<div>` with padding and a border-radius adds visual weight without information. Most groupings can be carried by spacing and typography. Reference, not rule.

### G5 — Motion: easing preferences

For UI productivity tooling: ease-out exponential curves (ease-out-quart / quint / expo) read snappy. Bounce / elastic / spring overshoot read playful and are appropriate for consumer / kids / casual contexts. Both are valid — choose by context, not by reflex.

### G6 — Absolute visual bans (match-and-refuse table)

These are six specific patterns the source author flags as overused. They are recommendations — many premium products use them well.

| Pattern | Source author's recommendation | Counter-example |
|-----|-----|-----|
| Side-stripe borders | Use full borders / background tints / leading numbers instead | Many fintech / dashboard UIs |
| Gradient text via `background-clip: text` | Single solid; emphasize via weight or size | Apple keynote slides, brand pages |
| Glassmorphism as default surface | Rare and purposeful overlay only | Apple iOS Control Center, macOS Big Sur+ |
| Hero-metric template (big number + small label + gradient) | Rework the data presentation | Stripe Atlas dashboard does this well |
| Identical card grids | Mix sizes, use a different affordance | Spotify album grid, Pinterest |
| Modal as first thought | Exhaust inline / progressive disclosure first | Genuinely correct for confirms and dangerous actions |

Promote any of these to enforced rules per-project in `craft.json features.aesthetic.<name>.bans[]` if the project's aesthetic forbids them on purpose.

### G7 — Copy: every word earns its place

No restated headings, no intros that repeat the title. Trim the page.

### G8 — Copy: em-dash preference

The source author prefers commas, colons, semicolons, periods, or parentheses over em dashes (`—` / `--`). This is style, not rule. Editorial, journalism, and many premium long-form publications use em dashes deliberately.

### G9 — AI Slop Tests

Both tests are heuristic taste checks before shipping any design.

**Test 1 — The "AI made that" test**
Could someone look at this interface and say "AI made that" without doubt? If yes, rework it.

**Test 2 — Category-reflex check**
Could someone guess the theme and palette from the category name alone?

```
observability → dark blue
healthcare    → white + teal
finance       → navy + gold
crypto        → neon on black
```

If yes, that's training-data reflex. Rework the scene sentence (R3) and the color strategy (G1) until the answer is no longer obvious from the domain.

---

## How `verify-changes` reads this file

- Headings under `## RULES` produce `PASS` / `FAIL` / `N_A` verdicts per `verification:88-93`.
- Headings under `## GUIDES` produce `INFO` verdicts only — they cannot block a `READY` verdict.
- A project that wants to enforce a specific guide (e.g., its aesthetic forbids gradient text) opts in via `craft.json features.aesthetic.<name>.enforced_guides[]` listing the guide key (e.g., `G6.gradient-text`). Listed guides are treated as rules for that project only.

This split exists because the original file mixed perceptual / standards-backed invariants with one designer's taste manifesto. Both have value; they are not the same kind of claim.
