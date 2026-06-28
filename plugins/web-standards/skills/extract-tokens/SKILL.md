---
name: extract-tokens
description: Extract the project's design tokens (color, type, spacing, radius, shadow, motion) from codebase or design inputs into one source-of-truth file. Run before any craft audit — the audit needs the user's tokens to check against. Never imposes values.
argument-hint: [path-to-design-input | "from-codebase" | "from-figma-url"]
---

# Extract Tokens (web)

The craft audit checks against the project's tokens; this skill establishes them. **Never invent values — read, then ask.**

## Mode 1 — From codebase (default)

Scan, in order, what the project already declares (read, don't infer): Tailwind config `theme.extend.{colors,fontFamily,fontSize,spacing,borderRadius,boxShadow}` → Tailwind v4 `@theme` in globals.css (authoritative if present; ignore defaults) → `:root`/`.dark` CSS custom properties → `components/ui/*` usages → committed Figma/Tokens-Studio JSON → the project instructions file.

Categorize into six dimensions: **Color** (brand, UI primary, neutral ladder + tint hue, semantic, surfaces, borders, text) · **Typography** (display/body/mono families, size scale + ratio, weights, line-height bands) · **Spacing** (base unit, scale, container max-widths) · **Radius** (scale + role map) · **Shadow** (elevation scale, multi-layer?) · **Motion** (durations, easings).

Flag missing dimensions (no shadow scale → per-component hardcoding; no semantic colors → hardcoded `#FF0000`) as candidates — ask, don't invent.

**Drift detection** — grep for values that should be tokens, count per category, list top-10 with `file:line`:
```
rg "#[0-9a-fA-F]{3,8}"  rg "hsl\(" rg "rgba?\("   # inline color
rg "\[[0-9]+px\]"                                  # arbitrary Tailwind p-[13px]
rg "box-shadow:" --type css                        # non-token shadow
rg "transition-duration: *[0-9]"                   # inline motion
```

## Mode 2 — From design input
User passes a file/image/Figma-export/brand-PDF/pasted values. Parse to the six-dimension map (image → k-means 5–7 colors as *candidates*; export JSON → normalize keys; PDF → stated hex/type/spacing). If the codebase already has tokens, **diff and surface conflicts** ("brand.pdf `#3A6FE0` vs config `hsl(222 80% 55%)` — which wins?"). Never silently overwrite.

## Mode 3 — From Figma URL
A Figma connector isn't part of this pack — use one if the project has it configured; otherwise ask the user to export (`Tokens Studio → Export`) and use Mode 2. Never scrape rendered Figma pages.

## Output — `design-tokens.md` (project root, or `docs/` if it exists)

```markdown
# Design Tokens — source of truth for the craft audit. Generated <date> from <source>.
## Aesthetic / Density target: <detected or user-declared>
## Color: brand, UI-primary, neutrals (tint hue), semantic, surfaces; Light/Dark pairs table
## Typography: display/body/mono, base + ratio + steps, weights, line-heights
## Spacing: base unit, scale, container max per breakpoint
## Radius: scale + role map (buttons/cards/modals/avatars)
## Shadow: elevation scale (multi-layer CSS per token)
## Motion: durations (micro/macro/page), easings (entry/exit/spring)
## Drift report: missing dimensions; inline violations (count + top-10 file:line)
## Verification: [ ] user confirmed hues [ ] aesthetic+density [ ] missing-dimension defaults
```

Other web skills (`craft-guide`, `premium-check`) consume this file when present.

## Refuses to (unless explicitly asked, then surface each default as "I chose X because Y")

Pick brand/UI/neutral colors the user didn't give · pick an aesthetic (detect + ask) · pick a density (ask app type) · rewrite `tailwind.config`/`globals.css` · overwrite declared tokens. Color extraction from images is approximate — always confirm. Generate once, then human-maintain; re-run on material brand change, not per-commit.
