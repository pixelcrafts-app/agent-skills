#!/bin/bash
# Unit tests for agent-traffic.sh.
# Run with: bash core/skills/core-hooks/hooks/__tests__/agent-traffic.test.sh

set +e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/agent-traffic.sh"
[ ! -x "$HOOK" ] && chmod +x "$HOOK" 2>/dev/null
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
    FAIL_LOG="$FAIL_LOG\n  ✗ $desc — expected=$expected, got=$actual"
    printf '  ✗ %s — expected=%s, got=%s\n' "$desc" "$expected" "$actual"
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if printf '%s' "$haystack" | grep -qF -- "$needle"; then
    PASS=$((PASS + 1))
    printf '  ✓ %s\n' "$desc"
  else
    FAIL=$((FAIL + 1))
    FAIL_LOG="$FAIL_LOG\n  ✗ $desc — missing needle: $needle"
    printf '  ✗ %s — missing needle: %s\n' "$desc" "$needle"
  fi
}

assert_not_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if printf '%s' "$haystack" | grep -qF -- "$needle"; then
    FAIL=$((FAIL + 1))
    FAIL_LOG="$FAIL_LOG\n  ✗ $desc — found needle that shouldn't be there: $needle"
    printf '  ✗ %s — found unexpected: %s\n' "$desc" "$needle"
  else
    PASS=$((PASS + 1))
    printf '  ✓ %s\n' "$desc"
  fi
}

TESTDIR=$(mktemp -d)
trap 'rm -rf "$TESTDIR"' EXIT
export CLAUDE_PROJECT_DIR="$TESTDIR"

mk_config() {
  mkdir -p "$TESTDIR/.claude"
  printf '%s' "$1" > "$TESTDIR/.claude/enforcement.json"
}
rm_config() { rm -f "$TESTDIR/.claude/enforcement.json"; rm -f "$TESTDIR/.claude/agent-traffic.log"; }

call_pre() {
  printf '%s' "$1" | bash "$HOOK" pre 2>&1
  echo "__EXIT__$?"
}
call_post() {
  printf '%s' "$1" | bash "$HOOK" post 2>&1
  echo "__EXIT__$?"
}

# ── Tests ────────────────────────────────────────────────────────────────────
echo "=== agent-traffic.sh tests ==="

# T1: non-Agent tool → silent no-op
echo "T1: non-Agent tool → silent no-op"
rm_config
PAYLOAD='{"tool_name":"Edit","tool_input":{"file_path":"/foo.ts"}}'
OUT=$(call_pre "$PAYLOAD")
assert_exit "Edit tool, pre → exit 0" "0" "$(echo "$OUT" | grep -oE '__EXIT__[0-9]+' | sed 's/__EXIT__//')"
[ ! -f "$TESTDIR/.claude/agent-traffic.log" ] && PASS=$((PASS+1)) && echo "  ✓ Edit tool → no log written" \
  || { FAIL=$((FAIL+1)); echo "  ✗ Edit tool → log was written"; }

# T2: Agent spawn → log + stderr
echo "T2: Agent spawn → log + live stderr"
rm_config
PAYLOAD='{"tool_name":"Agent","tool_input":{"subagent_type":"Explore","description":"Find auth files"}}'
OUT=$(call_pre "$PAYLOAD")
assert_exit "Agent pre → exit 0" "0" "$(echo "$OUT" | grep -oE '__EXIT__[0-9]+' | sed 's/__EXIT__//')"
assert_contains "Agent pre → stderr has SPAWN" "SPAWN" "$OUT"
assert_contains "Agent pre → stderr has subagent_type" "Explore" "$OUT"
assert_contains "Agent pre → stderr has description" "Find auth files" "$OUT"
[ -f "$TESTDIR/.claude/agent-traffic.log" ] && PASS=$((PASS+1)) && echo "  ✓ log file created" \
  || { FAIL=$((FAIL+1)); echo "  ✗ log file not created"; }
assert_contains "log has SPAWN entry" "SPAWN" "$(cat $TESTDIR/.claude/agent-traffic.log 2>/dev/null)"

# T3: Agent post → log + stderr with byte count
echo "T3: Agent post → log + stderr with byte count"
rm_config
PAYLOAD='{"tool_name":"Agent","tool_input":{"subagent_type":"Explore"},"tool_response":"Hello back from agent"}'
OUT=$(call_post "$PAYLOAD")
assert_exit "Agent post → exit 0" "0" "$(echo "$OUT" | grep -oE '__EXIT__[0-9]+' | sed 's/__EXIT__//')"
assert_contains "post stderr has RETURN" "RETURN" "$OUT"
assert_contains "post stderr has byte count" "bytes" "$OUT"

# T4: Task tool also captured
echo "T4: Task tool captured the same way"
rm_config
PAYLOAD='{"tool_name":"Task","tool_input":{"description":"Plan the feature"}}'
OUT=$(call_pre "$PAYLOAD")
assert_contains "Task pre → SPAWN logged" "SPAWN" "$OUT"
assert_contains "Task pre → general type fallback" "general" "$OUT"

# T5: agent_traffic_log: false → silent
echo "T5: agent_traffic_log: false → silent (no log, no stderr)"
mk_config '{"agent_traffic_log": false}'
PAYLOAD='{"tool_name":"Agent","tool_input":{"subagent_type":"Explore","description":"x"}}'
OUT=$(call_pre "$PAYLOAD")
assert_exit "opted out → exit 0" "0" "$(echo "$OUT" | grep -oE '__EXIT__[0-9]+' | sed 's/__EXIT__//')"
assert_not_contains "opted out → no SPAWN in stderr" "SPAWN" "$OUT"

# T6: malformed input → fail-open
echo "T6: malformed input → fail-open"
rm_config
empty_actual=$(echo "" | bash "$HOOK" pre 2>/dev/null; echo $?)
assert_exit "empty stdin pre → exit 0" "0" "$empty_actual"
bad_actual=$(echo "{not json}" | bash "$HOOK" pre 2>/dev/null; echo $?)
assert_exit "invalid JSON pre → exit 0" "0" "$bad_actual"
notool_actual=$(echo '{"foo":"bar"}' | bash "$HOOK" pre 2>/dev/null; echo $?)
assert_exit "no tool_name pre → exit 0" "0" "$notool_actual"

# T7: wrong mode arg → silent
echo "T7: invalid mode arg → silent"
PAYLOAD='{"tool_name":"Agent","tool_input":{"subagent_type":"Explore"}}'
bogus_actual=$(printf '%s' "$PAYLOAD" | bash "$HOOK" bogus 2>/dev/null; echo $?)
assert_exit "mode=bogus → exit 0 silent" "0" "$bogus_actual"

echo ""
echo "=== Results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -gt 0 ] && { printf '%b\n' "$FAIL_LOG" >&2; exit 1; }
exit 0
