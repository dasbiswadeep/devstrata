#!/usr/bin/env bash
# test_known_issues_mitigations_exist.sh — verify every script/config cited as a
# mitigation in KNOWN_ISSUES.md actually exists in the repo. Round 9 verified
# this manually; now it's a permanent test.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
KI="$REPO/docs/KNOWN_ISSUES.md"
FAIL=0

# Each mitigation cited in KNOWN_ISSUES.md must point to a real file.
check_mitigation() {
  local issue="$1"
  local file="$2"
  if grep -q "$issue" "$KI" && grep -q "$file" "$KI"; then
    if [ -f "$REPO/$file" ] || [ -f "$REPO/scripts/$(basename $file)" ] || [ -f "$REPO/configs/$(basename $file)" ]; then
      echo "PASS: $issue mitigation '$file' exists"
    else
      # Check scripts/ and configs/ subdirs
      local found=""
      for d in scripts configs; do
        if [ -f "$REPO/$d/$(basename $file)" ]; then found="$d/$(basename $file)"; break; fi
      done
      if [ -n "$found" ]; then
        echo "PASS: $issue mitigation '$found' exists"
      else
        echo "FAIL: $issue cites '$file' as mitigation but file not found"
        FAIL=1
      fi
    fi
  fi
}

# KI-001 mitigations
check_mitigation "KI-001" "update.sh"
check_mitigation "KI-001" "version-check.sh"
check_mitigation "KI-001" "validate-mcp.sh"

# KI-002 mitigation
check_mitigation "KI-002" "sync-memory.sh"

# KI-003 mitigations (supervision)
check_mitigation "KI-003" "docker-compose.yml"
check_mitigation "KI-003" "com.helixdb.dev.plist"
check_mitigation "KI-003" "helixdb.service"
check_mitigation "KI-003" "com.devstrata.headroom.proxy.plist"
check_mitigation "KI-003" "headroom-proxy.service"
check_mitigation "KI-003" "headroom-watchdog.sh"

# KI-004 mitigation
check_mitigation "KI-004" "recommend-profile.sh"

# KI-006 mitigation
check_mitigation "KI-006" "agent-isolate.sh"

# KI-008 mitigation
check_mitigation "KI-008" "wsl2-check.sh"

# KI-010 mitigation
check_mitigation "KI-010" "headroom-watchdog.sh"

# WF-002 mitigation
check_mitigation "WF-002" "validate-mcp.sh"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1