---
name: accessibility
description: Implement and audit WCAG 2.2 Level AA across Web, iOS, and Android — semantic ARIA, Swift accessibility traits, Compose semantics for any UI component.
origin: ECC
---

# Accessibility (WCAG 2.2 AA)

> Use the most semantic native element first (`<button>` over `<div role="button">`). Then apply POUR.

## POUR

- **Perceivable** — contrast 4.5:1 text / 3:1 large+UI; alt text for images, `aria-label` for icon-only controls; full function at 400% zoom with no horizontal scroll.
- **Operable** — target size 24×24 CSS px (Web, SC 2.5.8) / 44×44pt (native); everything keyboard-reachable with a visible focus indicator (SC 2.4.11); always a single-pointer alternative to dragging.
- **Understandable** — consistent navigation; text error messages with a correction suggestion (SC 3.3.3); never ask for the same data twice in a flow (SC 3.3.7).
- **Robust** — Name/Role/Value on every interactive element; dynamic updates via `aria-live` (`polite` non-urgent / `assertive` urgent).

## Cross-platform attribute map

| Feature | Web (ARIA) | iOS (SwiftUI) | Android (Compose) |
|---|---|---|---|
| Label | `aria-label`/`<label>` | `.accessibilityLabel()` | `contentDescription` |
| Hint | `aria-describedby` | `.accessibilityHint()` | `semantics { stateDescription }` |
| Role | `role="button"` | `.accessibilityAddTraits(.isButton)` | `semantics { role = Role.Button }` |
| Live region | `aria-live="polite"` | `.accessibilityLiveRegion(.polite)` | `semantics { liveRegion = Polite }` |

Icon-only control example: web `<button aria-label="Submit search"><svg aria-hidden="true">` · iOS `Image(systemName:"trash").accessibilityLabel("Delete item").accessibilityHint("Permanently removes…")` · Android `Switch(modifier = Modifier.semantics { contentDescription = "Enable notifications" })`.

## Anti-patterns

| Wrong | Right |
|---|---|
| `<div onclick>` | `<button>` (or `role="button" tabindex="0"` + keydown) |
| color-only error (red border) | color + icon + text |
| modal without focus trap | `aria-modal` + trap + Esc-to-close |
| "Image of a dog" | "Golden retriever puppy playing fetch" |
| focus lost after modal close | restore focus to the trigger |

## Pre-ship checklist

- [ ] Targets ≥24×24px web / 44×44pt native; focus indicators visible + high-contrast
- [ ] Modals trap focus then release; dropdowns restore focus to the trigger
- [ ] Text error messages with a correction hint; icon-only buttons labeled
- [ ] Text scales to 200% without loss / 400% without horizontal scroll
- [ ] Dynamic updates announced via live regions
