---
name: craft-guide
description: Apply when designing, reviewing, or polishing web UI — color, spacing, type, shadow, radius, motion, state design, responsive density, aesthetic coherence, iconography, chrome, theme, microcopy, brand moments. Cross-framework; examples use Tailwind/shadcn idioms but rules are framework-neutral. Tier-2 project contract — pairs with craft-invariants (Tier-1 universals) and craft.json features.aesthetic (Tier-3 taste).
requires:
  - craft-invariants
  - craft-config
---

# Premium Web Craft Guide

> Rules below are firm; numeric values are **recommended defaults** — a project declares its own via tokens, and what's enforced is that *one* declared scale/token exists and every code value resolves to it. Rules keep stable `§N.M` IDs that `verify-changes` / `pre-ship` iterate.

**Three tiers:** Tier 1 `craft-invariants` (WCAG/CSS/typography universals — PASS/FAIL) · Tier 2 this file (the project's design system — enforce *declaration + adherence*, values are the project's call) · Tier 3 `craft.json features.aesthetic` (aesthetic specifics — INFO unless promoted).

---

## §0 Visual System Foundations (default values — declare your own in tokens)

- **§0.1 Base unit:** one unit (commonly 4 or 8); every spacing value is a multiple. Default 8px + 4px half-steps.
- **§0.2 Breakpoints:** 3–5 monotonic min-widths. Default `375 / 768 / 1280 / 1536`.
- **§0.3 Content max-widths** per surface: standard `1200` / reading `720` / focused `480`.
- **§0.4 Column gutters:** mobile `16` / tablet `24` / desktop `32`.
- **§0.5–0.6 Type scale** in `rem`; named steps only, no intermediates (differentiate by weight, not a new size).

| Step | rem | LH | Wt | Role |
|---|---|---|---|---|
| xs | .75 | 1.4 | 500 | labels/captions |
| sm | .875 | 1.5 | 400 | body-small/helper |
| base | 1 | 1.6 | 400 | body |
| lg | 1.125 | 1.5 | 400 | lead |
| xl | 1.25 | 1.4 | 600 | card titles |
| 2xl | 1.5 | 1.3 | 600 | section headings |
| 3xl | 1.875 | 1.2 | 700 | page headings |
| 4xl+ | 2.25+ | 1.1 | 700 | hero/display |

- **§0.7 Color slots:** 1 primary, 1 secondary, neutral 50–900, 4 semantic (`error/success/warning/info`). Map new needs to an existing slot.
- **§0.8 Elevation** (≥2 levels; web default 3): flat `none` · card `0 1px 3px rgba(0,0,0,.12)` · dropdown `0 4px 16px rgba(0,0,0,.16)`. Use `box-shadow`, never `filter: drop-shadow()`.
- **§0.9 Interactive states** (every interactive role): hover surface ±~8% + `cursor:pointer`; focus `2px outline / 2px offset / primary` (never remove); active `scale(.98)` ~80ms; disabled `opacity .4 + not-allowed + pointer-events:none`.
- **§0.10 Dark mode** is designed independently: no pure-`#000` surfaces (warm near-black), no pure-`#fff` text (~87% / off-white), elevation reversal (higher = lighter surface), contrast audited separately. Replace shadows with `1px` ~12%-white border.

## §1 Color
- §1.1–1.6 Contrast: body ≥4.5:1 · large (18pt/14pt-bold) ≥3:1 · non-text UI ≥3:1 · placeholder ≥4.5:1 · dark mode verified separately · APCA Lc ≥75 body (premium).
- §1.7 One color-harmony relationship (complementary/analogous/triadic/split-comp/mono), not mixed. §1.8 60-30-10 distribution. §1.9 UI primary derived from brand color (saturation back 10–20%), not raw brand on surfaces. §1.10 Neutrals hue-tinted 5–15% sat, not pure gray. §1.11 Gradients ≤3 stops, same/analogous hue, never complementary. §1.12 Pure black/white only in OLED-dark or brutalist. §1.13 Tokens only, no hardcoded hex/rgb. §1.14 ≤3 accents/screen. §1.15 Color never the sole signal.

