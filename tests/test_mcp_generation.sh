#!/usr/bin/env bash
# test_mcp_generation.sh — verify the jq filter produces the right server count
# per profile. This is the single-source-of-truth .mcp.json generation logic
# used by install.sh.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$REPO/configs/.mcp.json.template"
FAIL=0

if ! command -v jq &>/dev/null; then
  echo "SKIP: jq not installed — cannot test .mcp.json generation"
  exit 0
fi

# lite should strip helix + mem0 → 4 servers
LITE_COUNT=$(jq 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | keys | length' "$TEMPLATE")
if [ "$LITE_COUNT" -eq 4 ]; then
  echo "PASS: lite .mcp.json has 4 servers (filesystem, git, fetch, graphify)"
else
  echo "FAIL: lite .mcp.json has $LITE_COUNT servers, expected 4"
  FAIL=1
fi

# lite must NOT contain helix or mem0
LITE_HAS_HELIX=$(jq -r 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | has("helix")' "$TEMPLATE")
[ "$LITE_HAS_HELIX" == "false" ] || { echo "FAIL: lite .mcp.json still has helix"; FAIL=1; }

# full/pro should keep all 6 servers
FULL_COUNT=$(jq '.mcpServers | keys | length' "$TEMPLATE")
if [ "$FULL_COUNT" -eq 6 ]; then
  echo "PASS: full/pro .mcp.json has 6 servers (+ helix, mem0)"
else
  echo "FAIL: full/pro .mcp.json has $FULL_COUNT servers, expected 6"
  FAIL=1
fi

# Verify the 4 lite servers are exactly the expected set
LITE_KEYS=$(jq -r 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | keys | sort | join(",")' "$TEMPLATE")
if [ "$LITE_KEYS" == "fetch,filesystem,git,graphify" ]; then
  echo "PASS: lite server set is exactly {fetch, filesystem, git, graphify}"
else
  echo "FAIL: lite server set is '$LITE_KEYS', expected 'fetch,filesystem,git,graphify'"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1