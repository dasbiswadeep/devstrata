#!/usr/bin/env bash
# test_doctor_sh_pre_install_state.sh — verify doctor.sh detects a pre-install
# state (nothing installed yet) and gives the right next-step (install, not morning-startup).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOCTOR="$REPO/scripts/doctor.sh"
FAIL=0

# 1. doctor.sh must have a pre-install detection block (counts NOT_INSTALLED)
if grep -q 'NOT_INSTALLED' "$DOCTOR"; then
  echo "PASS: doctor.sh has pre-install state detection"
else
  echo "FAIL: doctor.sh missing pre-install detection"
  FAIL=1
fi

# 2. in pre-install state, recommends install.sh (not morning-startup)
if grep -A5 'NOT_INSTALLED' "$DOCTOR" | grep -q 'install.sh'; then
  echo "PASS: pre-install state recommends install.sh"
else
  echo "FAIL: pre-install state doesn't recommend install.sh"
  FAIL=1
fi

# 3. in pre-install state, recommends recommend-profile.sh
if grep -A5 'NOT_INSTALLED' "$DOCTOR" | grep -q 'recommend-profile'; then
  echo "PASS: pre-install state recommends recommend-profile.sh"
else
  echo "FAIL: pre-install state doesn't recommend profile recommender"
  FAIL=1
fi

# 4. in installed state, points to version-check.sh (not just update.sh)
if grep -q 'version-check' "$DOCTOR"; then
  echo "PASS: doctor.sh points to version-check.sh"
else
  echo "FAIL: doctor.sh missing version-check.sh reference"
  FAIL=1
fi

# 5. .mcp.json fix message should mention install.sh (not "copy from template")
if grep -q 'install.sh' "$DOCTOR" && grep -q '.mcp.json not found' "$DOCTOR"; then
  # Check the .mcp.json warning line specifically mentions install.sh
  if grep '.mcp.json not found' "$DOCTOR" | grep -q 'install.sh'; then
    echo "PASS: .mcp.json warning points to install.sh"
  else
    echo "FAIL: .mcp.json warning doesn't mention install.sh"
    FAIL=1
  fi
else
  echo "FAIL: .mcp.json warning missing"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1