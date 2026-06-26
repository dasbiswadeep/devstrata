#!/usr/bin/env bash
# test_known_issues_consistency.sh — verify KNOWN_ISSUES.md is internally
# consistent: every KI-### and WF-### ID is unique, and resolved issues
# actually describe their resolution (not just "fixed" with no evidence).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
KI="$REPO/docs/KNOWN_ISSUES.md"
FAIL=0

# 1. Extract all KI-### IDs and verify uniqueness
IDS=$(grep -oE 'KI-[0-9]{3}' "$KI" | sort)
DUPLICATES=$(echo "$IDS" | uniq -d)
if [ -z "$DUPLICATES" ]; then
  echo "PASS: all KI-### IDs are unique"
else
  echo "FAIL: duplicate KI IDs: $DUPLICATES"
  FAIL=1
fi

# 2. Same for WF-### (Won't Fix)
WF_IDS=$(grep -oE 'WF-[0-9]{3}' "$KI" | sort)
WF_DUP=$(echo "$WF_IDS" | uniq -d)
if [ -z "$WF_DUP" ]; then
  echo "PASS: all WF-### IDs are unique"
else
  echo "FAIL: duplicate WF IDs: $WF_DUP"
  FAIL=1
fi

# 3. KI-003 (process supervision) must mention docker-compose.yml (the fix)
if grep -A20 "KI-003" "$KI" | grep -q "docker-compose.yml"; then
  echo "PASS: KI-003 references docker-compose.yml (the fix)"
else
  echo "FAIL: KI-003 does not reference docker-compose.yml"
  FAIL=1
fi

# 4. KI-003 must mention launchd or systemd (HelixDB fix)
if grep -A30 "KI-003" "$KI" | grep -qE "launchd|systemd"; then
  echo "PASS: KI-003 references launchd/systemd (HelixDB fix)"
else
  echo "FAIL: KI-003 does not reference launchd/systemd"
  FAIL=1
fi

# 5. KI-001 must reference update.sh (the drift checker mitigation)
if grep -A30 "KI-001" "$KI" | grep -q "update.sh"; then
  echo "PASS: KI-001 references update.sh (drift mitigation)"
else
  echo "FAIL: KI-001 does not reference update.sh"
  FAIL=1
fi

# 6. There must be a "Won't Fix" section
if grep -q "Won't Fix" "$KI"; then
  echo "PASS: KNOWN_ISSUES.md has a Won't Fix section"
else
  echo "FAIL: KNOWN_ISSUES.md missing Won't Fix section"
  FAIL=1
fi

# 7. Severity must be stated for each KI
SEVERITY_COUNT=$(grep -cE "Severity:" "$KI")
ISSUE_COUNT=$(grep -cE "^(### KI-|### WF-)" "$KI")
if [ "$SEVERITY_COUNT" -ge "$ISSUE_COUNT" ]; then
  echo "PASS: $SEVERITY_COUNT severity labels for $ISSUE_COUNT issues"
else
  echo "FAIL: only $SEVERITY_COUNT severity labels for $ISSUE_COUNT issues"
  FAIL=1
fi

# 8. Status must be stated for each KI
STATUS_COUNT=$(grep -cE "Status:" "$KI")
if [ "$STATUS_COUNT" -ge "$ISSUE_COUNT" ]; then
  echo "PASS: $STATUS_COUNT status labels for $ISSUE_COUNT issues"
else
  echo "FAIL: only $STATUS_COUNT status labels for $ISSUE_COUNT issues"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1