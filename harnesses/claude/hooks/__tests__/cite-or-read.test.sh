#!/bin/bash
# Unit tests for cite-or-read.sh.
# Verifies both modes: default WARN (exit 0) and opt-in BLOCK (exit 2).
# Run with: bash core/skills/core-hooks/hooks/__tests__/cite-or-read.test.sh

set +e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/cite-or-read.sh"

[ ! -x "$HOOK" ] && { echo "ERROR: hook not executable: $HOOK" >&2; exit 1; }

PASS=0
FAIL=0
FAIL_LOG=""

assert_exit() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    PASS=$((PASS + 1))
    printf '  ✓ %s\n' "$desc"
  else
    FAIL=$((FAIL + 1))
    FAIL_LOG="$FAIL_LOG\n  ✗ $desc — expected exit=$expected, got exit=$actual"
    printf '  ✗ %s — expected exit=%s, got exit=%s\n' "$desc" "$expected" "$actual"
  fi
}

TESTDIR=$(mktemp -d)
trap 'rm -rf "$TESTDIR"' EXIT
export CLAUDE_PROJECT_DIR="$TESTDIR"

mk_enforcement_blocking_on() {
  mkdir -p "$TESTDIR/.claude"
  printf '{ "honesty_blocking": true }' > "$TESTDIR/.claude/enforcement.json"
}
mk_enforcement_blocking_off() {
  mkdir -p "$TESTDIR/.claude"
  printf '{ "honesty_blocking": false }' > "$TESTDIR/.claude/enforcement.json"
}
rm_enforcement() { rm -f "$TESTDIR/.claude/enforcement.json"; }

# Build a transcript JSONL file with given assistant text + tool uses.
# Usage: build_transcript <text> [tool_call_path]
build_transcript() {
  local text="$1" tool_path="$2" file="$TESTDIR/transcript-$RANDOM.jsonl"
  {
    printf '%s\n' '{"role":"user","content":[{"type":"text","text":"hello"}]}'
    if [ -n "$tool_path" ]; then
      jq -cn --arg p "$tool_path" \
        '{role:"assistant",content:[{type:"tool_use",name:"Read",input:{file_path:$p}}]}'
    fi
    jq -cn --arg t "$text" \
      '{role:"assistant",content:[{type:"text",text:$t}]}'
  } > "$file"
  printf '%s' "$file"
}

call_hook() {
  local transcript="$1"
  jq -cn --arg t "$transcript" '{transcript_path:$t}' | bash "$HOOK" 2>/dev/null
  echo $?
}

# ── Tests ────────────────────────────────────────────────────────────────────
echo "=== cite-or-read.sh tests ==="

# T1: no violations (text has no file refs) → exit 0 in both modes
echo "T1: no file refs in response → exit 0 in both modes"
TR=$(build_transcript "All done. Tests passing.")
rm_enforcement
assert_exit "no config, no refs → exit 0"            "0" "$(call_hook "$TR")"
mk_enforcement_blocking_on
assert_exit "blocking on, no refs → exit 0"          "0" "$(call_hook "$TR")"

# T2: violations + default mode (no config) → exit 0 (WARN)
echo "T2: violations, no config → exit 0 (WARN mode default)"
rm_enforcement
TR=$(build_transcript "I checked src/auth/service.ts and it validates the token.")
assert_exit "violation, no config → exit 0"          "0" "$(call_hook "$TR")"

# T3: violations + blocking mode → exit 2 (BLOCK)
echo "T3: violations, honesty_blocking: true → exit 2 (BLOCK)"
mk_enforcement_blocking_on
TR=$(build_transcript "I checked src/auth/service.ts and it validates the token.")
assert_exit "violation, blocking on → exit 2"        "2" "$(call_hook "$TR")"

# T4: violations + blocking off → exit 0 (WARN)
echo "T4: violations, honesty_blocking: false → exit 0 (WARN)"
mk_enforcement_blocking_off
TR=$(build_transcript "I checked src/auth/service.ts and it validates the token.")
assert_exit "violation, blocking off → exit 0"       "0" "$(call_hook "$TR")"

# T5: file referenced AND was Read → no violation → exit 0 in either mode
echo "T5: referenced file was Read → exit 0 in either mode"
TR=$(build_transcript "Verified src/auth/service.ts works." "src/auth/service.ts")
mk_enforcement_blocking_on
assert_exit "ref + Read, blocking on → exit 0"       "0" "$(call_hook "$TR")"
mk_enforcement_blocking_off
assert_exit "ref + Read, blocking off → exit 0"      "0" "$(call_hook "$TR")"

# T6: malformed input → fail-open (exit 0) in either mode
echo "T6: malformed input → fail-open exit 0"
mk_enforcement_blocking_on
empty_actual=$(echo "" | bash "$HOOK" 2>/dev/null; echo $?)
assert_exit "empty stdin → exit 0"                   "0" "$empty_actual"
bad_actual=$(echo "{not json}" | bash "$HOOK" 2>/dev/null; echo $?)
assert_exit "invalid JSON → exit 0"                  "0" "$bad_actual"
notrans_actual=$(echo '{"foo":"bar"}' | bash "$HOOK" 2>/dev/null; echo $?)
assert_exit "no transcript_path → exit 0"            "0" "$notrans_actual"

# T7: URLs and bare names are NOT flagged
echo "T7: URLs and bare filenames don't count as violations"
mk_enforcement_blocking_on
TR=$(build_transcript "See https://example.com/foo.ts and also README.md for details.")
assert_exit "URL + bare filename → exit 0"           "0" "$(call_hook "$TR")"

echo ""
echo "=== Results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -gt 0 ] && { printf '%b\n' "$FAIL_LOG" >&2; exit 1; }
exit 0
