#!/bin/bash
# Stop hook — surfaces honesty violations: factual claims about files that
# were never Read/Grep'd in the same turn. Non-blocking by design — emits a
# WARN to stderr so the user sees it. The agent learns to either read first
# or say "I haven't checked".
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
# Excludes URLs (http*) and bare file names without a slash (too noisy).
REFERENCED_FILES="$(printf '%s' "$FINAL_TEXT" \
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

# Emit WARN to stderr — non-blocking. The user sees the message; the agent
# sees it next turn via transcript review.
{
    printf '\n[honesty WARN] The final response references files that were not Read/Grep'\''d in this turn:\n'
    printf '%b' "$VIOLATIONS" | sed 's/^/  - /'
    printf '\nIf any claim about these files was stated as fact, it may be a guess.\n'
    printf 'Per core-standards:honesty Rule 1, factual claims require a citation backed by an actual read in this turn.\n\n'
} >&2

# Exit 0 — do NOT block the turn. This is observability, not a gate.
exit 0
