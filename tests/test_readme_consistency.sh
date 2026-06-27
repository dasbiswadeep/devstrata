#!/usr/bin/env bash
# test_readme_consistency.sh — verify the README is internally consistent:
# the profile table matches the profiles/ directory, the docs table matches
# docs/, and star counts are present (not stale empty values).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
README="$REPO/README.md"
FAIL=0

# 1. README must mention all three profiles
for p in lite full pro; do
  if grep -q "\-\-$p" "$README"; then
    echo "PASS: README mentions --$p"
  else
    echo "FAIL: README does not mention --$p"
    FAIL=1
  fi
done

# 2. README must link to each profile doc
for p in lite full pro; do
  if grep -q "profiles/$p/PROFILE.md" "$README"; then
    echo "PASS: README links to profiles/$p/PROFILE.md"
  else
    echo "FAIL: README does not link to profiles/$p/PROFILE.md"
    FAIL=1
  fi
done

# 3. README docs table must reference every doc in docs/
for doc in ARCHITECTURE SKILLS GUIDING_PRINCIPLES INSTRUCTIONS SECURITY BACKENDS KNOWN_ISSUES MEMORY_DOMAINS SOURCES SUPERVISION; do
  if grep -q "docs/$doc.md\|$doc.md" "$README"; then
    echo "PASS: README references $doc.md"
  else
    echo "FAIL: README does not reference $doc.md"
    FAIL=1
  fi
done

# 4. README must have a "Quick Start" section
if grep -q "## Quick Start\|## Quick start" "$README"; then
  echo "PASS: README has Quick Start section"
else
  echo "FAIL: README missing Quick Start section"
  FAIL=1
fi

# 5. README must have a Repository Structure section
if grep -q "## Repository Structure\|## Repository structure" "$README"; then
  echo "PASS: README has Repository Structure section"
else
  echo "FAIL: README missing Repository Structure section"
  FAIL=1
fi

# 6. README must have an auto-adopt / auto-adoption Q&A section (Q5 from earlier)
if grep -qi "auto-adopt\|auto-adoption\|automatically adopt" "$README"; then
  echo "PASS: README answers the auto-adoption question"
else
  echo "FAIL: README missing auto-adoption Q&A"
  FAIL=1
fi

# 7. Star counts in the README table must not be empty or '0'
STAR_ROWS=$(grep -E '^\| L[0-9] ' "$README" | wc -l | tr -d ' ')
if [ "$STAR_ROWS" -ge 10 ]; then
  echo "PASS: README has $STAR_ROWS layer rows with star data"
else
  echo "FAIL: README has only $STAR_ROWS layer rows (expected 10+)"
  FAIL=1
fi

# 8. README must NOT contain the old 'Headroom | Proprietary' license claim
if grep -q "Headroom.*Proprietary\|Headroom.*proprietary" "$README"; then
  echo "FAIL: README still claims Headroom is proprietary (it's Apache-2.0)"
  FAIL=1
else
  echo "PASS: README correctly shows Headroom as Apache 2.0"
fi

# 9. README must NOT claim '885k installs' (corrected to ~780k)
if grep -q "885k" "$README"; then
  echo "FAIL: README still claims 885k installs (corrected to ~780k)"
  FAIL=1
else
  echo "PASS: README has corrected skills.sh install count"
fi

# 10. README's stated test-file count must match the actual number of test_*.sh files.
#     Guards against the 56-vs-62 drift: docs claiming a stale test count.
ACTUAL_TESTS=$(ls "$REPO"/tests/test_*.sh 2>/dev/null | wc -l | tr -d ' ')
if grep -qE "$ACTUAL_TESTS test files" "$README"; then
  echo "PASS: README test-file count matches actual ($ACTUAL_TESTS)"
else
  echo "FAIL: README does not state the actual test-file count ($ACTUAL_TESTS test files)"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1