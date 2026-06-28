---
name: accessibility
description: Apply when building Flutter UI — Semantics labels, 4.5:1 contrast, touch targets, no color-alone signals, text scaling to 200%, reduced motion, RTL via EdgeInsetsDirectional, focus indicators, screen-reader announcements. Auto-invoke on any interactive widget or form field change.
---

# Flutter Accessibility

> Not a compliance checkbox — it's whether ~15% of users can use the app. Verify with screen reader on / eyes closed, not by eye.

## Semantics

- Every interactive element has a Semantics label describing the **action**, never the widget type (never `label:'Button'`). Prefer built-in widgets (`IconButton`/`InkWell` expose semantics free); custom → wrap in `Semantics`/`MergeSemantics`.
- Decorative icons/images → `ExcludeSemantics`; informative → `Semantics` with meaning + `image:true`. Set role flags (`button`/`header`/`checked`/`selected`).

## Contrast (verify with a tool, test both themes)

| Element | Min | vs |
|---|---|---|
| body (<18pt/14pt-bold) | 4.5:1 | bg |
| large text · icons/essential UI | 3:1 | bg |
| focus indicator | 3:1 | unfocused state |

Text on images → gradient scrim/solid layer. Disabled state: convey with more than color.

## Text scaling & bold

- Respect `textScaleFactor` (never hardcode); test 0.85/1.0/1.3/2.0×, must stay usable. Buttons grow vertically (`Flexible` + `maxLines:2`), never clip. Icons paired with text scale via `IconTheme`. `FittedBox` sparingly.
- Respect `MediaQuery.boldTextOf`; use relative weights so OS-bold applies.

## Reduced motion

Check `MediaQuery.disableAnimations`: remove decorative animation (stagger/hero/confetti/pulse), replace parallax/auto-scroll with static, keep functional transitions ≤150ms. The reduced experience must feel intentional, not broken.

## Screen readers & focus

- Every critical flow (auth, main action, checkout) completable with VoiceOver + TalkBack — test manually before shipping.
- Announce dynamic state via `SemanticsService.announce` with `TextDirection` ("Added to cart", "Loaded 12 items").
- Focus order matches visual reading order (use `FocusTraversalGroup`/`FocusTraversalOrder`, don't fight defaults). Every interactive element keyboard-focusable with a visible indicator (≥3:1); never remove without replacement. Modals: focus moves in on open, returns to opener on close; Esc/back closes; never trap focus outside a modal.

## Forms

Visible label (never placeholder-only) + matching Semantics label; required marked visually AND via Semantics hint; validation failures announced via `SemanticsService.announce`; errors attached to the field (read on focus); `autofillHints` set. (Touch-target sizing lives in `engineering`.)

## Media, RTL, hit-testing, platform

- Content images: descriptive Semantics label (what it conveys, not filename). Video/audio: captions + transcript; autoplay muted with accessible controls.
- RTL: `EdgeInsetsDirectional`/`AlignmentDirectional` (`.start`/`.end`); `matchTextDirection` for mirrorable icons; test a full Arabic/Hebrew locale (fonts/numerals/layout shift), not just a `textDirection` override; per-locale digits via `intl`.
- No invisible overlays intercepting touches; `IgnorePointer`/`AbsorbPointer` only intentionally; gesture regions stay within visual bounds.
- Use adaptive variants (`Switch.adaptive`, `*.adaptive`) for platform-correct a11y; don't force one platform's idiom on the other.

## Testing

`SemanticsTester` for labels/roles/flags; manually walk critical flows with screen reader on + eyes closed, keyboard-only, reduced-motion on, and text scale 2.0×. `flutter analyze` passing ≠ accessible.
