#!/usr/bin/env bash
# deploy.sh — single entrypoint for deploying agent-skills to any harness.
#
# All harnesses read from the same single source of truth: skills/<category>/<name>/SKILL.md
#
# Two delivery modes sit behind this one command:
#   export  → writes a rules/context file into a target project (cursor, codex, gemini, aider)
#   install → installs into the harness itself (claude plugins, kimi global skills)
#
# Usage:
#   ./scripts/deploy.sh <harness> [target-project-path] [pack]
#   harness: claude | kimi | cursor | codex | gemini | aider
#   pack:    all | core | api | web | mobile | flutter | design (default: all)
#
# Examples:
#   ./scripts/deploy.sh gemini ~/work/my-app
#   ./scripts/deploy.sh cursor ~/work/my-flutter-app flutter
#   ./scripts/deploy.sh kimi
#   ./scripts/deploy.sh claude

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HARNESS="${1:?usage: deploy.sh <claude|kimi|cursor|codex|gemini|aider> [target] [pack]}"
TARGET="${2:-}"
PACK="${3:-all}"

case "$HARNESS" in
  cursor|codex|gemini|aider)
    if [[ -z "$TARGET" ]]; then
      echo "harness '$HARNESS' is an export target and needs a project path." >&2
      echo "usage: deploy.sh $HARNESS <target-project-path> [pack]" >&2
      exit 1
    fi
    exec "$ROOT/harnesses/$HARNESS/export.sh" "$TARGET" "$PACK"
    ;;
  kimi)
    exec "$ROOT/harnesses/kimi/install.sh"
    ;;
  claude)
    echo "Claude Code installs via the plugin marketplace. Run these in Claude Code:"
    echo "  /plugin marketplace add pixelcrafts-app/agent-skills"
    echo "  /plugin install core-standards@pixelcrafts"
    ;;
  *)
    echo "unknown harness: $HARNESS" >&2
    echo "expected one of: claude kimi cursor codex gemini aider" >&2
    exit 1
    ;;
esac
