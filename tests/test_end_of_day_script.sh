#!/usr/bin/env bash
# test_end_of_day_script.sh — verify end-of-day.sh refreshes the graph,
# exports to Obsidian conditionally, and optionally stops Headroom.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
EOD="$REPO/scripts/end-of-day.sh"
FAIL=0

# 1. end-of-day must run graphify . --update (refresh graph)
if grep -q "graphify.*--update\|graphify.*update" "$EOD"; then
  echo "PASS: end-of-day refreshes Graphify graph"
else
  echo "FAIL: end-of-day does not refresh graph"
  FAIL=1
fi

# 2. end-of-day must export to Obsidian (conditional on GRAPHIFY_OBSIDIAN_PATH)
if grep -q "GRAPHIFY_OBSIDIAN_PATH\|obsidian" "$EOD"; then
  echo "PASS: end-of-day handles Obsidian export"
else
  echo "FAIL: end-of-day does not handle Obsidian export"
  FAIL=1
fi

# 3. end-of-day must optionally stop Headroom (--stop-proxy flag)
if grep -q "stop-proxy\|stop_proxy" "$EOD"; then
  echo "PASS: end-of-day supports --stop-proxy"
else
  echo "FAIL: end-of-day missing --stop-proxy option"
  FAIL=1
fi

# 4. end-of-day must use set -u (not set -e — degrade gracefully)
if grep -q "set -u" "$EOD" && ! grep -q "set -e" "$EOD"; then
  echo "PASS: end-of-day uses set -u (graceful)"
else
  echo "FAIL: end-of-day uses set -e (crashes) or missing set -u"
  FAIL=1
fi

# 5. end-of-day must remind user to capture decisions in Mem0
if grep -q "mem0 add\|mem0.*add\|Mem0\|decisions" "$EOD"; then
  echo "PASS: end-of-day reminds to capture decisions"
else
  echo "FAIL: end-of-day does not remind about Mem0 capture"
  FAIL=1
fi

# 6. end-of-day must not crash if graphify is not installed (best-effort)
# Look for: `if command -v graphify` guard around graphify commands
if grep -B1 "graphify" "$EOD" | grep -q "command -v graphify\|command -v.*graphify"; then
  echo "PASS: end-of-day guards graphify with command -v"
else
  echo "FAIL: end-of-day does not guard graphify (will crash if absent)"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1