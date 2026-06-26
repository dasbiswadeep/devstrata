#!/usr/bin/env bash
# test_backends_graphify_cli.sh — verify BACKENDS.md uses the correct graphify CLI.
# Round 5 found it showed `graphify extract . --backend ollama` but `extract` is
# NOT a graphify subcommand. The real command is `graphify . --backend=ollama`.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOC="$REPO/docs/BACKENDS.md"
FAIL=0

# 1. BACKENDS.md must NOT show `graphify extract` (non-existent subcommand)
if grep -q 'graphify extract' "$DOC"; then
  echo "FAIL: BACKENDS.md uses 'graphify extract' (not a real subcommand)"
  FAIL=1
else
  echo "PASS: BACKENDS.md no longer uses non-existent 'graphify extract'"
fi

# 2. must use `graphify .` (the real build command)
if grep -q 'graphify \.' "$DOC"; then
  echo "PASS: BACKENDS.md uses 'graphify .' (real build command)"
else
  echo "FAIL: BACKENDS.md doesn't show 'graphify .'"
  FAIL=1
fi

# 3. --backend flag must use = syntax (--backend=ollama, not --backend ollama with space)
# Actually graphify accepts both, but = is the documented form. Either is fine.
if grep -q -- '--backend' "$DOC"; then
  echo "PASS: BACKENDS.md shows --backend flag for graphify"
else
  echo "FAIL: BACKENDS.md missing --backend flag for graphify"
  FAIL=1
fi

# 4. must mention auto-detect (graphify auto-detects from env vars by default)
if grep -qi 'auto-detect' "$DOC"; then
  echo "PASS: BACKENDS.md mentions graphify auto-detects backend"
else
  echo "FAIL: BACKENDS.md doesn't mention auto-detection"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1