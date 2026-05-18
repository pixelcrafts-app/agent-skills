#!/bin/bash
# plan-required.sh — PreToolUse hook for Edit / Write / MultiEdit.
#
# Blocks multi-file work without a `<!-- craft:plan` block in the conversation
# transcript. Plan format and content are defined by `core-standards:planning`.
# This hook does not invent a format — it only enforces presence.
#
# Opt-in via .claude/enforcement.json:
#   { "plan_required": true, "plan_threshold": 3 }
#
# Default threshold (3): the third unique non-trivial file modified in a
# session triggers the gate. Trivial files (*.md, *.json, lockfiles, tests,
# generated dirs) do not count toward the threshold. Once any plan block
# exists in the transcript OR a "plan satisfied" ledger flag is set, the
# gate clears for the rest of the session.
#
# Exit 2 → block, stderr instructs Claude to write a plan first.
# Fail-open: any error / missing jq / missing config → exit 0. A bug in this
# hook can never strand the user.

set +e

command -v jq >/dev/null 2>&1 || exit 0

# ── Setup ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/session-ledger.sh"

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

# ── Parse the tool call ─────────────────────────────────────────────────────
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE" ] && exit 0

# ── Skip trivial files (don't count toward threshold) ───────────────────────
case "$FILE" in
  *.md|*.json|*.yaml|*.yml|*.txt|*.lock|*.gitignore|*.toml) exit 0 ;;
  */.claude/*|*/node_modules/*|*/.git/*|*/build/*|*/dist/*|*/.next/*|*/out/*|*/.dart_tool/*|*/.turbo/*) exit 0 ;;
  *_test.dart|*.test.ts|*.test.js|*.test.tsx|*.spec.ts|*.spec.js|*.spec.tsx|*_test.go|*_test.py|test_*.py) exit 0 ;;
  */test/*|*/tests/*|*/spec/*|*/__tests__/*) exit 0 ;;
esac

# ── Locate enforcement.json (opt-in mechanism) ──────────────────────────────
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
[ ! -f "$CONFIG" ] && exit 0

PLAN_REQUIRED=$(jq -r '.plan_required // false' "$CONFIG" 2>/dev/null)
[ "$PLAN_REQUIRED" != "true" ] && exit 0

THRESHOLD=$(jq -r '.plan_threshold // 3' "$CONFIG" 2>/dev/null)
# Sanity: threshold must be a positive integer.
case "$THRESHOLD" in ''|*[!0-9]*) THRESHOLD=3 ;; esac
[ "$THRESHOLD" -lt 1 ] && THRESHOLD=3

# ── Plan-presence checks (clear the gate if satisfied) ──────────────────────
# (1) Ledger flag set earlier this session → clear.
if ledger_has "plan-required" "satisfied"; then
  exit 0
fi

# (2) Transcript contains a plan marker → set flag and clear.
TRANSCRIPT="${CLAUDE_TRANSCRIPT_PATH:-}"
[ -z "$TRANSCRIPT" ] && TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  if jq -r 'select(.role=="assistant") | .content[]? | select(.type=="text") | .text' "$TRANSCRIPT" 2>/dev/null \
       | grep -q '<!-- craft:plan'; then
    ledger_init
    ledger_set "plan-required" "satisfied"
    exit 0
  fi
fi

# ── Track unique files touched this session ─────────────────────────────────
ledger_init
FILE_LIST="$(ledger_dir)/plan-required.files"
touch "$FILE_LIST" 2>/dev/null

if ! grep -qxF -- "$FILE" "$FILE_LIST" 2>/dev/null; then
  printf '%s\n' "$FILE" >> "$FILE_LIST"
fi

COUNT=$(wc -l < "$FILE_LIST" 2>/dev/null | tr -d ' ')
case "$COUNT" in ''|*[!0-9]*) exit 0 ;; esac

# Below threshold → allow
[ "$COUNT" -lt "$THRESHOLD" ] && exit 0

# ── Block: significant work without a plan ──────────────────────────────────
cat >&2 <<EOF
[plan-required] Blocked: about to touch file #${COUNT} this session without a plan block.

Threshold is ${THRESHOLD} non-trivial files. Significant multi-file work
requires a craft:plan block in the conversation first
(see core-standards:planning for the full format).

Minimal block — write in your next response BEFORE any further Edit/Write:

  <!-- craft:plan
  deliverables:
    - id: D1
      description: "what will exist when this is done"
      files: [path/to/file.ext]
      verification: "Bash: <compile or test command>"
    - id: D2
      description: "..."
      files: [...]
      verification: "..."
  scope_boundary: "what is explicitly NOT in scope"
  -->

Once any plan marker appears in the conversation, this gate clears for the
session — no need to re-emit it for subsequent edits.

Opt-out for this project: set 'plan_required: false' in .claude/enforcement.json
EOF
exit 2
