---
name: production-readiness
description: Apply when auditing a Next.js app for production readiness — error boundaries, Suspense, optimistic UI, image optimization, metadata/OG/sitemap, CSP + security headers, analytics consent, Core Web Vitals, env-aware logging. Detect → Check → Suggest, never blindly enforces. Auto-invoke when reviewing app-level wiring, route config, or release readiness.
---

# Next.js Production Readiness

> Universal security/testing/observability rules apply too; this covers Next.js specifics. None of these are universally required — each depends on audience, regulation, deployment. **Every item: Detect → Check → Suggest. Never rewrite the app.** Skip what doesn't apply (an SSO-gated internal tool needs no OG tags/sitemap); flag "not yet" so it isn't silently missed at launch.

Rules keep stable `§R` IDs (split as `§R1.a`, never renumber) — `verify-changes`/`pre-ship` iterate them.

| Rule | Detect / key checks | If absent (suggest) |
|------|---------------------|---------------------|
| **§R1** Error boundaries | `error.tsx` per route segment + `global-error.tsx`; specific message + `reset()` retry; crash report with context | One exception blanks the whole tab — offer `error.tsx` template |
| **§R2** Suspense/streaming | `<Suspense>` around slow async children + `loading.tsx` matching layout; independent boundaries for independent fetches | Without it the route blocks on the slowest query — offer route `loading.tsx` + targeted Suspense |
| **§R3** Optimistic + rollback | `onMutate`/`onError` cache rollback or `useOptimistic`; **low-risk only**, not money/identity/destructive; error toast on rollback | Offer for toggles/lists; keep loading state for critical mutations |
| **§R4** Image optimization | `next/image` universal (flag raw `<img>`), explicit `width/height`, `sizes`, blur, `priority` on LCP only, remote allowlist (no `**`) | #1 LCP killer — offer `<img>`→`next/image` migration |
| **§R5** Metadata/OG | per-route `title`/`description`, dynamic OG, canonical, `twitter` card, `robots` (staging `noindex`) | Public apps only — offer `generateMetadata()`; skip for SSO-gated |
| **§R6** Sitemap/robots | `app/sitemap.ts`+`robots.ts`, dynamic, excludes auth/admin/preview, submitted to consoles | Public+SEO only — offer `sitemap.ts`; skip invite-only |
| **§R7** CSP + headers | CSP (no `unsafe-inline` without nonce), HSTS ≥1yr, nosniff, frame-ancestors/`X-Frame`, Referrer-Policy, Permissions-Policy | Offer conservative `headers()`; test CSP in report-only first |
| **§R8** Analytics consent | scripts don't load pre-consent (Consent Mode v2 or hard gate); categories; persisted; withdraw path | EU/UK/CA consumer only — offer consent flow; B2B+DPA usually exempt |
| **§R9** Core Web Vitals | targets LCP<2.5s / INP<200ms / CLS<0.1; real-user (not just Lighthouse); regression alerts; per-route | Offer `useReportWebVitals` → analytics; degraded LCP sinks search rank |
| **§R10** Env-aware logging | level by `LOG_LEVEL`; JSON in prod / pretty dev; secrets redacted at logger; no request bodies in prod | Offer `pino` + redaction list; `console.log` of user data = privacy + cost incident |

## When to run

Before launch/major release · when adding a privacy scope (new region/data category) · when CSP/headers change (regressions break rendering silently) · preview→prod cutover · in `pre-ship` for changes to root layout, middleware, `next.config.js`, or the service layer. Not for isolated component/copy/styling changes.
