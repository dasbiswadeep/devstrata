#!/usr/bin/env bash
# test_profile_docs_completeness.sh — each PROFILE.md must contain the
# required sections: install, prerequisites, RAM budget, troubleshooting, upgrade.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

for p in lite full pro; do
  PROFILE="$REPO/profiles/$p/PROFILE.md"
  [ -f "$PROFILE" ] || { echo "FAIL: $PROFILE missing"; FAIL=1; continue; }

  # Required sections (by heading keyword)
  for section in "What this profile" "RAM" "Prerequisites" "Install" "Troubleshooting" "Upgrade"; do
    if grep -q "$section" "$PROFILE"; then
      echo "PASS: $p profile has '$section' section"
    else
      echo "FAIL: $p profile missing '$section' section"
      FAIL=1
    fi
  done

  # Each profile must mention its RAM tier
  case "$p" in
    lite) grep -q "8GB" "$PROFILE" && echo "PASS: lite mentions 8GB" || { echo "FAIL: lite missing 8GB"; FAIL=1; } ;;
    full) grep -q "16GB" "$PROFILE" && echo "PASS: full mentions 16GB" || { echo "FAIL: full missing 16GB"; FAIL=1; } ;;
    pro)  grep -q "24GB" "$PROFILE" && echo "PASS: pro mentions 24GB" || { echo "FAIL: pro missing 24GB"; FAIL=1; } ;;
  esac

  # Each profile must reference ./scripts/install.sh
  if grep -q "install.sh" "$PROFILE"; then
    echo "PASS: $p profile references install.sh"
  else
    echo "FAIL: $p profile does not reference install.sh"
    FAIL=1
  fi

  # Each profile must list what it does NOT install (or what it adds)
  if grep -q "does NOT install\|adds over" "$PROFILE"; then
    echo "PASS: $p profile documents boundaries"
  else
    echo "FAIL: $p profile does not document what it adds/excludes"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1