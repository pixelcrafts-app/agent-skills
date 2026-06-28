---
name: performance
description: Apply when optimizing Flutter performance — frame budget, cold start, decode-at-display-size images, isolates for heavy work, const widgets, builder lists, bounded image cache, dispose discipline. Auto-invoke on list / image / animation work.
---

# Flutter Performance

> Budgets are firm; device-specific caps are defaults you tighten, never loosen. Measure in release mode on a mid-tier device (iPhone 12 / Pixel 6a), never a dev machine. Profile before optimizing.

## Budgets

| Metric | Budget |
|--------|--------|
| Frame (60fps / 120Hz) | 16ms / 8ms |
| Cold start: first frame / meaningful paint / interactive | <1s / <2s P75 / <3s P95 |
| Route transition · tap feedback · API render | <300ms · <100ms · <500ms |
| Memory on ≤2GB devices | <100MB RSS |

A 16ms frame splits ~4ms each across build/layout/paint/raster — blow any phase → dropped frame.

## Keep `build()` cheap

- No computation/sort/filter/map, no I/O, no `Future.delayed`/`Timer` in `build()` — it runs ~60×/sec. Compute once when data changes (provider / memoized value).
- `const` widgets skip rebuild. Narrow subscriptions: `Selector` / `ref.watch(p.select(...))` / `ValueListenableBuilder`. Never wrap a whole screen in a `Consumer` for one value.
- Avoid layout thrash: `Intrinsic*` and `shrinkWrap:true` on nested scrollables force multi-pass layout — use slivers/fixed heights; flatten deep `Expanded` nesting.

## Lists & scroll

- >20 items → always `.builder` / `SliverList` (virtualized). `itemExtent`/`prototypeItem` when heights are uniform. Nested scrolling → one `CustomScrollView`, not stacked scroll views.
- Paginate 20–50/page; trigger next at ~80% scroll; debounce scroll-driven fetches.

## Images

- **Decode at display size:** pass `cacheWidth`/`cacheHeight` = rendered size × `devicePixelRatio` (a 40px avatar on 3× → `cacheWidth:120`, not source resolution). `CachedNetworkImage` for remote; `FadeInImage` to avoid layout jump.
- Bound the cache on low-end devices (e.g. `imageCache.maximumSizeBytes` ~50MB, count ~200); clear on `didHaveMemoryPressure`.

## Heavy work → isolates

Never on the main isolate: parsing >1MB JSON, image transforms, crypto >1KB, sorting >1000 items. Use `compute()` (one-shot, ~10ms overhead) or a long-lived `Isolate.spawn` for frequent work.

## Cold start

`main()` does the minimum (critical init only); reach `runApp` fast; defer analytics/crash/remote-config/sync until after first frame; parallelize with `Future.wait`; first screen shows cached data, refreshes in background.

## Animations

`AnimatedBuilder` with a `child:` (built once); `RepaintBoundary` around independently-animating widgets; `FadeTransition` not `Opacity` on large subtrees; avoid animating shadows on many widgets and `BackdropFilter` on scroll-heavy screens.

## Memory

Dispose every controller/subscription/stream/`FocusNode`/`AnimationController`; close `StreamController`s and unused Hive boxes; don't hold large objects in app-lifetime fields. Verify: run a flow 10× in DevTools — memory must plateau, not climb.

## Network & bundle

Cache cacheable responses; cap concurrency ~4–6; debounce typed input ~250–500ms; `CancelToken` on screen dismount; timeout every request (~15s default). Per release: `flutter build --analyze-size`, prune unused packages, WebP photos / SVG vectors, load only used font weights.

## Where budgets are non-negotiable

Main tab screens, scroll-heavy lists, animated transitions, first post-cold-start screen, input fields. May relax (not ignore) on settings, one-off dialogs, admin/debug screens.

## Checklist

- [ ] No work in `build()`; `const` + narrow rebuild scope
- [ ] Long lists virtualized; images decoded at display size; cache bounded
- [ ] Heavy work off the main isolate
- [ ] Everything disposed/closed; memory plateaus over repeated flows
- [ ] Profiled in release on a real mid-tier device before optimizing
