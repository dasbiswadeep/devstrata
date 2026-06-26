#!/usr/bin/env bash
# test_validate_mcp_corrupted_json.sh — verify validate-mcp.sh rejects corrupted JSON.
# Mock-drill round 2 found it reported "all valid" on invalid JSON (FRUCTION R2-6).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
VM="$REPO/scripts/validate-mcp.sh"
FAIL=0

# 1. must validate JSON is parseable BEFORE iterating servers
if grep -q 'jq empty\|not valid JSON\|parseable' "$VM"; then
  echo "PASS: validate-mcp.sh checks JSON validity before iterating"
else
  echo "FAIL: validate-mcp.sh doesn't pre-validate JSON"
  FAIL=1
fi

# 2. must exit non-zero on corrupted JSON
TMP=$(mktemp -d)
echo '{not valid json' > "$TMP/broken.json"
if bash "$VM" "$TMP/broken.json" >/dev/null 2>&1; then
  echo "FAIL: validate-mcp.sh accepted corrupted JSON (should reject)"
  FAIL=1
else
  echo "PASS: validate-mcp.sh rejects corrupted JSON"
fi

# 3. must exit 0 on valid JSON with real commands
cat > "$TMP/valid.json" <<'EOF'
{ "mcpServers": { "ok": { "command": "npx", "args": ["-y", "x"] } } }
EOF
if bash "$VM" "$TMP/valid.json" >/dev/null 2>&1; then
  echo "PASS: validate-mcp.sh accepts valid JSON"
else
  echo "FAIL: validate-mcp.sh rejected valid JSON (false positive)"
  FAIL=1
fi

# 4. error message must mention "not valid JSON" (not "all valid")
OUTPUT=$(bash "$VM" "$TMP/broken.json" 2>&1)
if echo "$OUTPUT" | grep -qi "not valid JSON\|invalid JSON\|syntax"; then
  echo "PASS: error message says 'not valid JSON'"
else
  echo "FAIL: error message doesn't mention invalid JSON"
  echo "$OUTPUT" | head -3 | sed 's/^/    /'
  FAIL=1
fi

rm -rf "$TMP"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1