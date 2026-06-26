#!/usr/bin/env bash
# test_headroom_watchdog.sh — verify the watchdog restarts Headroom + Ollama correctly.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
WD="$REPO/scripts/headroom-watchdog.sh"
FAIL=0

[ -x "$WD" ] && echo "PASS: headroom-watchdog.sh is executable" || { echo "FAIL: not executable"; FAIL=1; }
bash -n "$WD" 2>/dev/null && echo "PASS: syntax OK" || { echo "FAIL: syntax"; FAIL=1; }

# 1. checks Ollama health (:11434)
if grep -q "11434" "$WD"; then
  echo "PASS: watchdog checks Ollama on :11434"
else
  echo "FAIL: watchdog missing Ollama check"
  FAIL=1
fi

# 2. checks Headroom health (:8787)
if grep -q "8787" "$WD"; then
  echo "PASS: watchdog checks Headroom on :8787"
else
  echo "FAIL: watchdog missing Headroom check"
  FAIL=1
fi

# 3. restarts Ollama if down (ollama serve)
if grep -q "ollama serve" "$WD"; then
  echo "PASS: watchdog restarts Ollama via 'ollama serve'"
else
  echo "FAIL: watchdog doesn't restart Ollama"
  FAIL=1
fi

# 4. restarts Headroom if down (or if Ollama was down — loses backend)
if grep -q "headroom proxy" "$WD" && grep -q "pkill\|restart" "$WD"; then
  echo "PASS: watchdog restarts Headroom (kills stale + starts fresh)"
else
  echo "FAIL: watchdog doesn't restart Headroom"
  FAIL=1
fi

# 5. logs to a file (for audit)
if grep -q "/tmp/devstrata-watchdog.log\|LOG=" "$WD"; then
  echo "PASS: watchdog logs to a file"
else
  echo "FAIL: watchdog missing logging"
  FAIL=1
fi

# 6. exits 0 when both healthy (nothing to do)
if grep -q "Both healthy\|nothing to do\|exit 0" "$WD"; then
  echo "PASS: watchdog exits 0 when both healthy"
else
  echo "FAIL: watchdog doesn't have a no-op path for healthy state"
  FAIL=1
fi

# 7. guards with command -v (graceful if tool missing)
if grep -q "command -v ollama\|command -v headroom" "$WD"; then
  echo "PASS: watchdog guards with command -v"
else
  echo "FAIL: watchdog doesn't guard against missing commands"
  FAIL=1
fi

# 8. uses set -u (graceful)
if grep -q "set -u" "$WD" && ! grep -q "^set -e" "$WD"; then
  echo "PASS: watchdog uses set -u"
else
  echo "FAIL: watchdog missing set -u or uses set -e"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1