#!/usr/bin/env bash
# test_validate_mcp.sh — verify validate-mcp.sh catches broken MCP servers.
# Uses a temp .mcp.json with a fake command to test the failure path.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
VM="$REPO/scripts/validate-mcp.sh"
FAIL=0

[ -x "$VM" ] && echo "PASS: validate-mcp.sh is executable" || { echo "FAIL: not executable"; FAIL=1; }
bash -n "$VM" 2>/dev/null && echo "PASS: syntax OK" || { echo "FAIL: syntax"; FAIL=1; }

# 1. requires jq (or warns)
if grep -q "command -v jq\|jq not installed" "$VM"; then
  echo "PASS: validate-mcp.sh checks for jq"
else
  echo "FAIL: validate-mcp.sh doesn't check for jq"
  FAIL=1
fi

# 2. handles missing file arg
if grep -q 'not found\|usage' "$VM"; then
  echo "PASS: validate-mcp.sh handles missing file"
else
  echo "FAIL: validate-mcp.sh missing file handling"
  FAIL=1
fi

# 3. distinguishes npx/uvx (package managers) from direct binaries
if grep -q 'npx\|uvx' "$VM" && grep -q 'package manager\|manager present' "$VM"; then
  echo "PASS: validate-mcp.sh handles package-manager commands"
else
  echo "FAIL: validate-mcp.sh doesn't handle npx/uvx"
  FAIL=1
fi

# 4. exit code: 0 = all valid, 1 = broken
if grep -q 'exit 0' "$VM" && grep -q 'exit 1' "$VM"; then
  echo "PASS: validate-mcp.sh has distinct exit codes"
else
  echo "FAIL: validate-mcp.sh missing exit codes"
  FAIL=1
fi

# 5. functional test: create a temp .mcp.json with a broken command, verify it fails
TMP=$(mktemp -d)
cat > "$TMP/broken-mcp.json" <<'EOF'
{
  "mcpServers": {
    "good-server": { "command": "npx", "args": ["-y", "fake-pkg"] },
    "bad-server":  { "command": "this-command-does-not-exist-anywhere-xyz123", "args": [] }
  }
}
EOF

# Run validate-mcp against the broken file — should exit 1
if bash "$VM" "$TMP/broken-mcp.json" >/dev/null 2>&1; then
  echo "FAIL: validate-mcp.sh passed a broken .mcp.json (should have failed)"
  FAIL=1
else
  echo "PASS: validate-mcp.sh correctly rejected broken .mcp.json"
fi

# 6. functional test: a file with all-real commands should pass (use npx which exists)
cat > "$TMP/good-mcp.json" <<'EOF'
{
  "mcpServers": {
    "ok-server": { "command": "npx", "args": ["-y", "some-pkg"] }
  }
}
EOF
if bash "$VM" "$TMP/good-mcp.json" >/dev/null 2>&1; then
  echo "PASS: validate-mcp.sh accepted a valid .mcp.json"
else
  echo "FAIL: validate-mcp.sh rejected a valid .mcp.json (false positive)"
  FAIL=1
fi

rm -rf "$TMP"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1