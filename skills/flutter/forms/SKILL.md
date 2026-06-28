---
name: forms
description: Apply when building mobile forms — field anatomy, keyboard types, autofill, validation timing, error display, focus, submission, multi-step, state preservation. Auto-invoke when writing form screens.
---

# Forms

## Field anatomy

Label (visible, above — never placeholder-only) → required/optional marker (with `Semantics`) → input → helper text → error text (replaces helper in the same position, never stacked).

- Labels above, start-aligned, concise, sentence case. Required fields get a visible indicator; mark "Optional" in long forms.
- Placeholders show a **format example**, not the label; <40 chars; meet contrast; never the only label.

## Keyboard, autofill, action

Match `keyboardType` to input (never default `text` when a specific type fits):

| Field | keyboardType | + |
|---|---|---|
| email | `emailAddress` | `autofillHints:[email]` |
| phone | `phone` | `[telephoneNumber]` |
| integer | `number` | `digitsOnly` formatter |
| decimal | `numberWithOptions(decimal:true)` | |
| password | `visiblePassword` | `obscureText`, `[password]` (signup: `newPassword`) |
| name | `name` | `[name]`/`givenName`/`familyName` |
| address | `streetAddress` | `[streetAddressLine1]` |

- **Always set `autofillHints`** (password managers depend on them); wrap related fields in `AutofillGroup`.
- Set `textInputAction` per field: `next` intermediate, `done`/`send`/`search` final; `onFieldSubmitted` advances focus or submits.

## Focus & keyboard handling

- `autofocus` only when the form is the screen's primary purpose. Declare `FocusNode`s at form level; create in `initState`, dispose in `dispose` (never leak).
- Wrap body in `SingleChildScrollView`/`ListView`; keep `resizeToAvoidBottomInset:true`; `Scrollable.ensureVisible` on focus; lift fixed bottom actions with `viewInsets.bottom`. The keyboard must never cover the focused field.

## Validation

- **On submit** (minimum) + **on blur** (good). **On change** only for password strength, confirmation match, format-as-you-type. **Never on focus** (hostile).
- Validators are pure (`null` valid / `String` error); compose them; async checks show a separate loading state and don't block submit; server errors attach to the relevant field, not a global banner.
- Error messages: specific ("Email must contain @"), actionable ("Password must include a number"), non-blaming, plain language.

## Submit & errors

- Action-labeled button ("Create account", not "Submit"), disabled until required fields valid; inline loading during submit (not full-screen). On success navigate/confirm; on error keep all input, show a specific message, focus the first invalid field, announce via `SemanticsService.announce`. Field error → on the field; form error ("Account exists") → banner; network error → banner + retry.

## Multi-step, specialized, preservation

- Multi-step: progress indicator, validate per step, back preserves data, autosave drafts (>3 steps), review step before final submit.
- Date/time → pickers (never free text). Dropdowns: <7 → segmented/radio, ≥7 → searchable sheet. Checkboxes wrap a tappable label. Password show/hide + strength on signup only.
- Preserve state across tabs (`PageStorageKey`), rotation, backgrounding; debounced autosave for long forms; prompt save/discard on navigate-away — never lose silently.
- Destructive ("Delete account"): two-step (confirm dialog requiring typed word or password); safe action is the dialog's primary button.
