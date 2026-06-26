#!/usr/bin/env bash
# test_bash_syntax.sh — every script in scripts/ parses cleanly.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

for f in "$REPO"/scripts/*.sh; do
  if bash -n "$f" 2>/dev/null; then
    echo "PASS: bash -n $(basename "$f")"
  else
    echo "FAIL: bash -n $(basename "$f") — syntax error"
    bash -n "$f"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1