#!/usr/bin/env bash
# Export agent-skills to Cursor Rules v2 format.
#
# Usage:
#   ./harnesses/cursor/export.sh <target-project-path> [pack]
#   pack: all | core | api | web | mobile | flutter | design (default: all)
#
# Example:
#   ./harnesses/cursor/export.sh ~/work/my-flutter-app flutter

set -euo pipefail

TARGET="${1:?usage: export.sh <target-project-path> [all|core|api|web|mobile|flutter|design]}"
PACK="${2:-all}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ ! -d "$TARGET" ]]; then
  echo "target project does not exist: $TARGET" >&2
  exit 1
fi

mkdir -p "$TARGET/.cursor/rules"

# Define globs per category
declare -A GLOBS=(
  [core]="**/*"
  [api]="src/**/*.ts,prisma/schema.prisma"
  [web]="app/**,components/**,lib/**,**/*.tsx,**/*.css"
  [mobile]="lib/**/*.dart,lib/**/*.swift,lib/**/*.kt"
  [flutter]="lib/**/*.dart,test/**/*.dart"
  [design]="**/*.tsx,**/*.css,**/*.dart"
)

extract_body() {
  awk 'BEGIN{f=0} /^---[[:space:]]*$/{f++;next} f>=2{print}' "$1"
}

extract_desc() {
  awk 'BEGIN{f=0}
       /^---[[:space:]]*$/{f++;next}
       f==1 && /^description:/{sub(/^description:[[:space:]]*/,""); gsub(/^"|"$/,""); print; exit}' "$1"
}

export_category() {
  local category="$1"
  local source_dir="$ROOT/skills/$category"
  local globs="${GLOBS[$category]}"

  [[ -d "$source_dir" ]] || return

  for skill_dir in "$source_dir"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name=$(basename "$skill_dir")
    local src="$skill_dir/SKILL.md"
    [[ -f "$src" ]] || continue

    local body="$(extract_body "$src")"
    local desc="$(extract_desc "$src")"
    local out="$TARGET/.cursor/rules/${category}-${skill_name}.mdc"

    {
      printf -- '---\n'
      printf 'description: %s\n' "${desc:-$category/$skill_name standard}"
      printf 'globs: %s\n' "$globs"
      printf 'alwaysApply: false\n'
      printf -- '---\n\n'
      printf '%s\n' "$body"
    } > "$out"
    echo "  wrote .cursor/rules/${category}-${skill_name}.mdc"
  done
}

if [[ "$PACK" == "all" ]]; then
  for category in core api web mobile flutter design; do
    export_category "$category"
  done
else
  export_category "$PACK"
fi

echo ""
echo "✓ Cursor export complete."
