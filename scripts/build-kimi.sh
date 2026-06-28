#!/usr/bin/env bash
# build-kimi.sh — generate the full Kimi skill set from the single source (skills/).
#
# Kimi reads SKILL.md frontmatter directly and expects a `pc-` name prefix, so each
# canonical skill is transformed (name -> pc-<...>) rather than copied verbatim.
# Hand-tuned Kimi skills in harnesses/kimi/overrides/ take precedence over generation.
#
# Output (generated build artifact, regenerate — do not hand-edit):
#   harnesses/kimi/skills/pc-<name>/SKILL.md
#
# Naming: core skills -> pc-<name>; stack skills -> pc-<category>-<name> (avoids
# collisions like flutter/accessibility vs design/accessibility).
#
# Usage: bash scripts/build-kimi.sh [--dry-run]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/skills"
OVERRIDES="$ROOT/harnesses/kimi/overrides"
OUT="$ROOT/harnesses/kimi/skills"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

kimi_name() {
  local cat="$1" name="$2"
  if [[ "$cat" == "core" ]]; then echo "pc-$name"; else echo "pc-$cat-$name"; fi
}

# Rewrite the `name:` line inside the first frontmatter block; keep everything else.
transform() {
  awk -v newname="$1" '
    BEGIN { fm = 0; done = 0 }
    /^---[[:space:]]*$/ { fm++; print; next }
    fm == 1 && !done && /^name:/ { print "name: " newname; done = 1; next }
    { print }
  ' "$2"
}

$DRY_RUN || rm -rf "$OUT"
gen=0; ovr=0
for cat in core api web mobile flutter design; do
  [[ -d "$SRC/$cat" ]] || continue
  for skill_dir in "$SRC/$cat"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    name="$(basename "$skill_dir")"
    target="$(kimi_name "$cat" "$name")"
    dest="$OUT/$target"

    if [[ -f "$OVERRIDES/$target/SKILL.md" ]]; then
      if $DRY_RUN; then echo "[dry-run] override → $target"; else
        mkdir -p "$dest"; cp "$OVERRIDES/$target/SKILL.md" "$dest/SKILL.md"
      fi
      ovr=$((ovr+1))
    else
      if $DRY_RUN; then echo "[dry-run] generate → $target"; else
        mkdir -p "$dest"; transform "$target" "$skill_dir/SKILL.md" > "$dest/SKILL.md"
      fi
      gen=$((gen+1))
    fi
  done
done

echo ""
echo "✓ Kimi skills built: $((gen+ovr)) total ($gen generated, $ovr from overrides)"
$DRY_RUN || echo "  → harnesses/kimi/skills/  (install with ./harnesses/kimi/install.sh)"
