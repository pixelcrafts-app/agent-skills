---
name: nextjs
description: Apply when writing or reviewing Next.js + React + Tailwind + shadcn — app router, Server Components by default, deep client boundary, CSS-variable tokens, shadcn base, React Query with structured keys, RHF + Zod, next/image + next/font, no barrel files, no any/as. Auto-invoke on changes under app/, components/, lib/.
---

# Next.js + React + Tailwind + shadcn

> Generic patterns, reusable across any Next.js project. App-specific values (tokens, container widths, brand colors, API clients) belong in your project's instructions file.

## App Router

- **Server Components by default;** add `"use client"` (top of file) only for interactivity/hooks/browser APIs, and push the boundary as deep as possible (wrap the interactive part, not the page).
- Layouts for shared UI (don't re-render on nav). Every new route ships `loading.tsx` + `error.tsx` (client) + `not-found.tsx` — all three, not optional.

## Components & Tailwind

- One component per file, named export matches filename, props destructured in the signature. Composition over prop drilling. Colocate component types; shared types in `lib/types/`.
- Style via Tailwind utilities only (no inline styles / CSS modules except dynamic computed values). Semantic colors via CSS vars (`--background`, `--primary`…) — never hardcoded hex. `dark:` via `next-themes`. `cn()` for conditional classes. No arbitrary values (`p-[13px]`). Mobile-first.
- Use shadcn/ui as the base (don't rebuild); customize in `components/ui/`, not wrappers. `cva` variants. Respect Radix a11y (focus trap, Esc). Toasts via Sonner.

## State

**Server state — choose first:** Server Component fetch when data is needed at initial render, auth-scoped/uncacheable, SEO-sensitive, or rarely-changing. React Query (needs `"use client"`) when data follows interaction, benefits from client cache/SWR, or needs optimistic/dependent queries. Never add `"use client"` solely to use React Query where a Server fetch works.

- **React Query:** structured array keys `['entity','list',{filter}]` (never strings); `staleTime`/`gcTime` per volatility; mutations invalidate in `onSuccess`; optimistic for user actions.
- **Client state:** Context for app-wide UI state (theme, prefs) — split by concern, no server data in context. `useState`/`useReducer` local; persist prefs to `localStorage`.

## Data fetching

- Server Components fetch directly (no React Query / `useEffect`). Client Components use React Query hooks (never raw `fetch` in `useEffect`). Centralized HTTP client with timeout + abort. Cache Server fetches: `cache()` dedup, `revalidatePath/Tag` after mutations, `revalidate` for time-based. Handle loading/error/empty for every data-driven component.

## Performance & forms

- `next/image` (explicit dims, lazy, placeholder); `next/dynamic` for heavy non-first-paint; `next/font` (no CLS); `@next/bundle-analyzer`; memoize only where profiling shows benefit.
- React Hook Form + Zod (share schema client/server). Inline field errors (not toast). Disable submit + loading state during submission.

## Accessibility & PWA

- Semantic HTML; keyboard-accessible with visible focus; ARIA from Radix; meaningful `alt`/`alt=""`; skip-to-content; `motion-reduce:`.
- Service worker offline fallback; manifest; designed offline page; update-available prompt.

## TypeScript & naming

- `interface` for props, `type` for unions. No `any` (use `unknown`+narrow); no `as` assertions (use type guards). Exhaustive switches with `never` default. Validate external data with Zod at boundaries. **No barrel files** (break tree-shaking) — import from source. No array-index keys for dynamic lists.
- Files kebab-case; components PascalCase matching file; hooks `use-`/`use`; constants `UPPER_SNAKE`.

## Verify, don't guess (cross-boundary)

Calling an API / reading an env var / using an SDK / consuming a shared type → **read the source of truth first** (controller+DTO, OpenAPI, `.env.example`, SDK typings). Can't read it → ask a concrete question. Never guess a field name (`userId` vs `user_id`). Order: read → plan → code, not code → hope → debug. End with an "assumptions I couldn't verify" list.
