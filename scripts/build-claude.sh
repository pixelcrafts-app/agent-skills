#!/usr/bin/env bash
# build-claude.sh — generate the Claude Code plugin marketplace from the single source (skills/).
#
# Produces (build artifacts, regenerate — do not hand-edit):
#   .claude-plugin/marketplace.json   ← front door, discoverable by `/plugin marketplace add owner/repo`
#   plugins/<plugin>/                  ← one installable plugin per pack, skills copied from skills/
#
# Plugin manifests are authored in harnesses/claude/.claude-plugin/<plugin>.json (the templates).
# Skill bodies are authored in skills/<category>/<name>/SKILL.md (the single source).
# This script wires them together so marketplace source paths actually resolve.
#
# Usage: bash scripts/build-claude.sh [--dry-run]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES="$ROOT/harnesses/claude/.claude-plugin"
OUT="$ROOT/plugins"
MKT="$ROOT/.claude-plugin"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

# plugin -> skills/ category
plugin_category() {
  case "$1" in
    core-standards)    echo "core" ;;
    flutter-standards) echo "flutter" ;;
    mobile-standards)  echo "mobile" ;;
    api-standards)     echo "api" ;;
    web-standards)     echo "web" ;;
    design-standards)  echo "design" ;;
  esac
}

PLUGINS=(core-standards flutter-standards mobile-standards api-standards web-standards design-standards)

say() { echo "$@"; }
run() { if $DRY_RUN; then echo "[dry-run] $*"; else eval "$@"; fi; }

# ── per-plugin build ─────────────────────────────────────────
$DRY_RUN || rm -rf "$OUT" "$MKT"
for name in "${PLUGINS[@]}"; do
  manifest="$TEMPLATES/$name.json"
  [[ -f "$manifest" ]] || { echo "missing manifest: $manifest" >&2; exit 1; }

  pdir="$OUT/$name"
  run "mkdir -p '$pdir/.claude-plugin'"
  run "cp '$manifest' '$pdir/.claude-plugin/plugin.json'"
  say "  ✓ $name → plugins/$name/.claude-plugin/plugin.json"

  # category skills from the single source
  cat="$(plugin_category "$name")"
  if [[ -n "$cat" && -d "$ROOT/skills/$cat" ]]; then
    run "mkdir -p '$pdir/skills'"
    run "cp -R '$ROOT/skills/$cat/.' '$pdir/skills/'"
    n=$(find "$ROOT/skills/$cat" -name SKILL.md | wc -l | tr -d ' ')
    say "      + $n skills from skills/$cat/"
  fi

  # core-standards also ships the Claude-scoped skills (skills/claude/)
  if [[ "$name" == "core-standards" && -d "$ROOT/skills/claude" ]]; then
    run "mkdir -p '$pdir/skills'"
    run "cp -R '$ROOT/skills/claude/.' '$pdir/skills/'"
    cn=$(find "$ROOT/skills/claude" -name SKILL.md | wc -l | tr -d ' ')
    say "      + $cn Claude-scoped skills (skills/claude/)"
  fi

done

# ── root marketplace.json ────────────────────────────────────
root_version="$(grep '^version:' "$ROOT/agent.yaml" | head -1 | sed 's/version:[[:space:]]*//')"

entries="[]"
for name in "${PLUGINS[@]}"; do
  entry="$(jq -n \
    --arg src "./plugins/$name" \
    --slurpfile m "$TEMPLATES/$name.json" \
    '{name: $m[0].name, source: $src, description: $m[0].description, version: $m[0].version, category: ($m[0].keywords[0] // "general"), tags: ($m[0].keywords // [])}')"
  entries="$(jq --argjson e "$entry" '. + [$e]' <<<"$entries")"
done

marketplace="$(jq -n \
  --arg ver "$root_version" \
  --argjson plugins "$entries" \
  '{
     name: "pixelcrafts",
     owner: { name: "pixelcrafts", url: "https://github.com/pixelcrafts-app" },
     metadata: {
       description: "Harness-agnostic standards, skills, and rules for AI coding agents. Generated from skills/ — see scripts/build-claude.sh.",
       version: $ver
     },
     plugins: $plugins
   }')"

if $DRY_RUN; then
  echo "[dry-run] would write $MKT/marketplace.json"
  echo "$marketplace" | jq '.plugins | length as $n | "\($n) plugins"'
else
  mkdir -p "$MKT"
  echo "$marketplace" > "$MKT/marketplace.json"
  echo ""
  echo "✓ wrote .claude-plugin/marketplace.json ($(jq '.plugins | length' <<<"$marketplace") plugins)"
fi
