#!/usr/bin/env bash
# test_sync_memory_empty_export.sh — verify sync-memory.sh warns when the export
# is header-only (no real memories found for the user-id).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SM="$REPO/scripts/sync-memory.sh"
FAIL=0

# 1. must detect header-only exports (no real memory content)
if grep -q 'header-only\|HEADER_LINES\|no memories found' "$SM"; then
  echo "PASS: sync-memory.sh detects header-only exports"
else
  echo "FAIL: sync-memory.sh doesn't detect empty exports"
  FAIL=1
fi

# 2. must warn the user the user-id may be wrong
if grep -q 'right user-id\|Is this the right user-id\|check.*mem0 list' "$SM"; then
  echo "PASS: sync-memory.sh warns user-id may be wrong when empty"
else
  echo "FAIL: sync-memory.sh doesn't warn about wrong user-id"
  FAIL=1
fi

# 3. must NOT update the Obsidian index when export is empty (avoid noise)
if grep -q "Don't update the index\|rm -f.*OUTFILE\|don.t update.*index" "$SM"; then
  echo "PASS: sync-memory.sh skips index update on empty export"
else
  echo "FAIL: sync-memory.sh updates index even when empty (noise in Obsidian)"
  FAIL=1
fi

# 4. must NOT claim "Exported" success when there's nothing to export
if grep -q 'Exported to.*lines\|Index updated' "$SM"; then
  # The success messages exist, but they must be gated by the > HEADER_LINES check
  if grep -B2 'Exported to' "$SM" | grep -q 'gt\|HEADER_LINES'; then
    echo "PASS: 'Exported' success message is gated by real-content check"
  else
    echo "FAIL: 'Exported' message may fire on empty export (false success)"
    FAIL=1
  fi
else
  echo "FAIL: sync-memory.sh has no success message at all"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1