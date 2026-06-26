#!/usr/bin/env bash
# test_plist_systemd_validity.sh — verify the HelixDB launchd plist and
# systemd unit are structurally valid and have the required supervision keys.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="$REPO/configs/com.helixdb.dev.plist"
SERVICE="$REPO/configs/helixdb.service"
FAIL=0

# ── Plist (macOS launchd) ─────────────────────────────────────────────────

# 1. plist must be valid XML (plutil if available, else python xml)
if command -v plutil &>/dev/null; then
  if plutil -lint "$PLIST" >/dev/null 2>&1; then
    echo "PASS: plist is valid XML (plutil)"
  else
    echo "FAIL: plist is invalid XML"
    FAIL=1
  fi
else
  if python3 -c "import xml.etree.ElementTree as ET; ET.parse('$PLIST')" 2>/dev/null; then
    echo "PASS: plist is valid XML (python)"
  else
    echo "FAIL: plist is invalid XML"
    FAIL=1
  fi
fi

# 2. plist must have KeepAlive = true (restart on crash)
if grep -q "<key>KeepAlive</key>" "$PLIST" && grep -A1 "<key>KeepAlive</key>" "$PLIST" | grep -q "<true/>"; then
  echo "PASS: plist has KeepAlive = true"
else
  echo "FAIL: plist missing KeepAlive = true"
  FAIL=1
fi

# 3. plist must have RunAtLoad = true (start at login)
if grep -q "<key>RunAtLoad</key>" "$PLIST" && grep -A1 "<key>RunAtLoad</key>" "$PLIST" | grep -q "<true/>"; then
  echo "PASS: plist has RunAtLoad = true"
else
  echo "FAIL: plist missing RunAtLoad = true"
  FAIL=1
fi

# 4. plist ExecStart must call 'helix start dev --disk' (persistent, not in-memory)
# Use grep -F so --disk isn't treated as a grep option
if grep -qF "helix" "$PLIST" && grep -qF "start" "$PLIST" && grep -qF "dev" "$PLIST" && grep -qF -- "--disk" "$PLIST"; then
  echo "PASS: plist starts 'helix start dev --disk'"
else
  echo "FAIL: plist does not start 'helix start dev --disk'"
  FAIL=1
fi

# 5. plist must have a Label
if grep -q "<key>Label</key>" "$PLIST"; then
  echo "PASS: plist has a Label"
else
  echo "FAIL: plist missing Label"
  FAIL=1
fi

# ── systemd unit (Linux) ──────────────────────────────────────────────────

# 6. service file must have [Unit], [Service], [Install] sections
# Use grep -F (fixed string) so [Unit] isn't treated as a regex char class
for section in "[Unit]" "[Service]" "[Install]"; do
  if grep -qF "$section" "$SERVICE"; then
    echo "PASS: systemd unit has $section"
  else
    echo "FAIL: systemd unit missing $section"
    FAIL=1
  fi
done

# 7. ExecStart must call 'helix start dev --disk'
if grep -q "ExecStart=.*helix.*start.*dev.*--disk" "$SERVICE"; then
  echo "PASS: systemd ExecStart is 'helix start dev --disk'"
else
  echo "FAIL: systemd ExecStart is not 'helix start dev --disk'"
  FAIL=1
fi

# 8. Restart must be 'always'
if grep -q "^Restart=always" "$SERVICE"; then
  echo "PASS: systemd has Restart=always"
else
  echo "FAIL: systemd missing Restart=always"
  FAIL=1
fi

# 9. RestartSec must be set (delay before restart)
if grep -q "^RestartSec=" "$SERVICE"; then
  echo "PASS: systemd has RestartSec"
else
  echo "FAIL: systemd missing RestartSec"
  FAIL=1
fi

# 10. WantedBy must be multi-user.target
if grep -q "WantedBy=multi-user.target" "$SERVICE"; then
  echo "PASS: systemd WantedBy=multi-user.target"
else
  echo "FAIL: systemd missing WantedBy=multi-user.target"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1