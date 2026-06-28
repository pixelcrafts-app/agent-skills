#!/usr/bin/env bash
# Export agent-skills to a single AGENTS.md file for OpenAI Codex / SWE agents.
#
# Usage:
#   ./harnesses/codex/export.sh <target-project-path> [pack]
#   pack: all | core | api | web | mobile | flutter | design (default: all)

set -euo pipefail

TARGET="${1:?usage: export.sh <target-project-path> [all|core|api|web|mobile|flutter|design]}"
PACK="${2:-all}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ ! -d "$TARGET" ]]; then
  echo "target project does not exist: $TARGET" >&2
  exit 1
fi

extract_body() {
  awk 'BEGIN{f=0} /^---[[:space:]]*$/{f++;next} f>=2{print}' "$1"
}

agents="$TARGET/AGENTS.md"

{
  printf '# Agent Standards\n\n'
  printf 'Auto-generated from `pixelcrafts-app/agent-skills`. Do not edit — regenerate via `harnesses/codex/export.sh`.\n\n'
  printf 'Source: https://github.com/pixelcrafts-app/agent-skills\n\n'
  printf -- '---\n\n'

  export_category() {
    local category="$1"
    local source_dir="$ROOT/skills/$category"
    [[ -d "$source_dir" ]] || return

    printf '## %s Standards\n\n' "$category"

    for skill_dir in "$source_dir"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name=$(basename "$skill_dir")
      local src="$skill_dir/SKILL.md"
      [[ -f "$src" ]] || continue

      printf '### %s\n\n' "$skill_name"
      extract_body "$src"
      printf '\n---\n\n'
    done
  }

  if [[ "$PACK" == "all" ]]; then
    for category in core api web mobile flutter design; do
      export_category "$category"
    done
  else
    export_category "$PACK"
  fi
} > "$agents"

echo "✓ wrote $agents"
