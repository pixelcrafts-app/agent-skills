---
name: brand-research
description: Before designing for a specific brand — verify the product exists via search, then collect assets in priority order: logo → product imagery → UI screenshots → color → font. Prevents designing from false assumptions or generic placeholders. Web, iOS, Android, any visual output.
origin: alchaincyf/huashu-design
---

# Brand Research

Triggers: user names a specific brand/product/company · designing for an external product · vague reference ("make it look like Notion") · any "which version / does this exist?" question.

## Step 0 — Verify facts first (highest priority)

Any claim about a specific product (existence, release, version, specs) is **searched before** clarifying questions or design — especially for products you don't have confirmed knowledge of, anything from 2024+, or any internal "I think / probably / I recall."

```
WebSearch: "<product> latest 2026" · "<product> release date specs"
```
Read 1–3 authoritative results; confirm existence/release/version/specs. **Banned** (stop and search instead): "I think X isn't released", "X is probably vN", "X might not exist." (10-second search vs 2-hour rework.)

## Step 1 — Collect assets in priority order

| # | Asset | Required when |
|---|-------|---------------|
| 1 | **Logo** (SVG/hi-res PNG) | always |
| 2 | Product imagery/renders | physical products |
| 3 | UI screenshots | digital products |
| 4 | Color values | supplementary |
| 5 | Font names | supplementary |

**Never extract color+font while skipping logo + product imagery** — color without logo is unrecognizable; a CSS silhouette is not a product image. Ask the user which they already have; search for the rest.

## Step 2 — Search official channels

Logo → `<brand>.com/brand` `/press-kit`, inline SVG · product imagery → product page hero/gallery, launch-video stills · UI → App/Play Store listing, site screenshots · colors → homepage CSS/Tailwind config, brand PDF · fonts → site `<link>`, Google Fonts. Fallbacks: `"<brand> logo SVG download"`, `"<brand> <product> official renders"`.

## Step 3 — Validate before use

Logo transparent (not JPEG artifact) · product image is the correct/current version · UI screenshot reflects the current app. Below usable quality → ask the user; never substitute a generated placeholder without disclosure.

## Anti-patterns

| Wrong | Right |
|---|---|
| extract color+font, skip logo | logo first — it *is* the brand |
| CSS/SVG silhouette as "product image" | find the real render or ask |
| assume the product exists from memory | search to confirm first |
| "I think the brand colors are…" | extract from official source |
| generic placeholder labeled with the brand | honest gray box > wrong brand impression |
