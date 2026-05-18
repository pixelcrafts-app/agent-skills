#!/bin/bash
# Stop hook — surfaces honesty violations: factual claims about files that
# were never Read/Grep'd in the same turn.
#
# Default mode: non-blocking WARN to stderr — the user sees the message,
# the agent sees it next turn via transcript review.
#
# Opt-in blocking mode: set in .claude/enforcement.json
#   { "honesty_blocking": true }
# In this mode the hook exits 2 on any violation, forcing Claude to either
# Read the referenced files or remove the unsourced claim before turn-end.
#
# Heuristic, not deterministic: scans the final assistant message for
# explicit file references, then checks the turn's tool calls for Read/Grep
# on those files. Matches `path/like/this.ext` and `path/like/this.ext:42`.
#
# Fail-open: any error → exit 0. Never blocks the user on a hook bug.

set +e

command -v jq >/dev/null 2>&1 || exit 0

# Hook payload on stdin: { "transcript_path": "...", "stop_hook_active": ... }
PAYLOAD="$(cat)"
TRANSCRIPT="$(printf '%s' "$PAYLOAD" | jq -r '.transcript_path // empty' 2>/dev/null)"
[ -z "$TRANSCRIPT" ] && exit 0
[ ! -f "$TRANSCRIPT" ] && exit 0

# Find the boundary of the current turn: scan the transcript backwards to
# the most recent user message. Everything after that is "this turn".
TURN_START_LINE="$(awk '/"role":"user"/ {n=NR} END{print n+0}' "$TRANSCRIPT")"
[ "$TURN_START_LINE" = "0" ] && exit 0

# The final assistant message — last assistant entry in the file.
FINAL_TEXT="$(jq -r 'select(.role=="assistant") | .content[]? | select(.type=="text") | .text' "$TRANSCRIPT" 2>/dev/null | tail -c 20000)"
[ -z "$FINAL_TEXT" ] && exit 0

# Extract file references from the final message.
# Matches:
#   path/with/slashes.ext        → src/auth/service.ts
#   path/with/slashes.ext:42     → src/auth/service.ts:42
#   `path/with/slashes.ext`      → backtick-quoted form
# Excludes URLs (http(s)://...) and bare file names without a slash.
# Strip URLs first — otherwise the regex picks up "example.com/foo.ts"
# from inside "https://example.com/foo.ts" and the prefix filter misses it.
TEXT_STRIPPED="$(printf '%s' "$FINAL_TEXT" | sed -E 's#https?://[^[:space:]]+##g')"
REFERENCED_FILES="$(printf '%s' "$TEXT_STRIPPED" \
    | grep -oE '[a-zA-Z0-9_./-]+/[a-zA-Z0-9_./-]+\.[a-zA-Z]{1,6}(:[0-9]+(-[0-9]+)?)?' \
    | sed 's/:.*$//' \
    | grep -vE '^https?:' \
    | grep -vE '^\.' \
    | sort -u)"

[ -z "$REFERENCED_FILES" ] && exit 0

# Tool calls in this turn — extract Read/Grep/Glob targets from tool_use entries
# after TURN_START_LINE.
TOOLS_USED="$(awk -v start="$TURN_START_LINE" 'NR>start' "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.role=="assistant") | .content[]? | select(.type=="tool_use") | select(.name=="Read" or .name=="Grep" or .name=="Glob") | .input | (.file_path // .path // .pattern // "")' 2>/dev/null \
    | sort -u)"

# Cross-check: for each referenced file, was a Read/Grep/Glob touching it?
# Match is generous — basename match counts (handles relative vs absolute).
VIOLATIONS=""
while IFS= read -r FILE; do
    [ -z "$FILE" ] && continue
    BASENAME="$(basename "$FILE")"
    if ! printf '%s' "$TOOLS_USED" | grep -qF "$BASENAME"; then
        VIOLATIONS="${VIOLATIONS}${FILE}\n"
    fi
done <<EOF
$REFERENCED_FILES
EOF

# No violations → quiet success.
[ -z "$VIOLATIONS" ] && exit 0

# ── Decide mode: blocking or warning ────────────────────────────────────────
# Walk up to find .claude/enforcement.json (same pattern as other hooks).
HONESTY_BLOCKING="false"
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
if [ -f "$CONFIG" ]; then
    HONESTY_BLOCKING=$(jq -r '.honesty_blocking // false' "$CONFIG" 2>/dev/null)
fi

# ── Emit message ────────────────────────────────────────────────────────────
if [ "$HONESTY_BLOCKING" = "true" ]; then
    LABEL="BLOCK"
    TAIL="Either Read the file(s) above and re-state with citations, OR remove the unsourced claim from the response. Re-send the corrected message; this gate re-checks each Stop until clean.\n\nOpt-out of blocking mode: set 'honesty_blocking: false' in .claude/enforcement.json — the hook reverts to non-blocking WARN."
else
    LABEL="WARN"
    TAIL="If any claim about these files was stated as fact, it may be a guess.\nOpt-in to blocking mode: set 'honesty_blocking: true' in .claude/enforcement.json."
fi

{
    printf '\n[honesty %s] The final response references files that were not Read/Grep'\''d in this turn:\n' "$LABEL"
    printf '%b' "$VIOLATIONS" | sed 's/^/  - /'
    printf '\nPer core-standards:honesty Rule 1, factual claims require a citation backed by an actual read in this turn.\n'
    printf '%b\n\n' "$TAIL"
} >&2

# Exit code depends on mode.
if [ "$HONESTY_BLOCKING" = "true" ]; then
    exit 2
fi
exit 0
