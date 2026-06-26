#!/usr/bin/env bash
# test_morning_startup_idempotency.sh — verify morning-startup.sh is safe to
# run multiple times: it checks if a service is already running before starting.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
MS="$REPO/scripts/morning-startup.sh"
FAIL=0

# 1. For each service, morning-startup must check "already running" before starting
# Use grep -E so the alternation works.
check_service() {
  local service_name="$1"
  local already_running_marker="$2"
  if grep -qE "$already_running_marker" "$MS"; then
    echo "PASS: morning-startup checks $service_name before starting"
  else
    echo "FAIL: morning-startup may double-start $service_name (no '$already_running_marker' check)"
    FAIL=1
  fi
}

check_service "Headroom" "Headroom already running"
check_service "HelixDB" "HelixDB already running"
check_service "Mem0"    "Mem0 already running"
check_service "Ollama"  "Ollama already running"

# 2. morning-startup must use curl health check, not just pgrep (more reliable)
if grep -q "curl.*localhost.*health\|curl.*localhost.*/api" "$MS"; then
  echo "PASS: morning-startup uses HTTP health checks"
else
  echo "FAIL: morning-startup does not use HTTP health checks"
  FAIL=1
fi

# 3. morning-startup must check Graphify graph freshness
if grep -q "DAYS_OLD\|graph.json" "$MS"; then
  echo "PASS: morning-startup checks Graphify graph freshness"
else
  echo "FAIL: morning-startup does not check Graphify graph freshness"
  FAIL=1
fi

# 4. morning-startup must not crash if a service is missing (graceful degradation)
# It should use `warn` or `fail` but continue, not `set -e` + exit
if grep -q "set -u" "$MS" && ! grep -q "set -e" "$MS"; then
  echo "PASS: morning-startup uses set -u (no -e) — degrades gracefully"
else
  echo "FAIL: morning-startup uses set -e (crashes on first error) or missing set -u"
  FAIL=1
fi

# 5. morning-startup must reference doctor.sh at the end
if grep -q "doctor.sh" "$MS"; then
  echo "PASS: morning-startup points to doctor.sh"
else
  echo "FAIL: morning-startup does not point to doctor.sh"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1