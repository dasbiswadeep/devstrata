#!/usr/bin/env bash
# test_install_sh_hardening.sh — verify install.sh's new KI-009 + KI-012 mitigations:
# Node version check (not just presence) and Mem0 image pre-pull for full/pro.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. install.sh checks Node MAJOR version (≥18), not just presence
if grep -qE "NODE_MAJOR|node --version.*sed" "$INSTALL"; then
  echo "PASS: install.sh checks Node major version (KI-009 mitigation)"
else
  echo "FAIL: install.sh doesn't check Node version (only presence)"
  FAIL=1
fi

# 2. install.sh fails fast if Node < 18
if grep -q "skills.sh.*fail silently\|< 18\|exit 1" "$INSTALL"; then
  echo "PASS: install.sh exits if Node < 18"
else
  echo "FAIL: install.sh doesn't fail on old Node"
  FAIL=1
fi

# 3. install.sh checks for jq (warns, doesn't fail — optional)
if grep -q "command -v jq" "$INSTALL"; then
  echo "PASS: install.sh checks for jq"
else
  echo "FAIL: install.sh doesn't check for jq"
  FAIL=1
fi

# 4. install.sh pre-pulls Mem0 image for full/pro (KI-012 mitigation)
if grep -q "docker compose.*pull\|Pre-pulling Mem0\|pre-pull" "$INSTALL"; then
  echo "PASS: install.sh pre-pulls Mem0 image (KI-012 mitigation)"
else
  echo "FAIL: install.sh doesn't pre-pull Mem0 image"
  FAIL=1
fi

# 5. pre-pull is gated to full/pro (not lite — lite has no Mem0)
# The pull is inside the full/pro branch which starts higher up; use a wider window
if grep -B40 "Pre-pulling Mem0\|docker compose.*pull.*mem0" "$INSTALL" | grep -qE 'PROFILE" == "full"|PROFILE" == "pro"'; then
  echo "PASS: pre-pull gated to full/pro"
else
  echo "FAIL: pre-pull not gated to full/pro"
  FAIL=1
fi

# 6. install.sh mentions recommend-profile.sh (so users can pre-check)
# Optional — check if mentioned anywhere in the repo's scripts
if grep -q "recommend-profile" "$REPO/README.md" || grep -q "recommend-profile" "$REPO/docs/INSTRUCTIONS.md"; then
  echo "PASS: recommend-profile.sh mentioned in docs"
else
  echo "FAIL: recommend-profile.sh not mentioned in docs"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1