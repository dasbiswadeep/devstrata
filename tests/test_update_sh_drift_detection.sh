#!/usr/bin/env bash
# test_update_sh_drift_detection.sh — verify update.sh checks all 11 upstream
# tools and provides the correct upgrade command for each.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
UPDATE="$REPO/scripts/update.sh"
FAIL=0

# 1. update.sh must check each of these tools (by command name or install name)
for tool in "headroom" "graphify" "mem0" "helix" "hermes" "shannon"; do
  if grep -qi "$tool" "$UPDATE"; then
    echo "PASS: update.sh checks $tool"
  else
    echo "FAIL: update.sh does not check $tool"
    FAIL=1
  fi
done

# 2. update.sh must mention docker compose pull (for image updates)
if grep -q "docker compose pull\|docker compose.*pull" "$UPDATE"; then
  echo "PASS: update.sh mentions docker compose pull"
else
  echo "FAIL: update.sh does not mention docker compose pull"
  FAIL=1
fi

# 3. update.sh must NOT auto-upgrade (deliberate — see GUIDING_PRINCIPLES §1)
# It should say "report" or "check", not "upgrade" as an automatic action
if grep -qi "auto-upgrade\|automatically upgrade\|auto-install" "$UPDATE" && ! grep -qi "does NOT auto" "$UPDATE"; then
  echo "FAIL: update.sh appears to auto-upgrade (against design)"
  FAIL=1
else
  echo "PASS: update.sh reports drift without auto-upgrading"
fi

# 4. update.sh must reference doctor.sh (post-upgrade verification)
if grep -q "doctor.sh" "$UPDATE"; then
  echo "PASS: update.sh references doctor.sh for post-upgrade verification"
else
  echo "FAIL: update.sh does not reference doctor.sh"
  FAIL=1
fi

# 5. update.sh must print manual upgrade commands (so user can copy-paste)
if grep -q "pip install --upgrade\|pip install.*upgrade" "$UPDATE"; then
  echo "PASS: update.sh shows pip upgrade commands"
else
  echo "FAIL: update.sh missing pip upgrade commands"
  FAIL=1
fi

# 6. update.sh must check npm-based MCP servers
if grep -q "npm\|modelcontextprotocol" "$UPDATE"; then
  echo "PASS: update.sh checks npm MCP servers"
else
  echo "FAIL: update.sh does not check npm MCP servers"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1