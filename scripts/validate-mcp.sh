#!/usr/bin/env bash
# validate-mcp.sh — validate that every server in .mcp.json has a command
# that actually exists on PATH. Catches the most common WF-002 failure mode:
# tool updated → command renamed/removed → .mcp.json silently broken.
#
# Usage: ./scripts/validate-mcp.sh [path/to/.mcp.json]
# Exit: 0 = all servers valid, 1 = one or more broken
set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MCP="${1:-.mcp.json}"
FAIL=0

[ -f "$MCP" ] || { echo -e "${RED}✗${NC} $MCP not found"; exit 1; }

if ! command -v jq &>/dev/null; then
  echo -e "${YELLOW}⚠${NC}  jq not installed — cannot validate. Install: brew install jq / apt install jq"
  exit 2
fi

# Validate JSON is parseable before iterating (otherwise jq errors silently
# and we'd report "all valid" on a broken file)
if ! jq empty "$MCP" >/dev/null 2>&1; then
  echo -e "${RED}✗${NC} $MCP is not valid JSON — fix the syntax before validating servers"
  jq empty "$MCP" 2>&1 | sed 's/^/    /'
  exit 1
fi

echo "Validating $MCP ..."
echo "──────────────────────────────────"

# Extract each server's command (first element of args is the binary for npx/uvx)
SERVERS=$(jq -r '.mcpServers | keys[]' "$MCP")
for srv in $SERVERS; do
  CMD=$(jq -r ".mcpServers[\"$srv\"].command" "$MCP")
  ARGS0=$(jq -r ".mcpServers[\"$srv\"].args[0] // empty" "$MCP")

  case "$CMD" in
    npx|uvx|pipx)
      # package manager — check the manager exists, and the package resolves
      if command -v "$CMD" &>/dev/null; then
        # For npx/uvx, the first arg is the package; we can't verify it without
        # actually running it (would trigger a download). Just verify the manager.
        echo -e "${GREEN}✓${NC} $srv: $CMD ${ARGS0:+$ARGS0 ...} (manager present)"
      else
        echo -e "${RED}✗${NC} $srv: '$CMD' not on PATH"
        FAIL=1
      fi
      ;;
    *)
      # direct binary (helix, mem0, graphify, etc.)
      if command -v "$CMD" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $srv: $CMD (present)"
      else
        echo -e "${RED}✗${NC} $srv: '$CMD' not on PATH — install it or remove from .mcp.json"
        FAIL=1
      fi
      ;;
  esac
done

echo "──────────────────────────────────"
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}✓${NC} All MCP server commands valid"
  exit 0
else
  echo -e "${RED}✗${NC} One or more MCP servers broken — fix above before starting your agent"
  echo ""
  echo "Common fixes:"
  echo "  uvx missing (git server):  curl -LsSf https://astral.sh/uv/install.sh | sh"
  echo "  npx missing (filesystem/fetch): install Node.js 18+ from https://nodejs.org"
  echo "  helix missing:             curl -sSL https://install.helix-db.com | bash"
  echo "  mem0 missing:              npm install -g @mem0/cli"
  echo "  graphify missing:           pip install graphifyy && graphify install"
  echo ""
  echo "After fixing, re-run: $0 $MCP"
  exit 1
fi