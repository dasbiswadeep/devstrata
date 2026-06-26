#!/usr/bin/env bash
# test_headroom_supervision_templates.sh — verify the new Headroom + watchdog
# launchd/systemd templates are valid and have the right keys.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# ── Headroom proxy plist ────────────────────────────────────────────────────
HP_PLIST="$REPO/configs/com.devstrata.headroom.proxy.plist"

# 1. valid XML
if command -v plutil &>/dev/null; then
  plutil -lint "$HP_PLIST" >/dev/null 2>&1 && echo "PASS: headroom plist valid XML" || { echo "FAIL: headroom plist invalid"; FAIL=1; }
else
  python3 -c "import xml.etree.ElementTree as ET; ET.parse('$HP_PLIST')" 2>/dev/null && echo "PASS: headroom plist valid XML" || { echo "FAIL: headroom plist invalid"; FAIL=1; }
fi

# 2. KeepAlive
grep -q "<key>KeepAlive</key>" "$HP_PLIST" && grep -A1 "<key>KeepAlive</key>" "$HP_PLIST" | grep -q "<true/>" && echo "PASS: headroom plist KeepAlive=true" || { echo "FAIL: headroom plist missing KeepAlive"; FAIL=1; }

# 3. ExecStart = headroom proxy --port 8787
grep -qF "headroom" "$HP_PLIST" && grep -qF "proxy" "$HP_PLIST" && grep -qF "8787" "$HP_PLIST" && echo "PASS: headroom plist starts proxy on 8787" || { echo "FAIL: headroom plist wrong ExecStart"; FAIL=1; }

# ── Headroom proxy systemd ──────────────────────────────────────────────────
HP_SVC="$REPO/configs/headroom-proxy.service"
for section in "[Unit]" "[Service]" "[Install]"; do
  grep -qF "$section" "$HP_SVC" && echo "PASS: headroom service has $section" || { echo "FAIL: headroom service missing $section"; FAIL=1; }
done
grep -qF "headroom proxy" "$HP_SVC" && grep -qF "8787" "$HP_SVC" && echo "PASS: headroom service ExecStart correct" || { echo "FAIL: headroom service wrong ExecStart"; FAIL=1; }
grep -q "^Restart=always" "$HP_SVC" && echo "PASS: headroom service Restart=always" || { echo "FAIL: headroom service missing Restart=always"; FAIL=1; }

# ── Watchdog plist ──────────────────────────────────────────────────────────
WD_PLIST="$REPO/configs/com.devstrata.headroom-watchdog.plist"
if command -v plutil &>/dev/null; then
  plutil -lint "$WD_PLIST" >/dev/null 2>&1 && echo "PASS: watchdog plist valid XML" || { echo "FAIL: watchdog plist invalid"; FAIL=1; }
else
  python3 -c "import xml.etree.ElementTree as ET; ET.parse('$WD_PLIST')" 2>/dev/null && echo "PASS: watchdog plist valid XML" || { echo "FAIL: watchdog plist invalid"; FAIL=1; }
fi

# Watchdog must run periodically (StartInterval, not KeepAlive)
grep -q "<key>StartInterval</key>" "$WD_PLIST" && echo "PASS: watchdog plist has StartInterval (periodic)" || { echo "FAIL: watchdog plist missing StartInterval"; FAIL=1; }
grep -qF "headroom-watchdog.sh" "$WD_PLIST" && echo "PASS: watchdog plist calls headroom-watchdog.sh" || { echo "FAIL: watchdog plist doesn't call the script"; FAIL=1; }

# ── Watchdog systemd timer ──────────────────────────────────────────────────
WD_TIMER="$REPO/configs/headroom-watchdog.timer"
for section in "[Unit]" "[Service]" "[Timer]" "[Install]"; do
  grep -qF "$section" "$WD_TIMER" && echo "PASS: watchdog timer has $section" || { echo "FAIL: watchdog timer missing $section"; FAIL=1; }
done
grep -q "OnUnitActiveSec\|OnBootSec" "$WD_TIMER" && echo "PASS: watchdog timer has schedule" || { echo "FAIL: watchdog timer missing schedule"; FAIL=1; }
grep -qF "headroom-watchdog" "$WD_TIMER" && echo "PASS: watchdog timer references watchdog service" || { echo "FAIL: watchdog timer missing reference"; FAIL=1; }

[ "$FAIL" -eq 0 ] && exit 0 || exit 1