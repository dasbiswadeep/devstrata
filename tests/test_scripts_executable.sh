#!/usr/bin/env bash
# test_scripts_executable.sh — every script in scripts/ + tests/ must have
# the executable bit set. A non-executable install.sh is a common packaging bug.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

for f in "$REPO"/scripts/*.sh "$REPO"/tests/test_*.sh; do
  [ -f "$f" ] || continue
  if [ -x "$f" ]; then
    echo "PASS: $(basename "$f") is executable"
  else
    echo "FAIL: $(basename "$f") is NOT executable"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1