## §2 Spacing
- §2.1 Single base unit, every value on scale. §2.2 No arbitrary values (`p-[13px]`). §2.3 Same scale for margin/padding/gap. §2.4 Touch targets ≥44px (≥48 premium). §2.5 ≥8px between adjacent targets. §2.6 `gap` for layout inside flex/grid, not margin.

## §3 Typography
- §3.1 Every size on one modular scale (ratio: 1.125 dense · 1.25 default · 1.333 expressive · 1.5 editorial · 1.618 dramatic). §3.2 `rem` for font-size. §3.3 ≤2 typefaces (contrast, not similarity). §3.4 No skipped heading levels. §3.5 LH by band (body 1.5–1.7, display 1.0–1.1). §3.6 Letter-spacing (negative display, positive caps/small). §3.7 Body measure 45–75ch. §3.8 `font-display:swap`. §3.9 preload above-fold fonts. §3.10 Fallback metrics matched (`size-adjust`/`ascent-override`) — no CLS. §3.11 `tabular-nums` on numbers/money/time. §3.12 UGC `line-clamp`. Prefer variable fonts, self-host (`next/font`).

## §4 Shadow & Elevation
- §4.1 Every shadow from the named scale (3–5). §4.2 Multi-layer composition, not single-layer. §4.3 Dark-mode adapts (more alpha or switch to border/luminance depth). Alternatives to shadow: layered opacity, subtle borders, temperature shift.

## §5 Border Radius
- §5.1 Every radius from a named scale (`0/4/8/16/24/full`). §5.2 Consistent per role. §5.3 Nested math: inner = outer − padding. §5.4 Scale matches aesthetic (brutalist 0 · material 8–12 · bento 16–24 · clay 40–60).

## §6 Motion
- §6.1 Named duration scale (≥3 tiers; default micro 150–250 / macro 300–500 / page 500–800 ms; >800 needs narrative reason). §6.2 Exit slightly faster than entry. §6.3 Entry `ease-out`, exit `ease-in`. §6.4 No default `ease` — named easing tokens. §6.5 Animate only `transform`+`opacity` on hot paths. §6.6 Respect `prefers-reduced-motion` (strip travel, keep state change). §6.7 3-layer stack (container → content → details), not all at once.

## §7 State Design (every data surface; missing one is a bug)
- §7.1 Loading = skeleton matching layout (not spinner). §7.2 Skip skeleton <200ms. §7.3 Empty = icon + invite + single CTA. §7.4 Error = specific + actionable + retry (never "Error occurred", never blame user). §7.5 Content. §7.6 Offline (queue + sync, cached still readable). §7.7 Stale/background-refresh. §7.8 Partial/progressive. §7.9 Pending (optimistic + silent rollback for non-critical; in-button spinner for critical). §7.10 Rate-limited (countdown). §7.11 Permission-denied (distinct from error). §7.12 Success (inline 2–3s small; full-screen for milestones). §7.13 Destructive confirmed or undo-able. §7.14 Disabled (opacity ≥.4 + not-allowed + reason tooltip). Sparse state (1–3 items) anchors top, isn't a lonely card in a void.

## §8 Responsive + Density
- §8.1 Mobile-first. §8.2 No horizontal overflow at 320px. §8.3 Safe-area insets (`env(safe-area-inset-*)`) on fixed bars/full-bleed/modals. §8.4 `dvh` not `vh` where keyboard opens. §8.5 Density matches app type. §8.6 Tablet ≠ bigger mobile. §8.7 Primary actions in thumb zone. §8.8 Constrain content ≤~1920px.

Density by app type: content-heavy/forms → high & tight · tool/dashboard → medium · consumption/marketing → low & generous. Detect: what does the user come to do, would they trade whitespace for content, how long is a session.

