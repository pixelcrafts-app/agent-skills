#!/usr/bin/env bash
# Generic installer for agent-skills.
# Detects the active harness or accepts one as an argument.
#
# Usage:
#   ./scripts/install.sh [claude|kimi|cursor|codex|gemini]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HARNESS="${1:-auto}"

if [[ "$HARNESS" == "auto" ]]; then
  if command -v claude >/dev/null 2>&1; then
    HARNESS="claude"
  elif command -v kimi >/dev/null 2>&1; then
    HARNESS="kimi"
  else
    echo "Could not detect harness. Please specify one of: claude, kimi, cursor, codex, gemini" >&2
    exit 1
  fi
fi

case "$HARNESS" in
  claude)
    echo "Claude Code uses the plugin marketplace."
    echo "Run these commands in Claude Code:"
    echo "  /plugin marketplace add pixelcrafts-app/agent-skills"
    echo "  /plugin install core-standards@pixelcrafts"
    ;;
  kimi)
    "$ROOT/harnesses/kimi/install.sh"
    ;;
  cursor)
    echo "Cursor requires a target project path."
    echo "Usage: ./harnesses/cursor/export.sh <target-project-path>"
    ;;
  codex)
    echo "Codex requires a target project path."
    echo "Usage: ./harnesses/codex/export.sh <target-project-path>"
    ;;
  gemini)
    echo "Gemini requires a target project path."
    echo "Usage: ./harnesses/gemini/export.sh <target-project-path>"
    ;;
  *)
    echo "unknown harness: $HARNESS" >&2
    exit 1
    ;;
esac
