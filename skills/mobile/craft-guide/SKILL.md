---
name: craft-guide
description: Apply when designing, reviewing, or polishing mobile UI — typography, spacing, motion, state design, visual weight, navigation, information architecture. For any mobile framework (Flutter, React Native, SwiftUI, Compose). Tier-2 project contract — pairs with craft-invariants (Tier-1) and craft.json features.aesthetic (Tier-3).
requires:
  - craft-invariants
  - design-tokens
  - craft-config
---

# Premium Mobile Craft Guide

> Principles are firm; numbers are recommended defaults a project declares in tokens (what's enforced is that *one* scale exists and every value comes from it). Engineering requirements from `craft-invariants` (Tier-1) can't be skipped; design choices here can be questioned. Aesthetic specifics are Tier-3 INFO unless promoted via `craft.json`.

## Information architecture (do this first — the screen must deserve to exist)

- **One-sentence rule:** if you can't name a screen's single job in ≤5 words, merge or delete it.
- **No duplicate content:** the same data never lives on two tabs/siblings. Pick one home per piece of content. (Tab uniqueness test: two tabs sharing >50% content → merge.)
- **Each tab = one job;** 3–5 tabs max. Search lives *with* content, settings inside Profile. Tab roots are landing pages, not recycled push screens (no back button; rethink density).
- **No naked numbers:** every stat has a label/context ("3 of 12 lessons", not "📖 3"). Show each metric once, in its most useful place. Cut vanity metrics — make actionable or remove.
- **Hub & spoke:** hubs show just enough to choose (spacious); spokes show everything (dense). Actions live near their objects.

## Density & theme as identity

- **Density signature by screen type:** hub spacious · detail dense · settings/forms compact · creation minimal-chrome. Never give a hub detail-density or a form hub-spaciousness.
- **Each mode independently designed.** Dark ≠ inverted (depth via blur/luminance, not shadow; mid-tones carry weight). Light ≠ white (warmth, border subtlety). A screen looks intentional in *both*, not "correct in one, tolerable in the other."

## Perception & feedback

- Speed is a feeling: instant-start animation > shorter-after-delay; skeletons; optimistic UI (update now, reconcile silently); progressive disclosure.
- Never leave a touch unanswered: visual response ≤100ms → haptic ~10–50ms after (not simultaneous) → state change confirms. Cancel-on-pan reverts gracefully.
- Haptics by weight: `light` taps/toggles · `medium` confirm · `heavy` destructive/milestone · `selectionClick` pickers. Respect the user's haptic setting.

## Motion (default bands — declare as tokens)

- Micro 100–200ms · transitions 300–400ms · page sequences 400–600ms · list stagger 50–100ms/item.
- Entry `ease-out`, exit `ease-in`; prefer spring over tweens; no default `ease`.
- 3-layer stack: container (position/size) → content (opacity/scale, staggered) → details (icons/badges). Back-nav reverses the forward transition exactly. Reduced motion: drop decorative, cap functional ≤150ms.

## Color & typography

- State via temperature (cool inactive → warm active; error = desaturated red, not alarm). 60-30-10 (accent is precious).
- **Weight before size** for hierarchy; pass the squint test. Letter-spacing: tighter headlines, tracking on CAPS/small labels.
- Scale (default): body 16/1.5/400 · small 14/1.4 · label 12/1.3/600 (+0.08em caps) · title 18–20/1.3/600 · headline 24–28/1.2/700 · hero 32+/1.1/700. Never add a size between steps.

## State design

- Loading = skeleton matching final layout (not spinner); add value to long waits.
- Empty = invitation: illustration + human message + one action.
- Error = name what happened + concrete next step; never vague, never blame, never dead-end.
- **Sparse (1–3 items)** is its own state: anchor to top, don't center a lonely card in a void; a 1-item grid shows the item with presence, not a grid.

## Mobile patterns & platform

- Tap targets ≥48dp (44 floor iOS), ≥8dp apart; primary actions in the thumb zone; one-handed reach for core tasks; destructive → 3–5s undo.
- Respect platform conventions (iOS bouncy overscroll/swipe-back; Android glow/predictive back) — don't force one on the other. Never assume bounds (notch, island, home indicator, keyboard moves content, not hides it).

## Navigation & continuity

- Back is not exit: in a tabbed app, back goes home before leaving; only the home tab exits. Sheets absorb back while visible. Every route handles being the cold-start entry point.
- **Data continuity:** an edit on a detail screen reflects on the parent list immediately on back — no stale cards, no "pull to refresh to see your own change."

## Visual system (Tier-2 contract — declare specifics in tokens)

One base unit (default 8, multiples of 4 allowed) · named radius scale with role mapping (default 4/8/12–16) · role color tokens (default 1 primary + 1 secondary + 6 neutral + 3 semantic; tertiary/per-feature accents must be explicit) · named elevation scale ≥2 levels (premium-mobile default = 1px border at 8–12% over drop shadows, but Material 3 shadows are correct too — project's call).

## Contextual awareness

Design for day-1 (orientation) and day-100 (speed), then make them coexist. Adapt to progress (beginner sees encouragement, power user sees efficiency) and content volume (layout breathes at 1 *and* 200 items). Fresh items feel fresh; old items feel patient, not stale.

## Checklist

- [ ] Every screen names its one job; no content duplicated across tabs; tab roots designed as landing pages
- [ ] Every visible number has a label; no vanity metrics
- [ ] Density matches screen type; intentional in both light and dark
- [ ] Tap → instant response; loading/empty/error/sparse states all designed
- [ ] Targets ≥48dp; back gesture returns home (not eject); edits reflect on back
- [ ] Motion uses token durations + 3-layer stack; reduced motion still feels designed
- [ ] Every color/size/spacing traces to the design system
