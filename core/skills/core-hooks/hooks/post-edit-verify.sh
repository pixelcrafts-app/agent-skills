#!/bin/bash
# post-edit-verify.sh — Stop hook.
#
# At turn-end, if Claude touched N+ non-trivial files in this turn AND did
# NOT run a verification pass (verify-changes / verification skill output),
# nudge the agent to verify before declaring done.
#
# Default behaviour: non-blocking WARN to stderr.
# Opt-in blocking: .claude/enforcement.json { "verify_required": "strict" }
#   exits 2, forcing the agent to run verification before Stop can complete.
#
# Opt-in WARN-only (still reminder, never blocks):
#   .claude/enforcement.json { "verify_required": true }
#
# Off (default): no enforcement.json or verify_required != true / "strict"
#   → hook is silent.
#
# Threshold: .claude/enforcement.json { "verify_threshold": 3 } (default 3).
#
# Fail-open: any error → exit 0. A bug in this hook cannot strand the user.

set +e

command -v jq >/dev/null 2>&1 || exit 0

PAYLOAD="$(cat)"
TRANSCRIPT="$(printf '%s' "$PAYLOAD" | jq -r '.transcript_path // empty' 2>/dev/null)"
[ -z "$TRANSCRIPT" ] && exit 0
[ ! -f "$TRANSCRIPT" ] && exit 0

# ── Locate enforcement.json (opt-in mechanism) ──────────────────────────────
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
CONFIG="$PROJECT_DIR/.claude/enforcement.json"
if [ ! -f "$CONFIG" ]; then
  DIR="$PWD"
  HOPS=0
  while [ "$DIR" != "/" ] && [ "$DIR" != "." ] && [ -n "$DIR" ] && [ $HOPS -lt 20 ]; do
    if [ -f "$DIR/.claude/enforcement.json" ]; then
      CONFIG="$DIR/.claude/enforcement.json"
      break
    fi
    DIR=$(dirname "$DIR")
    HOPS=$((HOPS + 1))
  done
fi
[ ! -f "$CONFIG" ] && exit 0

VERIFY_REQUIRED=$(jq -r '.verify_required // false' "$CONFIG" 2>/dev/null)
case "$VERIFY_REQUIRED" in
  true|strict) ;;
  *) exit 0 ;;  # not opted in → silent no-op
esac

THRESHOLD=$(jq -r '.verify_threshold // 3' "$CONFIG" 2>/dev/null)
case "$THRESHOLD" in ''|*[!0-9]*) THRESHOLD=3 ;; esac
[ "$THRESHOLD" -lt 1 ] && THRESHOLD=3

# ── Find the boundary of the current turn ───────────────────────────────────
TURN_START_LINE="$(awk '/"role":"user"/ {n=NR} END{print n+0}' "$TRANSCRIPT")"
[ "$TURN_START_LINE" = "0" ] && exit 0

# ── Count unique non-trivial files touched via Edit/Write/MultiEdit ─────────
EDITED_FILES="$(awk -v start="$TURN_START_LINE" 'NR>start' "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.role=="assistant") | .content[]? | select(.type=="tool_use") | select(.name=="Edit" or .name=="Write" or .name=="MultiEdit") | .input.file_path // empty' 2>/dev/null \
    | sort -u)"

[ -z "$EDITED_FILES" ] && exit 0

# Strip trivial paths (same list as plan-required.sh — keep in sync).
COUNT=0
SIGNIFICANT_FILES=""
while IFS= read -r FILE; do
    [ -z "$FILE" ] && continue
    case "$FILE" in
        *.md|*.json|*.yaml|*.yml|*.txt|*.lock|*.gitignore|*.toml) continue ;;
        */.claude/*|*/node_modules/*|*/.git/*|*/build/*|*/dist/*|*/.next/*|*/out/*|*/.dart_tool/*|*/.turbo/*) continue ;;
        *_test.dart|*.test.ts|*.test.js|*.test.tsx|*.spec.ts|*.spec.js|*.spec.tsx|*_test.go|*_test.py|test_*.py) continue ;;
        */test/*|*/tests/*|*/spec/*|*/__tests__/*) continue ;;
    esac
    COUNT=$((COUNT + 1))
    SIGNIFICANT_FILES="${SIGNIFICANT_FILES}${FILE}\n"
done <<EOF
$EDITED_FILES
EOF

[ "$COUNT" -lt "$THRESHOLD" ] && exit 0

# ── Did the assistant produce a verification artifact this turn? ────────────
# Two acceptable signals (any one clears the gate):
#   (1) Assistant text contains "Verification report" (verification skill header)
#       or "verify-changes" (the skill name referenced when invoked).
#   (2) A tool call to a `mcp__*verify*` or similar verifier ran this turn.
ASSISTANT_TEXT="$(awk -v start="$TURN_START_LINE" 'NR>start' "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.role=="assistant") | .content[]? | select(.type=="text") | .text' 2>/dev/null)"

if printf '%s' "$ASSISTANT_TEXT" \
     | grep -qE 'Verification report|verify-changes|Phase 1 — Plan|verify-state\.json'; then
  exit 0
fi

# Also accept: a Bash command containing the project's test/lint runner with PASS output.
TEST_RAN="$(awk -v start="$TURN_START_LINE" 'NR>start' "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.role=="assistant") | .content[]? | select(.type=="tool_use") | select(.name=="Bash") | .input.command // empty' 2>/dev/null \
    | grep -cE '(npm|pnpm|yarn|flutter|pytest|cargo|go) (test|run test|build|type-check|lint|tsc|analyze)')"
if [ -n "$TEST_RAN" ] && [ "$TEST_RAN" -gt 0 ]; then
  exit 0
fi

# ── Emit message ────────────────────────────────────────────────────────────
if [ "$VERIFY_REQUIRED" = "strict" ]; then
  LABEL="BLOCK"
  TAIL="Run /verify-changes (or invoke core-standards:verify-changes inline) before this turn can complete. The gate re-checks each Stop until verification artifacts appear in the transcript.\n\nOpt-out: set 'verify_required: true' (warn-only) or 'verify_required: false' in .claude/enforcement.json."
else
  LABEL="WARN"
  TAIL="Consider running /verify-changes before declaring done. The hook is in warn-only mode; opt in to blocking by setting 'verify_required: \"strict\"' in .claude/enforcement.json."
fi

{
    printf '\n[post-edit-verify %s] %d non-trivial files modified this turn without a verification pass:\n' "$LABEL" "$COUNT"
    printf '%b' "$SIGNIFICANT_FILES" | sed 's/^/  - /'
    printf '\nverify-changes runs the dependency-graph audit + cross-skill compliance check that no single per-file tool covers.\n'
    printf '%b\n\n' "$TAIL"
} >&2

if [ "$VERIFY_REQUIRED" = "strict" ]; then
  exit 2
fi
exit 0
