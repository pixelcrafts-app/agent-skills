#!/usr/bin/env bash
# Master export script for agent-skills.
# Delegates to harness-specific export scripts.
#
# Usage:
#   ./scripts/export.sh <harness> <target-project-path> [pack]
#   harness: cursor | codex | aider
#   pack: all | core | api | web | mobile | flutter | design (default: all)
#
# Examples:
#   ./scripts/export.sh cursor ~/work/my-flutter-app flutter
#   ./scripts/export.sh codex ~/work/my-api api
#   ./scripts/export.sh aider ~/work/my-web web

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HARNESS="${1:?usage: export.sh <cursor|codex|aider> <target-project-path> [pack]}"
TARGET="${2:?usage: export.sh <cursor|codex|aider> <target-project-path> [pack]}"
PACK="${3:-all}"

SCRIPT="$ROOT/harnesses/$HARNESS/export.sh"

if [[ ! -f "$SCRIPT" ]]; then
  echo "unknown harness or missing export script: $HARNESS" >&2
  exit 1
fi

exec "$SCRIPT" "$TARGET" "$PACK"
