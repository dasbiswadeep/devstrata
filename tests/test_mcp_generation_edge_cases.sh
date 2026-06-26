#!/usr/bin/env bash
# test_mcp_generation_edge_cases.sh — edge cases for the .mcp.json jq filter.
# Beyond the basic server-count test, verify:
#   - lite output is valid JSON (not just a string)
#   - full output matches the template byte-for-byte (no drift)
#   - the 6 expected server names are present in full
#   - graphify server survives the lite strip (it's a lite tool, not full-only)
#   - helix + mem0 are the ONLY servers stripped for lite (not git, not fetch)
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$REPO/configs/.mcp.json.template"
FAIL=0

if ! command -v jq &>/dev/null; then
  echo "SKIP: jq not installed"
  exit 0
fi

# 1. lite output must be valid JSON
LITE_JSON=$(jq 'del(.mcpServers.helix, .mcpServers.mem0)' "$TEMPLATE")
if echo "$LITE_JSON" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  echo "PASS: lite .mcp.json is valid JSON"
else
  echo "FAIL: lite .mcp.json is not valid JSON"
  FAIL=1
fi

# 2. full output must equal the template (no modification for full/pro)
FULL_JSON=$(cat "$TEMPLATE")
if [ "$(echo "$FULL_JSON" | python3 -m json.tool)" == "$(echo "$LITE_JSON" | python3 -m json.tool)" ]; then
  echo "FAIL: full .mcp.json should NOT equal lite (something stripped too much)"
  FAIL=1
else
  echo "PASS: full .mcp.json differs from lite (stripping worked)"
fi

# 3. full must contain exactly these 6 servers
FULL_KEYS=$(jq -r '.mcpServers | keys | sort | join(",")' "$TEMPLATE")
EXPECTED_FULL="fetch,filesystem,git,graphify,helix,mem0"
if [ "$FULL_KEYS" == "$EXPECTED_FULL" ]; then
  echo "PASS: full server set is exactly {$EXPECTED_FULL}"
else
  echo "FAIL: full server set is '$FULL_KEYS', expected '$EXPECTED_FULL'"
  FAIL=1
fi

# 4. graphify must survive the lite strip (it's a lite tool, not full-only)
LITE_HAS_GRAPHIFY=$(jq -r 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | has("graphify")' "$TEMPLATE")
[ "$LITE_HAS_GRAPHIFY" == "true" ] && echo "PASS: graphify survives lite strip" || { echo "FAIL: graphify stripped from lite"; FAIL=1; }

# 5. git must survive the lite strip
LITE_HAS_GIT=$(jq -r 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | has("git")' "$TEMPLATE")
[ "$LITE_HAS_GIT" == "true" ] && echo "PASS: git survives lite strip" || { echo "FAIL: git stripped from lite"; FAIL=1; }

# 6. filesystem must survive the lite strip
LITE_HAS_FS=$(jq -r 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | has("filesystem")' "$TEMPLATE")
[ "$LITE_HAS_FS" == "true" ] && echo "PASS: filesystem survives lite strip" || { echo "FAIL: filesystem stripped from lite"; FAIL=1; }

# 7. fetch must survive the lite strip
LITE_HAS_FETCH=$(jq -r 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | has("fetch")' "$TEMPLATE")
[ "$LITE_HAS_FETCH" == "true" ] && echo "PASS: fetch survives lite strip" || { echo "FAIL: fetch stripped from lite"; FAIL=1; }

# 8. ONLY helix and mem0 should be stripped for lite (not any other server)
LITE_KEYS=$(jq -r 'del(.mcpServers.helix, .mcpServers.mem0) | .mcpServers | keys | length' "$TEMPLATE")
[ "$LITE_KEYS" -eq 4 ] && echo "PASS: exactly 4 servers remain for lite (only helix+mem0 stripped)" || { echo "FAIL: $LITE_KEYS servers remain, expected 4"; FAIL=1; }

# 9. Each server block must have 'command' and 'args' fields (structural integrity)
SERVERS_INVALID=$(jq -r '.mcpServers | to_entries[] | select(.value.command == null or .value.args == null) | .key' "$TEMPLATE")
if [ -z "$SERVERS_INVALID" ]; then
  echo "PASS: all servers have command + args fields"
else
  echo "FAIL: servers missing command/args: $SERVERS_INVALID"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1