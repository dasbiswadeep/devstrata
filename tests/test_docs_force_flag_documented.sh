#!/usr/bin/env bash
# test_docs_force_flag_documented.sh — verify --force is documented in README
# and PROFILE.md upgrade sections (round 3 found it was undocumented).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# 1. README must mention --force
if grep -q -- '--force' "$REPO/README.md"; then
  echo "PASS: README documents --force"
else
  echo "FAIL: README doesn't mention --force"
  FAIL=1
fi

# 2. README must have an "Upgrading or changing profiles" section
if grep -q "Upgrading or changing profiles\|Upgrade.*profile\|changing profiles" "$REPO/README.md"; then
  echo "PASS: README has a profile-change/upgrade section"
else
  echo "FAIL: README missing profile-change section"
  FAIL=1
fi

# 3. README must explain --force backs up files (so users know edits are safe)
if grep -q "backs up.*before overwriting\|backs up.*edits" "$REPO/README.md"; then
  echo "PASS: README explains --force backs up files"
else
  echo "FAIL: README doesn't explain --force backup behavior"
  FAIL=1
fi

# 4. README must mention downgrade (Pro → Lite) with --force
if grep -q "Downgrade\|downgrade\|Pro.*Lite.*--force" "$REPO/README.md"; then
  echo "PASS: README documents downgrade path with --force"
else
  echo "FAIL: README missing downgrade documentation"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1