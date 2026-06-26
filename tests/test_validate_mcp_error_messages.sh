#!/usr/bin/env bash
# test_validate_mcp_error_messages.sh — verify validate-mcp.sh gives concrete
# install commands (not just "run update.sh") when a server is broken.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
VM="$REPO/scripts/validate-mcp.sh"
FAIL=0

# 1. error section lists concrete fixes per tool
for tool in "uvx" "npx" "helix" "mem0" "graphify"; do
  if grep -q "$tool" "$VM"; then
    echo "PASS: validate-mcp.sh error mentions $tool"
  else
    echo "FAIL: validate-mcp.sh error missing $tool fix"
    FAIL=1
  fi
done

# 2. uvx fix points to astral.sh/uv (the actual install command)
if grep -q 'astral.sh/uv/install' "$VM"; then
  echo "PASS: validate-mcp.sh points uvx error to astral.sh/uv"
else
  echo "FAIL: validate-mcp.sh uvx error missing install command"
  FAIL=1
fi

# 3. Node error points to nodejs.org
if grep -q 'nodejs.org' "$VM"; then
  echo "PASS: validate-mcp.sh points npx error to nodejs.org"
else
  echo "FAIL: validate-mcp.sh npx error missing nodejs.org"
  FAIL=1
fi

# 4. error says "re-run" with the script path (so user knows how to re-check)
if grep -q 're-run\|After fixing' "$VM"; then
  echo "PASS: validate-mcp.sh tells user to re-run after fixing"
else
  echo "FAIL: validate-mcp.sh missing re-run guidance"
  FAIL=1
fi

# 5. does NOT just say "run update.sh" (the old wrong message)
if grep -q 'update.sh to check for upstream' "$VM"; then
  echo "FAIL: validate-mcp.sh still says 'run update.sh' (wrong — update checks versions, not missing binaries)"
  FAIL=1
else
  echo "PASS: validate-mcp.sh no longer says 'run update.sh'"
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1