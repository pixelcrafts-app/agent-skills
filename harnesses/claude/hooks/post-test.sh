#!/bin/bash
# PostToolUse hook — runs related tests after every Write/Edit to a source file.
# Detects stack from project root, runs the appropriate fast test suite.
# Exit 2: Claude must fix the failure before the turn can proceed.
# Fail-open: any detection or runner error → exit 0 (never strand the user).

set +e

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE" ] && exit 0

# Skip infrastructure, config, and non-source files.
case "$FILE" in
  */.claude/*|*/node_modules/*|*/.git/*|*/build/*|*/dist/*|*/.next/*|*/out/*|*/.dart_tool/*) exit 0 ;;
  *.md|*.json|*.yaml|*.yml|*.txt|*.sh|*.lock|*.gitignore|*.env*|*.toml|*.gradle) exit 0 ;;
esac

# Skip test files themselves — they are not the source under test.
case "$FILE" in
  *_test.dart|*.test.ts|*.test.js|*.spec.ts|*.spec.js|*_test.go|*_test.py) exit 0 ;;
  */tests/*|*/test/*|*/spec/*|*/contracts/*|*/acceptance/*) exit 0 ;;
esac

# Locate project root: walk up until we find a known manifest.
ROOT="$FILE"
HOPS=0
while [ "$ROOT" != "/" ] && [ $HOPS -lt 20 ]; do
  ROOT=$(dirname "$ROOT")
  HOPS=$((HOPS + 1))
  [ -f "$ROOT/pubspec.yaml" ] && break
  [ -f "$ROOT/package.json" ] && break
  [ -f "$ROOT/go.mod" ] && break
  [ -f "$ROOT/Cargo.toml" ] && break
  [ -f "$ROOT/requirements.txt" ] || [ -f "$ROOT/pyproject.toml" ] && break
done

[ "$ROOT" = "/" ] && exit 0

# --- Flutter ---
if [ -f "$ROOT/pubspec.yaml" ]; then
  command -v flutter >/dev/null 2>&1 || exit 0
  # Run unit tests only for speed; acceptance/integration run at Stop gate.
  UNIT_DIR="$ROOT/test/unit"
  [ ! -d "$UNIT_DIR" ] && UNIT_DIR="$ROOT/test"
  RESULT=$(cd "$ROOT" && flutter test "$UNIT_DIR" 2>&1)
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    {
      printf 'Tests failed after writing %s:\n\n%s\n\n' "$(basename "$FILE")" "$RESULT"
      printf 'Fix the failing tests. Do not modify test files to force a pass.\n'
    } >&2
    exit 2
  fi
  exit 0
fi

# --- Node / TypeScript (Jest) ---
if [ -f "$ROOT/package.json" ]; then
  TEST_SCRIPT=$(jq -r '.scripts.test // empty' "$ROOT/package.json" 2>/dev/null)
  [ -z "$TEST_SCRIPT" ] || [ "$TEST_SCRIPT" = "null" ] && exit 0

  command -v npx >/dev/null 2>&1 || exit 0

  # Find related test file (same basename, .test.ts / .spec.ts).
  BASENAME=$(basename "$FILE" | sed 's/\.[^.]*$//')
  RELATED=$(find "$ROOT/src" "$ROOT/tests" "$ROOT/test" -maxdepth 6 \
    \( -name "${BASENAME}.test.ts" -o -name "${BASENAME}.test.js" \
       -o -name "${BASENAME}.spec.ts" -o -name "${BASENAME}.spec.js" \) \
    2>/dev/null | head -1)

  if [ -n "$RELATED" ]; then
    RESULT=$(cd "$ROOT" && npx jest --testPathPattern="$(basename "$RELATED")" --passWithNoTests --forceExit 2>&1)
  else
    # No related test — run fast unit test subset only.
    RESULT=$(cd "$ROOT" && npx jest --testPathPattern="unit" --passWithNoTests --forceExit 2>&1)
  fi
  STATUS=$?

  if [ $STATUS -ne 0 ]; then
    {
      printf 'Tests failed after writing %s:\n\n%s\n\n' "$(basename "$FILE")" "$RESULT"
      printf 'Fix the failing tests. Do not modify test files to force a pass.\n'
    } >&2
    exit 2
  fi
  exit 0
fi

# --- Go ---
if [ -f "$ROOT/go.mod" ]; then
  command -v go >/dev/null 2>&1 || exit 0
  PKG_DIR=$(dirname "$FILE")
  RESULT=$(cd "$ROOT" && go test "$PKG_DIR/..." 2>&1)
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    {
      printf 'Tests failed after writing %s:\n\n%s\n\n' "$(basename "$FILE")" "$RESULT"
      printf 'Fix the failing tests. Do not modify test files to force a pass.\n'
    } >&2
    exit 2
  fi
  exit 0
fi

# --- Python (pytest) ---
if [ -f "$ROOT/requirements.txt" ] || [ -f "$ROOT/pyproject.toml" ]; then
  command -v pytest >/dev/null 2>&1 || exit 0
  BASENAME=$(basename "$FILE" | sed 's/\.[^.]*$//')
  RELATED=$(find "$ROOT/tests" "$ROOT/test" -maxdepth 6 \
    \( -name "test_${BASENAME}.py" -o -name "${BASENAME}_test.py" \) \
    2>/dev/null | head -1)
  if [ -n "$RELATED" ]; then
    RESULT=$(cd "$ROOT" && pytest "$RELATED" -q 2>&1)
  else
    RESULT=$(cd "$ROOT" && pytest tests/unit/ -q 2>&1)
  fi
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    {
      printf 'Tests failed after writing %s:\n\n%s\n\n' "$(basename "$FILE")" "$RESULT"
      printf 'Fix the failing tests. Do not modify test files to force a pass.\n'
    } >&2
    exit 2
  fi
  exit 0
fi

exit 0
