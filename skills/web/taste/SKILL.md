---
name: taste
description: React/Next.js + Tailwind design engineering — three metric dials (DESIGN_VARIANCE, MOTION_INTENSITY, VISUAL_DENSITY) drive decisions. Anti-LLM-bias rules, AI-tells forbidden list, hardware-accelerated motion, Bento patterns. Auto-invoke on React/Next.js UI tasks needing premium output.
origin: Leonxlnx/taste-skill
---

# High-Agency Frontend

## Dials (baseline 8 / 6 / 4 — adapt to the user's prompt; don't ask them to edit this)

- **DESIGN_VARIANCE 8** (1 symmetry → 10 artsy chaos)
- **MOTION_INTENSITY 6** (1 static → 10 cinematic physics)
- **VISUAL_DENSITY 4** (1 art-gallery → 10 cockpit)

These drive the rules below. The arsenal in the last section is a creativity menu — pull from it, don't default to generic UI.

## Conventions

- **Verify deps:** check `package.json` before importing any library; if missing, output the install command first. Never assume it exists.
- React/Next, RSC by default; isolate interactive/motion parts as `'use client'` leaf components (Server Components render static layout only).
- Tailwind for ~90% of styling — check v3 vs v4 first (don't mix syntax; v4 uses `@tailwindcss/postcss`).
- **No emojis** anywhere — use Radix/Phosphor icons or clean SVG (standardize strokeWidth, e.g. 1.5).
- Viewport: `min-h-[100dvh]` not `h-screen` (iOS jump). CSS Grid over flex `calc()` math. Contain with `max-w-7xl mx-auto`.

## Bias correction (LLMs trend generic — counter it)

- **Typography:** display `text-4xl md:text-6xl tracking-tighter leading-none`; prefer `Geist/Outfit/Cabinet Grotesk/Satoshi` over Inter; serif BANNED on dashboards; body `text-base text-gray-600 leading-relaxed max-w-[65ch]`.
- **Color:** max 1 accent, saturation <80%; **no AI-purple/blue glow**; neutral base (Zinc/Slate) + one high-contrast accent; one palette per project (don't drift warm↔cool).
- **Layout:** when VARIANCE >4, no centered hero — split-screen / left-content-right-asset / asymmetric whitespace.
- **Materiality:** when DENSITY >7, no generic card boxes — group via `border-t`/`divide-y`/whitespace; cards only when elevation = hierarchy; tint shadows to the bg hue.
- **States (always):** skeletal loaders matching layout (not spinners), composed empty states, inline errors, tactile `:active` (`scale-[0.98]`/`-translate-y-px`).
- **Forms:** label above input, error below, `gap-2`.

## Motion & performance guardrails

- Animate only `transform`/`opacity` (never top/left/width/height). Spring physics (`stiffness:100, damping:20`), no linear easing. Magnetic/continuous motion via Framer `useMotionValue`/`useTransform` (never `useState`). Stagger list reveals; parent+children variants in the same client tree. Never `window.addEventListener('scroll')` — use Framer scroll hooks / GSAP ScrollTrigger.
- Grain/noise only on `fixed pointer-events-none` layers, never scroll containers. No arbitrary `z-50` spam. Memoize + isolate any perpetual animation in its own micro client component. Never mix GSAP/Three with Framer in one tree.

## AI tells — forbidden unless asked

Visual: no neon/outer glows, no pure `#000` (use Zinc-950), no oversaturated accents, no gradient-fill big headers, no custom cursors. Type: no Inter, no oversized screaming H1 (control via weight/color), serif only for editorial. Layout: mathematically perfect spacing; **no generic 3-equal-card row** (use zig-zag/asymmetric). Content: no "John Doe"/generic avatars/round numbers (`99.99%`) — use organic data (`47.2%`); no "Acme/Nexus"; no filler words ("Elevate/Seamless/Unleash"). Resources: no Unsplash (use `picsum.photos/seed/...`); customize shadcn (never default radii/colors).

## Creative arsenal (pull from these — don't default to generic)

- **Nav:** dock magnification, magnetic button, gooey menu, dynamic island, radial menu, speed dial, mega-menu reveal.
- **Layout:** bento grid, masonry, chroma grid, split-screen scroll, curtain reveal.
- **Cards:** parallax tilt, spotlight border, glass refraction panel, holographic foil, swipe stack, morphing modal.
- **Scroll:** sticky stack, horizontal hijack, locomotive sequence, zoom parallax, progress path, liquid swipe.
- **Media:** dome gallery, coverflow, drag-to-pan, accordion slider, hover image trail, glitch.
- **Type:** kinetic marquee, mask reveal, scramble, circular path, gradient stroke, dodging grid.
- **Micro:** particle button, liquid pull-refresh, shimmer, directional hover, ripple, SVG line-draw, mesh gradient, lens-blur depth.
- **Glass refraction:** beyond `backdrop-blur` add `border-white/10` + `shadow-[inset_0_1px_0_rgba(255,255,255,0.1)]`.

## Bento 2.0 (SaaS dashboards)

`#f9fafb` bg, white cards + `border-slate-200/50`, `rounded-[2.5rem]`, diffusion shadow `0_20px_40px_-15px_rgba(0,0,0,0.05)`, `p-8`+ padding, labels **outside/below** cards, Geist/Satoshi. Each card has an isolated, memoized infinite micro-loop (auto-sort list, typewriter command bar, breathing status, seamless carousel, focus-highlight) — `layout`/`layoutId` for reorders, `<AnimatePresence>`, 60fps.

## Pre-flight

- [ ] High-variance layouts collapse to `w-full px-4` mobile; `min-h-[100dvh]` not `h-screen`
- [ ] `useEffect` animations have cleanup; perpetual animations isolated + memoized
- [ ] Empty/loading/error states present; cards omitted for spacing where possible
- [ ] Only `transform`/`opacity` animated; deps verified against package.json
