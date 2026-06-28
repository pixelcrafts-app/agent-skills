---
name: design-tokens
description: Apply when auditing or documenting design-token usage in a mobile app — color, type, spacing, radius, duration completeness and naming. Framework-agnostic (Flutter, RN, SwiftUI, Compose, KMP); per-framework match patterns at the end. Auto-invoke when reviewing theme files, constants, or design-system code.
---

# Design Tokens

> Categories, naming, and audit patterns are universal; only the match identifiers differ per stack (adapters below).

## Completeness (a system is incomplete until every category is named, finite, and exposed as constants)

| Category | Required |
|---|---|
| Colors | brand, semantic (primary/secondary/error/success/warning), ≥3 surface levels, text levels (primary/secondary/muted/disabled), border |
| Typography | 6–8 step scale, per-step line-height + weight |
| Spacing | named scale ≥8 steps from one base unit (4 or 8) |
| Radius | named scale ≥5 steps |
| Duration | named (`instant/fast/normal/slow`) |
| Elevation | 2–5 levels (shadow / border-tint / luminance — project's choice) |

Names (`xxs`, `fast`) are convention, not law.

## Naming

Semantic not descriptive (`primary` not `blue500`). Surface hierarchy monotonic (`surface < surfaceVariant < surfaceContainer`; lighter = higher elevation in light mode, inverse in dark). Never expose raw values in screens — the token file is the only place a raw value lives; one file per category. Each token documents name + value + one-line intended use (missing any → fail).

## Violation patterns (flag in screen code, regardless of framework)

Color literal · inline text-style literal (size/weight/line-height) · spacing literal · edge-inset literal · radius literal · duration literal · shadow/elevation literal — any value not pulled from its token file. Allowed **only** inside the token file.

## Framework match patterns (what to grep outside the token file)

- **Flutter:** `Color(0x…)`/`Colors.<name>`/`Color.fromRGBO(` · `TextStyle(fontSize:/fontWeight:/height:` · raw nums in `SizedBox`/`EdgeInsets.*`/`padding:` · `BorderRadius.circular(<num>` · `Duration(milliseconds:<num>` · inline `BoxShadow(`.
- **React Native:** raw hex/rgb in `style`/`StyleSheet` · inline `fontSize/fontWeight/lineHeight` · numeric `margin/padding/gap/borderRadius` · `timing(...,{duration:<num>})` · inline `shadow*`/`elevation`.
- **SwiftUI:** `Color(red:/hex:` · `.font(.system(size:`/`.fontWeight(`/`.lineSpacing(` · `.padding(<num>)`/`.frame(width:/height:<num>` · `.cornerRadius(<num>` · `.easeInOut(duration:<num>` · literal `.shadow(`.
- **Compose:** `Color(0xFF…)` outside theme · `TextStyle(fontSize=` inline · `padding(<num>.dp)`/`.size(<num>.dp` · `RoundedCornerShape(<num>.dp` · `tween(durationMillis=<num>` · `Modifier.shadow(elevation=<num>` without theme.
- **KMP:** Compose adapter in `composeApp/` + shared tokens (`expect`/`actual`) in `shared/commonMain/`.

Allowed locations: the stack's token files (`theme/Color.kt`, `AppSpacing`, `theme/spacing.ts`, etc.). A missing adapter is a request for contribution, not permission to skip the audit.
