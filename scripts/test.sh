#!/usr/bin/env bash
# test.sh — run all devstrata integration + structural tests.
# Auto-discovers tests/test_*.sh and runs each.
# Exit non-zero if any test fails.
#
# Usage:
#   ./scripts/test.sh           # run all
#   ./scripts/test.sh tests/test_structure.sh  # run one

set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$REPO/tests"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAILS=0
SKIP=0

# Discover tests
if [ $# -gt 0 ]; then
  TESTS=("$@")
else
  TESTS=( "$TESTS_DIR"/test_*.sh )
fi

echo ""
echo "devstrata test suite"
echo "──────────────────────────────────"
echo ""

for t in "${TESTS[@]}"; do
  if [ ! -f "$t" ]; then
    echo -e "${RED}MISSING: $t${NC}"
    FAILS=$((FAILS+1))
    continue
  fi
  if [ ! -x "$t" ]; then
    chmod +x "$t" 2>/dev/null || true
  fi
  # Run it
  OUTPUT=$(bash "$t" 2>&1)
  # Print each PASS/FAIL/SKIP line with color
  echo "$OUTPUT" | grep -E "^(PASS|FAIL|SKIP):" | while IFS= read -r line; do
    if [[ "$line" == PASS:* ]]; then
      echo -e "${GREEN}✓${NC} ${line#PASS: }"
    elif [[ "$line" == FAIL:* ]]; then
      echo -e "${RED}✗${NC} ${line#FAIL: }"
    elif [[ "$line" == SKIP:* ]]; then
      echo -e "${YELLOW}⊘${NC} ${line#SKIP: }"
    fi
  done
  # Print any diagnostic output (non-PASS/FAIL/SKIP lines)
  echo "$OUTPUT" | grep -vE "^(PASS|FAIL|SKIP):" | sed 's/^/    /' | grep -vE '^\s*$'

  # Count this file as pass or fail (one file = one outcome)
  if echo "$OUTPUT" | grep -qE '^FAIL:'; then
    FAILS=$((FAILS+1))
  elif echo "$OUTPUT" | grep -qE '^SKIP:' && ! echo "$OUTPUT" | grep -qE '^PASS:'; then
    SKIP=$((SKIP+1))
  else
    PASS=$((PASS+1))
  fi
done

echo ""
echo "──────────────────────────────────"
TOTAL=$(echo "${TESTS[@]}" | wc -w | tr -d ' ')
if [ "$FAILS" -eq 0 ]; then
  echo -e "${GREEN}$PASS/$TOTAL test files passed${NC}"
  exit 0
else
  echo -e "${RED}$FAILS of $TOTAL test files failed${NC}"
  exit 1
fi