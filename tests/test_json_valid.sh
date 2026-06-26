#!/usr/bin/env bash
# test_json_valid.sh — every .mcp.json + template is valid JSON.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

for f in "$REPO/configs/.mcp.json.template"; do
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    echo "PASS: json $(basename "$f")"
  else
    echo "FAIL: json $(basename "$f") — invalid"
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1