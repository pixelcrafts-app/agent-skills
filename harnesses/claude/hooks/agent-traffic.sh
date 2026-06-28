#!/bin/bash
# agent-traffic.sh — Pre/Post hook for Agent and Task tools.
#
# Logs every agent spawn and return to .claude/agent-traffic.log so the user
# can see inter-agent communication post-hoc. Also prints a one-line live
# summary to stderr for immediate visibility.
#
# Always on by default (observability — no opt-in required). To silence:
# set .claude/enforcement.json { "agent_traffic_log": false }.
#
# Usage from plugin.json — pass "pre" or "post" as the first argument:
#   bash ${CLAUDE_PLUGIN_ROOT}/hooks/agent-traffic.sh pre
#   bash ${CLAUDE_PLUGIN_ROOT}/hooks/agent-traffic.sh post
#
# Log format:
#   2026-05-18T22:15:30  SPAWN   <agent-type>  <description first 100 chars>
#   2026-05-18T22:16:42  RETURN  <agent-type>  <response bytes>
#
# Fail-open: any error → exit 0. Never blocks or delays the agent call.

set +e

MODE="${1:-pre}"
[ "$MODE" != "pre" ] && [ "$MODE" != "post" ] && exit 0

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
case "$TOOL" in
  Agent|Task) ;;
  *) exit 0 ;;
esac

# ── Honor opt-out ───────────────────────────────────────────────────────────
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
CONFIG="$PROJECT_DIR/.claude/enforcement.json"
if [ ! -f "$CONFIG" ]; then
  DIR="$PWD"
  HOPS=0
  while [ "$DIR" != "/" ] && [ "$DIR" != "." ] && [ -n "$DIR" ] && [ $HOPS -lt 20 ]; do
    if [ -f "$DIR/.claude/enforcement.json" ]; then
      CONFIG="$DIR/.claude/enforcement.json"
      PROJECT_DIR="$DIR"
      break
    fi
    DIR=$(dirname "$DIR")
    HOPS=$((HOPS + 1))
  done
fi
if [ -f "$CONFIG" ]; then
  # jq's `//` treats `false` as null-equivalent, so `.x // true` returns `true`
  # when .x is explicitly `false`. Use `has()` + explicit branch to honor
  # an explicit `agent_traffic_log: false` opt-out.
  ENABLED=$(jq -r 'if has("agent_traffic_log") then (.agent_traffic_log | tostring) else "true" end' "$CONFIG" 2>/dev/null)
  [ "$ENABLED" = "false" ] && exit 0
fi

# ── Set up log file ─────────────────────────────────────────────────────────
LOG_DIR="$PROJECT_DIR/.claude"
mkdir -p "$LOG_DIR" 2>/dev/null
LOG_FILE="$LOG_DIR/agent-traffic.log"

TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%S')

# ── Extract agent identity ──────────────────────────────────────────────────
# Agent tool: tool_input has { description, prompt, subagent_type, ... }
# Task tool: similar shape; legacy/alternate naming
AGENT_TYPE=$(printf '%s' "$INPUT" | jq -r '
  .tool_input.subagent_type
  // .tool_input.type
  // .tool_input.agent_type
  // "general"
' 2>/dev/null)
[ -z "$AGENT_TYPE" ] && AGENT_TYPE="general"

if [ "$MODE" = "pre" ]; then
  # Truncate description to 120 chars so the log stays scannable.
  DESC=$(printf '%s' "$INPUT" | jq -r '.tool_input.description // empty' 2>/dev/null)
  [ -z "$DESC" ] && DESC=$(printf '%s' "$INPUT" | jq -r '.tool_input.prompt // empty' 2>/dev/null | head -c 120 | tr '\n' ' ')
  [ -z "$DESC" ] && DESC="<no description>"

  {
    printf '%s  SPAWN   %-20s  %s\n' "$TIMESTAMP" "$AGENT_TYPE" "$DESC"
  } >> "$LOG_FILE" 2>/dev/null

  # Live stderr summary — user sees this in their terminal.
  printf '[agent-traffic] SPAWN   %-20s  %s\n' "$AGENT_TYPE" "$DESC" >&2
fi

if [ "$MODE" = "post" ]; then
  # Response size as a proxy for "what came back" — keeps the log small but
  # informative. Full response stays in the transcript for deeper review.
  RESPONSE=$(printf '%s' "$INPUT" | jq -r '
    .tool_response
    // .tool_response_text
    // (.tool_response_content // [] | map(.text // "") | join(""))
    // ""
  ' 2>/dev/null)
  BYTES=$(printf '%s' "$RESPONSE" | wc -c | tr -d ' ')
  [ -z "$BYTES" ] && BYTES=0

  {
    printf '%s  RETURN  %-20s  %s bytes\n' "$TIMESTAMP" "$AGENT_TYPE" "$BYTES"
  } >> "$LOG_FILE" 2>/dev/null

  printf '[agent-traffic] RETURN  %-20s  %s bytes\n' "$AGENT_TYPE" "$BYTES" >&2
fi

exit 0
