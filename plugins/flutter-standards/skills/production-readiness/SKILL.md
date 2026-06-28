---
name: production-readiness
description: Apply when auditing a mobile app for production readiness — retry + backoff, app lifecycle, deep links, push permission UX, force-update gate, secure storage, locale/RTL, offline + sync, env-aware logging. Detect → Check → Suggest. Auto-invoke when reviewing app-level wiring, service layer, or release readiness.
---

# Flutter Production Readiness

> None universally required — depends on surface area, regulation, deployment. **Detect → Check → Suggest, never rewrite the app.** Skip what doesn't apply (single-locale B2B needs no RTL); flag "not yet" so it isn't missed at launch.

| § | Concern | Key checks | If absent (suggest) |
|---|---------|-----------|---------------------|
| R1 | Retry + backoff | bounded ≤3, exponential + jitter, idempotent-only, never on 4xx; visible retry for user ops | `dio_smart_retry`; warn retry+no-idempotency = duplicate payments |
| R2 | App lifecycle | `paused` flushes pending mutations, `resumed` refreshes stale data, `detached` cleans up; never pause sync on `inactive` (fires on Face ID) | single `LifecycleObserver`; without flush, in-flight mutations lost on OS kill |
| R3 | Deep links | cold-start resolves, auth-gated redirects then continues, malformed → graceful error, server manifests (`AASA`/`assetlinks`) verified | `go_router` + platform config; client-only setup just opens the browser |
| R4 | Push permission | pre-prompt rationale, deferred past first launch (after value), settings re-enable path | `NotificationPermissionFlow`; cold-start prompt kills opt-in |
| R5 | Force-update gate | distinct soft/hard states, store link, correct build-number compare, runs before auth/API | `VersionGate` at root; else a breaking API orphans old clients |
| R6 | Secure storage | tokens/refresh/keys in `flutter_secure_storage` (never Hive/Prefs), iOS `first_unlock_this_device`, Android `encryptedSharedPreferences:true` | `SecureStorageService`; tokens in Prefs = compliance finding + attack surface |
| R7 | Locale + RTL | no hardcoded strings (`AppLocalizations`), `intl` formatting, `EdgeInsetsDirectional`, mirrored icons, RTL verified in a build | `flutter_localizations` + `.arb`; single-locale → note tradeoff, skip |
| R8 | Offline + sync | cached reads with explicit stale/empty states, mutations queue + flush with idempotency keys, defined conflict strategy, one connectivity service | sync/dirty-queue pattern; strictly-online app → skip |
| R9 | Env-aware logging | build-mode gates for logging/crash/analytics; only `warn`+ to prod sink; no `print()` in features; `kDebugMode` not runtime env | `LoggerService` build-mode-aware (full rules in `observability`) |

## When to run

Before store submission (launch/major release) · beta→public cutover · when adding a capability that touches the above (first deep link/push/offline) · in pre-ship for service-layer or app-wiring changes. Not for small UI/copy changes.
