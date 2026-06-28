---
name: premium-signals
description: Reference catalog of precise design values from shipped premium products (Linear, Vercel, Superhuman, Arc, Raycast, Stripe, Things 3). INFO-only — documented references, not enforced rules. Opt in per project via craft.json features.aesthetic.<name>.enforced_signals[].
verdict_mode: INFO_ONLY
requires:
  - verification
---

# Web Premium Signals (reference catalog)

> **INFO-only.** `verify-changes` never FAILs on these. They're precise values from one design lineage (Linear/Vercel/Stripe/etc.) — a Material 3 or brutalist app will correctly violate many. Enforce specific entries via `craft.json features.aesthetic.<name>.enforced_signals[]`.

## Shadow & depth

- **Two-layer shadow** (never single), tinted to surface hue not pure black: light `0 1px 2px rgba(0,0,0,.05), 0 4px 12px rgba(0,0,0,.08)`; dark `…,.20 / …,.30`. Warm surface → +3–8% red in shadow.
- **Border as structure:** dark `1px solid rgba(255,255,255,.08)` (exactly 8%); light `var(--gray-200)`, never `#ccc`.
- Elevation via 3–5% warmer hue shift (not just lightness) on hover/dropdown surfaces. Inactive sidebar items `opacity:.65`, content full.

## Color & dark mode

- **5-step dark gray elevation** (lighter = nearer): base `hsl(240 5% 6%)` · raised `8%` · elevated `10%` · overlay `12%` · top `14%`. 2–3 grays flattens everything.
- Contrast compensation: light `black @60%` → dark `white @65%` (eyes perceive less contrast in low light); calibrate each text role, not one inversion.
- Accent recalibration: darken light-mode accent ~L−5–8% for dark mode. **One accent, one place** (primary CTA only — not hover/focus/borders). Never default blue (`#0070f3`/`#0000EE`).
- **OKLCH tokens** (perceptually uniform, P3): `--primary: oklch(55% .22 262)`, hover `+5% L`, muted `/ .15`. 3-layer architecture: primitives → ~35–50 semantic → component overrides only when semantic can't express. Never style against primitives.
- Hue-shift states: error −10° toward red, success +20° toward green (shift hue, not just lightness).

## Motion

- Primary easing `cubic-bezier(0.16, 1, 0.3, 1)` (expo-out) for productivity UI; springs/bounce for playful only.
- Three durations: `200ms` hover/press · `300ms` transitions · `600ms` entrances. Never one duration for all.
- Sub-100ms response guarantee (optimistic updates — UI responds before server). Hover displacement cap `8px`, translate OR scale not both.
- Skeleton shimmer: 3 stops `.1/.3/.4` opacity, horizontal, `1.5s ease-in-out`, shaped like incoming content. Completion ceremony 200–300ms (+50ms hold) for meaningful actions; ≤150ms no-ceremony for toggles.

## Typography

- Body: dense tools `14px/1.5`, consumer `16px`. Display 48px+: `letter-spacing:-0.04em; line-height:1.15`. Monospace for data (timestamps/IDs/metrics/code). `tabular-nums` is a hard requirement on any number that animates, columns, or is time/currency/metric.

| Size band | Tracking | | Context | Font |
|---|---|---|---|---|
| caps/small | +.02 to +.04em | | SaaS/productivity | Inter |
| body 14–18 | 0 | | Vercel/dev tools | Geist |
| sub 20–32 | −.01em | | marketing/brand | Söhne |
| display 40–64 | −.025 to −.04em | | editorial | DM Serif + Inter |
| hero 64+ | −.04 to −.05em | | data/technical | Geist/Berkeley Mono |

Never a system fallback in a display role; never two similar sans families.

## Layout & grid

- **4px base grid** (allows 4/8/12/16/24/32/48 half-steps). **Tiered radius** (one global value is the #1 template tell): inputs/chips `4–6` · buttons `8` · cards/modals `12` · large/sheets `16` · pills `9999`.
- Hit-target generosity: control can *look* 28px while having 44px click area via padding.

## Aesthetic precision values

- **Glass (overlay only):** `backdrop-filter: blur(12–20px)` + `bg rgba(255,255,255,.06–.12)`; never a card style; text needs solid layer or bg-opacity ≥.5.
- **SVG noise** 3–5% opacity (`feTurbulence`) over gradients — kills banding, reads printed not rendered.
- **Bento:** `grid-auto-rows:90px`, gap 12–20, radius 16–24, hover scale `1.02`+depth `200ms expo-out`, ≤4 tile sizes.
- **Minimalist:** ≤2 brand colors + neutrals + 4 semantic; whitespace ≥40%; ≤3 weights; one signature detail/screen.
- **Utility-brutalist:** dark-first, single accent hue, mono metadata, motion `150ms` bg/border only (no row entrances), border-as-elevation `rgba(255,255,255,.08)`.
- **Dark luxury:** bg `#0D0D0D`/`#111`, section padding `64px`, one metallic accent (`oklch(75% .12 80)` gold), accent in one role only.

## State precision

- **Empty state** = monochrome illustration (stroke matched to icon system, never stock/3D/AI clipart) + one sentence (names what's missing + benefit) + one specific-verb CTA (not "Get started").
- **Command palette:** `Cmd/Ctrl+K`, dark modal 60–70% width, mono result metadata, accent-highlighted match chars, recents before query, executes without confirmation.
