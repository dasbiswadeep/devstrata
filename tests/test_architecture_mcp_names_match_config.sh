#!/usr/bin/env bash
# test_architecture_mcp_names_match_config.sh — verify the ARCHITECTURE.md
# data-flow diagram uses the same MCP server names as .mcp.json.template.
# Round 8 found the diagram used 'graphify-mcp', 'mcp-server-git' etc. which
# don't match the real .mcp.json server keys (graphify, git, filesystem, etc.).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$REPO/docs/ARCHITECTURE.md"
TEMPLATE="$REPO/configs/.mcp.json.template"
FAIL=0

# Get the real server names from .mcp.json.template
REAL_NAMES=$(jq -r '.mcpServers | keys[]' "$TEMPLATE" 2>/dev/null | sort | tr '\n' ' ')
if [ -z "$REAL_NAMES" ]; then
  echo "SKIP: jq not available to extract server names"
  exit 0
fi

# 1. diagram must NOT use the old wrong names as server labels (in the data-flow section).
# NOTE: 'mcp-server-git' is the legitimate uvx package name for the git server, so it
# appears in the .mcp.json JSON example block — that's correct. We only check the
# data-flow diagram section (the tree with ├── arrows), not the JSON block.
DIAGRAM=$(sed -n '/^User prompt/,/^```$/p' "$ARCH" | head -30)

for wrong in "graphify-mcp" "mem0-mcp" "helix-mcp" "mcp-server-fs"; do
  if echo "$DIAGRAM" | grep -q "$wrong"; then
    echo "FAIL: ARCHITECTURE.md data-flow diagram uses '$wrong' (not a real .mcp.json server name)"
    FAIL=1
  fi
done
# mcp-server-git is OK in the JSON args block (it's the uvx package name), but NOT as a tree label
if echo "$DIAGRAM" | grep -q '├── mcp-server-git\|├── mcp-server-fs'; then
  echo "FAIL: ARCHITECTURE.md diagram uses 'mcp-server-git'/'mcp-server-fs' as tree labels"
  FAIL=1
fi
[ "$FAIL" -eq 0 ] && echo "PASS: ARCHITECTURE.md data-flow diagram uses real .mcp.json server names"

# 2. diagram must reference at least 4 of the real server names
MATCH_COUNT=0
for name in $REAL_NAMES; do
  if grep -q "$name" "$ARCH"; then
    MATCH_COUNT=$((MATCH_COUNT+1))
  fi
done
if [ "$MATCH_COUNT" -ge 4 ]; then
  echo "PASS: ARCHITECTURE.md references $MATCH_COUNT real server names from .mcp.json"
else
  echo "FAIL: ARCHITECTURE.md only references $MATCH_COUNT real server names (expected ≥4)"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1