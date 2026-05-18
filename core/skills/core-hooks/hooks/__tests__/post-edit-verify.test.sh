#!/bin/bash
# Unit tests for post-edit-verify.sh.
# Run with: bash core/skills/core-hooks/hooks/__tests__/post-edit-verify.test.sh

set +e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/post-edit-verify.sh"

[ ! -x "$HOOK" ] && { chmod +x "$HOOK" 2>/dev/null; }
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

mk_config() {
  mkdir -p "$TESTDIR/.claude"
  printf '%s' "$1" > "$TESTDIR/.claude/enforcement.json"
}
rm_config() { rm -f "$TESTDIR/.claude/enforcement.json"; }

# Build a transcript with N edit tool calls of the given paths,
# optionally an assistant text containing a verification keyword.
# Usage: build_transcript "edit1,edit2,edit3" [final_text]
build_transcript() {
  local paths="$1" final_text="$2" file="$TESTDIR/transcript-$RANDOM.jsonl"
  {
    printf '%s\n' '{"role":"user","content":[{"type":"text","text":"do work"}]}'
    IFS=',' read -ra ARR <<< "$paths"
    for p in "${ARR[@]}"; do
      [ -z "$p" ] && continue
      jq -cn --arg p "$p" \
        '{role:"assistant",content:[{type:"tool_use",name:"Edit",input:{file_path:$p}}]}'
    done
    if [ -n "$final_text" ]; then
      jq -cn --arg t "$final_text" \
        '{role:"assistant",content:[{type:"text",text:$t}]}'
    fi
  } > "$file"
  printf '%s' "$file"
}

build_transcript_with_bash() {
  local paths="$1" bash_cmd="$2" file="$TESTDIR/transcript-bash-$RANDOM.jsonl"
  {
    printf '%s\n' '{"role":"user","content":[{"type":"text","text":"do work"}]}'
    IFS=',' read -ra ARR <<< "$paths"
    for p in "${ARR[@]}"; do
      jq -cn --arg p "$p" \
        '{role:"assistant",content:[{type:"tool_use",name:"Edit",input:{file_path:$p}}]}'
    done
    jq -cn --arg c "$bash_cmd" \
      '{role:"assistant",content:[{type:"tool_use",name:"Bash",input:{command:$c}}]}'
  } > "$file"
  printf '%s' "$file"
}

call_hook() {
  jq -cn --arg t "$1" '{transcript_path:$t}' | bash "$HOOK" 2>/dev/null
  echo $?
}

# ── Tests ────────────────────────────────────────────────────────────────────
echo "=== post-edit-verify.sh tests ==="

# T1: no config → silent no-op
echo "T1: no enforcement.json → exit 0 (silent)"
rm_config
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts,src/d.ts" "done")
assert_exit "no config + many edits → exit 0" "0" "$(call_hook "$TR")"

# T2: explicit off → silent
echo "T2: verify_required: false → exit 0 (silent)"
mk_config '{"verify_required": false}'
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts,src/d.ts" "done")
assert_exit "verify_required=false → exit 0" "0" "$(call_hook "$TR")"

# T3: opt-in WARN, below threshold → exit 0 (no nudge)
echo "T3: WARN mode, below threshold (2 of 3) → exit 0"
mk_config '{"verify_required": true}'
TR=$(build_transcript "src/a.ts,src/b.ts" "done")
assert_exit "2 files, no verify → exit 0" "0" "$(call_hook "$TR")"

# T4: opt-in WARN, at threshold, no verify artifact → exit 0 (warn only)
echo "T4: WARN mode, at threshold (3), no verify → exit 0 (still warns)"
mk_config '{"verify_required": true}'
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts" "done")
assert_exit "3 files no verify, warn mode → exit 0" "0" "$(call_hook "$TR")"

# T5: opt-in STRICT, at threshold, no verify artifact → exit 2 (block)
echo "T5: STRICT mode, at threshold, no verify → exit 2"
mk_config '{"verify_required": "strict"}'
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts" "all good, done")
assert_exit "3 files no verify, strict → exit 2" "2" "$(call_hook "$TR")"

# T6: STRICT, at threshold, "Verification report" in text → exit 0 (cleared)
echo "T6: STRICT, at threshold, verification report present → exit 0"
mk_config '{"verify_required": "strict"}'
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts" "Verification report — date 2026-05-18. All passed.")
assert_exit "verify report present, strict → exit 0" "0" "$(call_hook "$TR")"

# T7: STRICT, at threshold, "verify-changes" mentioned → exit 0 (cleared)
echo "T7: STRICT, at threshold, verify-changes invoked text → exit 0"
mk_config '{"verify_required": "strict"}'
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts" "Ran verify-changes. PASS.")
assert_exit "verify-changes mentioned → exit 0" "0" "$(call_hook "$TR")"

# T8: STRICT, at threshold, test runner Bash command → exit 0 (cleared)
echo "T8: STRICT, at threshold, test runner ran → exit 0"
mk_config '{"verify_required": "strict"}'
TR=$(build_transcript_with_bash "src/a.ts,src/b.ts,src/c.ts" "npm test")
assert_exit "test runner Bash ran, strict → exit 0" "0" "$(call_hook "$TR")"

# T9: trivial files don't count
echo "T9: trivial files (.md, .json, /test/) don't count toward threshold"
mk_config '{"verify_required": "strict"}'
TR=$(build_transcript "README.md,package.json,test/a.test.ts,src/x.ts" "done")
assert_exit "3 trivial + 1 real → exit 0 (count=1)" "0" "$(call_hook "$TR")"

# T10: custom threshold
echo "T10: custom verify_threshold: 5"
mk_config '{"verify_required": "strict", "verify_threshold": 5}'
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts,src/d.ts" "done")
assert_exit "4 files, threshold=5, no verify → exit 0" "0" "$(call_hook "$TR")"
TR=$(build_transcript "src/a.ts,src/b.ts,src/c.ts,src/d.ts,src/e.ts" "done")
assert_exit "5 files, threshold=5, no verify, strict → exit 2" "2" "$(call_hook "$TR")"

# T11: malformed input → fail-open
echo "T11: malformed input → exit 0"
mk_config '{"verify_required": "strict"}'
empty_actual=$(echo "" | bash "$HOOK" 2>/dev/null; echo $?)
assert_exit "empty stdin → exit 0" "0" "$empty_actual"
bad_actual=$(echo "{not json}" | bash "$HOOK" 2>/dev/null; echo $?)
assert_exit "invalid JSON → exit 0" "0" "$bad_actual"
notrans_actual=$(echo '{"foo":"bar"}' | bash "$HOOK" 2>/dev/null; echo $?)
assert_exit "no transcript_path → exit 0" "0" "$notrans_actual"

echo ""
echo "=== Results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -gt 0 ] && { printf '%b\n' "$FAIL_LOG" >&2; exit 1; }
exit 0
