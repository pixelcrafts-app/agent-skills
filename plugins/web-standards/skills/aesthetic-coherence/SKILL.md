---
name: aesthetic-coherence
description: Detect aesthetic mixing — a screen committing to two design languages at once (glass + neumorphism, bento + brutalist) is the #1 "assembled, not designed" tell. Scores each aesthetic's signals, flags mixed signatures, then hands per-aesthetic spec compliance to the audit engine. Use on a surface that feels "off" but passes token/contrast audits.
argument-hint: [component-file-path | page-path | "app"]
---

# Aesthetic Coherence Audit (web)

Detection is a signal-scoring pass (classification, not compliance). Spec compliance is delegated to the engine (`craft-guide:aesthetic-coherence`).

## Step 0 — Inputs
Read `$ARGUMENTS` (file/page/app; if app, enumerate routes under `app/` or `pages/`). Read `design-tokens.md` for a declared aesthetic.

## Step 1 — Score each aesthetic's fingerprint per file

- **Minimalist** — no `backdrop-filter`, ≤2 shadow levels, ≤2 brand colors, high whitespace, small radius, no decorative gradients.
- **Flat** — zero shadows, solid fills, 1px token borders, no effects.
- **Material** — ≥3 shadow levels, elevation, ripple motion, FAB.
- **Utility-brutalist** (Linear/Vercel) — `font-mono` metadata, rule-heavy tables, dark-first, single accent, minimal motion, tinted neutrals.
- **Glassmorphism** — `backdrop-filter: blur`, bg alpha .1–.3, hairline alpha borders, layered translucency.
- **Neumorphism** — dual offset shadows on same-surface color, no border/fill, interactive elements.
- **Claymorphism** — radius >16px, soft-saturated fills, inner+outer shadow, playful vocabulary.
- **Liquid Glass** (iOS 26) — backdrop-filter + animated specular, spring motion, morphing translucent chrome.
- **Bento** — grid with varying `col/row-span`, uniform radius 16–24, per-tile hover, ≤4 tile sizes.
- **Editorial** — type ratio ≥1.5, serif/two-sans pair, measure 55–70ch, visible grid.
- **Brutalist** — pure `#000`/`#fff`, system/mono fonts, radius 0, no shadow, asymmetry.
- **Dark-cinematic** — true/near-black bg, graded color, glow/bloom, image/video-forward.
- **AI-native** — animated mesh gradients, 3D orbs, particle motion, dark + bright bloom.
- **Retro/Y2K** — chrome gradients, pixel fonts, skeuomorphic icons.

## Step 2 — Classify per file
Take the top-2 scores. Large gap → **COMMITTED** (healthy). Gap ≤30% → **MIXED** (FAIL vs single-aesthetic rule). No strong signal → **UNCLEAR** (not necessarily a fail). Output dominant/secondary/gap/verdict + `file:line` evidence per signal.

## Step 3 — Cross-file coherence
Aggregate per-file verdicts; flag outliers committed to a different aesthetic than the app. Cross-file mixing (a glass modal in a brutalist app) is worse than in-file and is a FAIL.

## Step 4 — Delegate compliance (once dominant aesthetic is known)
```
verify-changes brief:
  scope: <COMMITTED/MIXED files>
  dimensions: [craft-guide:aesthetic-coherence]
  depth: direct
  fix: no
  context: { aesthetic: <dominant or user-confirmed> }
```
**Aesthetic choice is user taste** — if UNCLEAR or conflicting, ask before delegating. Never run compliance against a guessed aesthetic.

## Step 5 — Report
Detection (app aesthetic vs declared, mixed files, outliers) + engine's per-rule PASS/FAIL. Verdict: 0 mixed/outliers/fails → COHERENT · any mixed/outlier → FRAGMENTED · only rule fails → COMMITTED-BUT-UNFINISHED.

## Step 6 — Fix loop (never automatic)
Aesthetic fixes are high-blast-radius. Propose which aesthetic to keep (strongest signal default), list exact per-file changes, wait for confirmation per file, apply only confirmed, re-run Steps 1–3. Never `fix: yes` — taste is not a rule-driven auto-fix.
