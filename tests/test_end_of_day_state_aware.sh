#!/usr/bin/env bash
# test_end_of_day_state_aware.sh — verify end-of-day.sh checks Mem0/HelixDB
# state instead of statically claiming they're running.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
EOD="$REPO/scripts/end-of-day.sh"
FAIL=0

# 1. end-of-day must curl Mem0 health endpoint
if grep -q 'localhost:3000/health\|MEM0_UP' "$EOD"; then
  echo "PASS: end-of-day checks Mem0 health endpoint"
else
  echo "FAIL: end-of-day doesn't check Mem0 state"
  FAIL=1
fi

# 2. end-of-day must curl HelixDB health endpoint
if grep -q 'localhost:6969/health\|HELIX_UP' "$EOD"; then
  echo "PASS: end-of-day checks HelixDB health endpoint"
else
  echo "FAIL: end-of-day doesn't check HelixDB state"
  FAIL=1
fi

# 3. must NOT have the static "Mem0 + HelixDB left running" message anymore
# (the Headroom "left running" message is fine — it's about Headroom, not Mem0/Helix)
if grep -q 'Mem0 + HelixDB left running\|Mem0.*HelixDB.*managed by docker compose' "$EOD"; then
  echo "FAIL: end-of-day still has static 'Mem0 + HelixDB left running' message"
  FAIL=1
else
  echo "PASS: end-of-day no longer statically claims Mem0/HelixDB are running"
fi

# 4. must give a start command when Mem0 is down
if grep -q 'docker compose up -d\|start with' "$EOD"; then
  echo "PASS: end-of-day gives a start command when services are down"
else
  echo "FAIL: end-of-day doesn't tell user how to start down services"
  FAIL=1
fi

# 5. must acknowledge --lite (not installed)
if grep -q 'not installed in --lite\|not installed in lite' "$EOD"; then
  echo "PASS: end-of-day acknowledges services may not be installed (lite)"
else
  echo "FAIL: end-of-day doesn't mention lite (implies services always exist)"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1