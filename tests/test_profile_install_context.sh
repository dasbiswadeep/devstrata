#!/usr/bin/env bash
# test_profile_install_context.sh — verify each PROFILE.md "Install (one command)"
# section includes the clone + cd context (so a new user doesn't run ./scripts/install.sh
# from the wrong directory and get "No such file").
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

for p in lite full pro; do
  PROFILE="$REPO/profiles/$p/PROFILE.md"
  [ -f "$PROFILE" ] || { echo "FAIL: $PROFILE missing"; FAIL=1; continue; }

  # Extract the "Install (one command)" code block
  BLOCK=$(sed -n '/## Install (one command)/,/^```$/p' "$PROFILE" | head -20)

  # 1. must include git clone
  if echo "$BLOCK" | grep -q 'git clone'; then
    echo "PASS: $p PROFILE.md install block has git clone"
  else
    echo "FAIL: $p PROFILE.md install block missing git clone (user won't know to clone first)"
    FAIL=1
  fi

  # 2. must include cd devstrata
  if echo "$BLOCK" | grep -q 'cd devstrata'; then
    echo "PASS: $p PROFILE.md install block has 'cd devstrata'"
  else
    echo "FAIL: $p PROFILE.md install block missing 'cd devstrata'"
    FAIL=1
  fi

  # 3. must include the install command for this profile
  if echo "$BLOCK" | grep -q "install.sh --$p"; then
    echo "PASS: $p PROFILE.md install block runs install.sh --$p"
  else
    echo "FAIL: $p PROFILE.md install block missing install.sh --$p"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1