## §9 Aesthetic Coherence
- §9.1 Commit to ONE aesthetic (declare `craft.json features.aesthetic.active`); **never mix two** (#1 "assembled not designed" tell). §9.2 Honor that aesthetic's specs. §9.3 If glass: text legibility strategy (solid layer OR bg-opacity ≥.5). §9.4 If glass: `prefers-reduced-transparency` fallback. §9.5 Per-aesthetic numbers are Tier-3 INFO unless promoted.

Aesthetic spec ranges (Tier-3 examples): **glass** blur 8–24px, bg-opacity .1–.3, hairline border · **clay** radius 40–60px, triple-layer shadow, sat 40–65% / light 70–85% · **bento** radius 16–24, 2–4 tile sizes, per-tile hover · **neumorph** dual shadow, interactive-only, ruthless contrast audit · **utility-brutalist** mono accents, dense tables, dark-first, minimal motion · **editorial** ratio ≥1.5, measure 55–70ch, contrasting type pair · **minimalist** ≤2 brand colors, ≤3 weights, whitespace ≥40%.

## §10 Iconography
- §10.1 One icon family. §10.2 All stroke OR all fill. §10.3 Stroke weight matches body weight. §10.4 Fixed size scale (16/20/24/32). §10.5 `currentColor`, not hardcoded. Pair with text via optical alignment + consistent `gap`. Icons (functional) ≠ illustrations (emotional).

## §11 Chrome & Details
- §11.1 Visible custom focus ring (never `outline:none` unreplaced). §11.2 `:focus-visible` not `:focus`. §11.3 Custom `::selection`. §11.4 Styled scrollbar where visible (never hide overflow indicators). §11.5 `caret-color` on inputs. §11.6 `cursor:pointer` on clickable non-links. §11.7 Inline loading (in-button), not full-page. §11.8 `-webkit-font-smoothing` per project choice (Tier-3). §11.9 Images: fixed aspect ratios, lazy-load, blur-up.

## §12 Accessibility (craft, not just compliance)
- §12.1 Semantic HTML (no `<div onClick>` where `<button>` fits). §12.2 One `<h1>`, no skipped levels. §12.3 Modal focus trap (Tab cycles, Esc closes, focus returns). §12.4 Tab order matches visual order. §12.5 `role="status"`/`alert` on live regions. §12.6 Meaningful `alt` or `alt=""`. §12.7 `color-scheme` set. §12.8 `forced-colors` honored. §12.9 `prefers-reduced-transparency` honored. §12.10 `<html lang>`. §12.11 Color-blind safe.

## §13 Theme
- §13.1 Every themeable value from CSS var / `@theme`. §13.2 Semantic token names (`--surface-muted`, not `--blue-500`). §13.3 Light & dark independently designed (not computed invert). §13.4 SSR hydration flash prevented (blocking script / cookie; `next-themes` + `suppressHydrationWarning`). §13.5 `color-scheme` per theme class. Prefer OKLCH (HSL acceptable). Audit: toggle theme, scroll every screen for untokenized backgrounds/borders/embeds.

## §14 Content & Microcopy
- §14.1 Button labels are verbs ("Save changes", not "OK"). §14.2 Errors explain + suggest. §14.3 Empty states invite. §14.4 Confirmations name the action ("Delete 3 items?"). §14.5 Success understated ("Saved."). §14.6 Loading text specific. §14.7 No jargon (HTTP codes, stack traces) in UI. §14.8 Localize numbers/dates/currency. §14.9 Labels above fields for forms >3 fields. §14.10 Placeholder is example, not label. Pick sentence vs title case and commit.

## §15 Brand Moments (whole-app, audit only on these surfaces)
- §15.1 404 on-brand + useful actions. §15.2 500 apologetic + retry + support. §15.3 Splash branded (not generic spinner). §15.4 Offline branded (not browser error). §15.5 First-run empty state designed as a moment.

---

**Final verdict (after §0–§15 pass):** one harmony, one aesthetic, one base unit, one type scale, ≤2 typefaces; every value traces to a token; all 4 primary states + relevant edge states present; works 320→2560px; focus visible everywhere; dark mode independently correct. Any "no / not sure" → unfinished.
