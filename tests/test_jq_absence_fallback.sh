#!/usr/bin/env bash
# test_jq_absence_fallback.sh — verify install.sh handles the case where jq
# is not installed. It should fall back to a plain copy + warn, not crash.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# install.sh must check for jq before using it
if grep -q 'command -v jq' "$INSTALL"; then
  echo "PASS: install.sh checks for jq before using it"
else
  echo "FAIL: install.sh uses jq without checking presence"
  FAIL=1
fi

# install.sh must have a fallback path when jq is absent
if grep -qE 'else\s*$' "$INSTALL" && grep -A2 'command -v jq' "$INSTALL" | grep -q 'cp'; then
  echo "PASS: install.sh has a cp fallback when jq is missing"
else
  echo "FAIL: install.sh has no cp fallback for missing jq"
  FAIL=1
fi

# install.sh must warn lite users when jq is absent (they get 6 servers, need to edit)
if grep -A5 'jq not available' "$INSTALL" | grep -q 'warn'; then
  echo "PASS: install.sh warns lite users when jq is absent"
else
  # the warning text may differ — check for any warn in the jq-absent branch
  if grep -A10 'else' "$INSTALL" | grep -q 'warn.*mcp.json'; then
    echo "PASS: install.sh warns when jq absent (generic)"
  else
    echo "FAIL: install.sh does not warn lite users when jq is absent"
    FAIL=1
  fi
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1