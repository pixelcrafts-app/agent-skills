---
name: observability
description: Apply when adding logging, analytics, or crash reporting to a mobile app — one logger, structured events, level thresholds by build mode, crash hooks, PII discipline, consent. Auto-invoke on observability/logging/analytics code.
---

# Mobile Observability

> One logger, structured events, never PII. Branch behavior on `kDebugMode`/`kReleaseMode`, never runtime env reads.

## Logging

- **One logger** wrapper, one import path. `print()` only in `main.dart` init, debug only — never in feature code.
- **Event names** are stable, dot-separated `<domain>.<object>.<action>` (`auth.session.expired`), kept in a constants file. Structured context map, never string concatenation. Never log in 60fps paths.
- **Levels:** `trace/debug` (dev flow) · `info` (significant events) · `warn` (recoverable) · `error` (user-facing failure) · `fatal` (crash/corruption).
- **Thresholds by build mode** — excess logging costs money and buries signal:

| Build | → console | → remote sink |
|-------|-----------|---------------|
| Debug | `trace`+ | disabled |
| Profile | `debug`+ | disabled |
| Release | none | `warn`+ |

## Crash reporting

- Both hooks required: `FlutterError.onError` (forward to `presentError` in debug) and `PlatformDispatcher.instance.onError` (return `true`).
- Report: all unhandled exceptions; caught-but-unexpected as non-fatal; release `assert` failures as non-fatal; breadcrumbs (navigations, state transitions, API calls without payloads).
- **Triage:** review new crashes <24h; >1% sessions → hotfix; ≤1% → next release; every crash → ticket with an owner. Target 99.9% crash-free (track the trend).

## Analytics

- Events `<domain>.<object>.<action>`, lowercase, stable, in one constants file. Never rename (deprecate + add). Keep under ~500 distinct names.
- <10 properties/event; strings/numbers/booleans only; enumerated values, not free-form. User properties (persist: `plan`, `cohort`) vs event properties (`source`, `position`) — don't duplicate.
- Don't track noise (scroll, every tap, re-renders). Rule: if you can't finish "we need this to answer ___", don't add it.

## PII discipline

| Category | Log | Crash | Analytics |
|----------|-----|-------|-----------|
| Direct ids (email, phone, name, address) | never | never | never |
| Internal UUID | if needed for correlation | yes (correlation) | yes (user-level) |
| Ad ID (IDFA/GAID), precise GPS | never | never | never |
| User content (messages, photos, notes, search) | never | never | never |
| Behavioral (screen, tap, flow) | yes | breadcrumbs | primary |
| Technical (OS/app version, network, model) | yes | yes | yes |

Never anywhere: auth tokens, passwords, API keys, full request/response bodies.

## Consent, retention, correlation

- Analytics = **opt-in** in GDPR regions; crash reporting may be opt-out but disclosed. In-app toggle honored immediately (stop + flush). Track consent state anonymized.
- Retention: logs ~30d, crashes ~90d, analytics per policy. Route EU traffic to EU regions; honor delete/export DSRs; keep store privacy labels in sync.
- **Trace ID** (UUID v4) per outbound request → header + that request's logs + any resulting crash. **Session ID** per launch → all events/logs/crashes (answers "what happened right before the crash?").

## Checklist

- [ ] One logger; no `print()` in features; no logging in 60fps paths
- [ ] Levels gated by build mode (no debug/info to prod sink)
- [ ] Both crash hooks wired; context attached, never PII
- [ ] Event names stable + centralized; <10 enumerated properties
- [ ] Consent flow in GDPR regions; toggle respected
- [ ] Trace + session IDs propagated
