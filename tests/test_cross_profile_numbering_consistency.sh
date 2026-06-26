#!/usr/bin/env bash
# test_cross_profile_numbering_consistency.sh — verify the tool numbering in
# PROFILE.md files matches the step numbering in INSTRUCTIONS.md install matrix.
# Round 7 found full PROFILE.md had Mem0=#8, HelixDB=#9 but INSTRUCTIONS matrix
# had HelixDB=step7, Mem0=step8 (swapped).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# The canonical numbering from INSTRUCTIONS.md install matrix:
#   7=HelixDB, 8=Mem0, 10=Shannon, 11=Hermes
# Verify PROFILE.md files use the same numbers.

# 1. full PROFILE.md: HelixDB must be #7 (matching INSTRUCTIONS step 7)
if grep -q '| 7 | HelixDB' "$REPO/profiles/full/PROFILE.md"; then
  echo "PASS: full PROFILE.md numbers HelixDB as #7 (matches INSTRUCTIONS step 7)"
else
  echo "FAIL: full PROFILE.md doesn't number HelixDB as #7"
  FAIL=1
fi

# 2. full PROFILE.md: Mem0 must be #8 (matching INSTRUCTIONS step 8)
if grep -q '| 8 | Mem0' "$REPO/profiles/full/PROFILE.md"; then
  echo "PASS: full PROFILE.md numbers Mem0 as #8 (matches INSTRUCTIONS step 8)"
else
  echo "FAIL: full PROFILE.md doesn't number Mem0 as #8"
  FAIL=1
fi

# 3. full PROFILE.md: Shannon must be #10 (matching INSTRUCTIONS step 10)
if grep -q '| 10 | Shannon' "$REPO/profiles/full/PROFILE.md"; then
  echo "PASS: full PROFILE.md numbers Shannon as #10 (matches INSTRUCTIONS step 10)"
else
  echo "FAIL: full PROFILE.md doesn't number Shannon as #10"
  FAIL=1
fi

# 4. pro PROFILE.md: Hermes must be #11 (matching INSTRUCTIONS step 11)
if grep -q '| 11 | Hermes' "$REPO/profiles/pro/PROFILE.md"; then
  echo "PASS: pro PROFILE.md numbers Hermes as #11 (matches INSTRUCTIONS step 11)"
else
  echo "FAIL: pro PROFILE.md doesn't number Hermes as #11"
  FAIL=1
fi

# 5. INSTRUCTIONS.md must have the matching step numbers
if grep -q '| 7 | HelixDB' "$REPO/docs/INSTRUCTIONS.md" && grep -q '| 8 | Mem0' "$REPO/docs/INSTRUCTIONS.md"; then
  echo "PASS: INSTRUCTIONS.md matrix has HelixDB=7, Mem0=8"
else
  echo "FAIL: INSTRUCTIONS.md matrix numbering inconsistent"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1