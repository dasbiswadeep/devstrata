#!/usr/bin/env bash
# test_further_reading_doc.sh — verify FURTHER_READING.md maps each devstrata
# layer to a build-your-own-x tutorial (principle #10: educational purpose first).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOC="$REPO/docs/FURTHER_READING.md"
FAIL=0

[ -f "$DOC" ] || { echo "FAIL: FURTHER_READING.md missing"; exit 1; }

# 1. must reference the source repo (codecrafters-io/build-your-own-x)
if grep -q "codecrafters-io/build-your-own-x" "$DOC"; then
  echo "PASS: FURTHER_READING.md cites codecrafters-io/build-your-own-x"
else
  echo "FAIL: FURTHER_READING.md doesn't cite the source repo"
  FAIL=1
fi

# 2. must reference principle #10 (educational purpose)
if grep -q "principle #10\|principle.*10\|educational purpose" "$DOC"; then
  echo "PASS: FURTHER_READING.md ties back to principle #10 (educational purpose)"
else
  echo "FAIL: FURTHER_READING.md doesn't reference principle #10"
  FAIL=1
fi

# 3. must cover all 7 layers (L0-L6)
for layer in "L0" "L1" "L2" "L3" "L4" "L5" "L6"; do
  if grep -q "### $layer —" "$DOC"; then
    echo "PASS: FURTHER_READING.md covers layer $layer"
  else
    echo "FAIL: FURTHER_READING.md missing layer $layer"
    FAIL=1
  fi
done

# 4. must link to at least one build-your-own-x tutorial per layer (github.com or external)
# Count the number of tutorial links (https:// links in the layer sections)
LINK_COUNT=$(grep -cE 'https://[^ )]+' "$DOC")
if [ "$LINK_COUNT" -ge 10 ]; then
  echo "PASS: FURTHER_READING.md has $LINK_COUNT tutorial links (≥10)"
else
  echo "FAIL: FURTHER_READING.md only has $LINK_COUNT links (expected ≥10)"
  FAIL=1
fi

# 5. must have a "graduation path" section (the principle #10 message)
if grep -qi "graduation path\|has succeeded\|scaffold you eventually climb past" "$DOC"; then
  echo "PASS: FURTHER_READING.md has a graduation-path section"
else
  echo "FAIL: FURTHER_READING.md missing graduation-path message"
  FAIL=1
fi

# 6. must have a verified date
if grep -q "Last verified:" "$DOC"; then
  echo "PASS: FURTHER_READING.md has a Last verified date"
else
  echo "FAIL: FURTHER_READING.md missing Last verified date"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1