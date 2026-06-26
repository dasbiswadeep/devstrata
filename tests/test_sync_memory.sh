#!/usr/bin/env bash
# test_sync_memory.sh — verify sync-memory.sh structure, arg handling, safety.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SM="$REPO/scripts/sync-memory.sh"
FAIL=0

# 1. exists + executable
[ -x "$SM" ] && echo "PASS: sync-memory.sh is executable" || { echo "FAIL: sync-memory.sh not executable"; FAIL=1; }

# 2. bash syntax
bash -n "$SM" 2>/dev/null && echo "PASS: sync-memory.sh syntax OK" || { echo "FAIL: sync-memory.sh syntax"; FAIL=1; }

# 3. requires --user-id (rejects no args)
if "$SM" 2>&1 | grep -q "Required: --user-id"; then
  echo "PASS: sync-memory.sh rejects missing --user-id"
else
  echo "FAIL: sync-memory.sh should reject missing --user-id"
  FAIL=1
fi

# 4. supports --all flag
grep -q -- "--all" "$SM" && echo "PASS: sync-memory.sh supports --all" || { echo "FAIL: missing --all"; FAIL=1; }

# 5. supports --since flag
grep -q -- "--since" "$SM" && echo "PASS: sync-memory.sh supports --since" || { echo "FAIL: missing --since"; FAIL=1; }

# 6. one-way export (does NOT claim to sync back to Mem0)
if grep -qi "do not edit here expecting sync back\|one-way export\|do NOT write back" "$SM"; then
  echo "PASS: sync-memory.sh documents one-way direction"
else
  echo "FAIL: sync-memory.sh doesn't clarify one-way direction"
  FAIL=1
fi

# 7. checks Mem0 is running before syncing
if grep -q "localhost:3000" "$SM" && grep -q "not running" "$SM"; then
  echo "PASS: sync-memory.sh checks Mem0 server is up"
else
  echo "FAIL: sync-memory.sh doesn't check Mem0 server"
  FAIL=1
fi

# 8. creates the export directory
if grep -q "mkdir -p" "$SM"; then
  echo "PASS: sync-memory.sh creates export dir"
else
  echo "FAIL: sync-memory.sh doesn't mkdir"
  FAIL=1
fi

# 9. uses set -u (graceful on unset vars)
if grep -q "set -u" "$SM" && ! grep -q "^set -e" "$SM"; then
  echo "PASS: sync-memory.sh uses set -u (no -e)"
else
  echo "FAIL: sync-memory.sh missing set -u or uses set -e"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1