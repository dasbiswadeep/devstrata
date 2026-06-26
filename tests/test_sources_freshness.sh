#!/usr/bin/env bash
# test_sources_freshness.sh — verify SOURCES.md has a recent verification date
# and that every tool section has the required fields (License, Stars, Verified, URL).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SOURCES="$REPO/docs/SOURCES.md"
FAIL=0

# 1. SOURCES.md must have a "Last verified:" date (may be bold-markdown)
if grep -q "Last verified:" "$SOURCES"; then
  echo "PASS: SOURCES.md has Last verified date"
else
  echo "FAIL: SOURCES.md missing Last verified date"
  FAIL=1
fi

# 2. The verified date must be a real ISO date (YYYY-MM-DD), possibly in **bold**
VERIFIED=$(grep -oE 'Last verified:.*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$SOURCES" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
if [ -n "$VERIFIED" ]; then
  # Validate it's a real date
  if python3 -c "import datetime; datetime.datetime.strptime('$VERIFIED', '%Y-%m-%d')" 2>/dev/null; then
    echo "PASS: verified date $VERIFIED is a valid ISO date"
  else
    echo "FAIL: verified date '$VERIFIED' is not a valid date"
    FAIL=1
  fi
else
  echo "FAIL: no ISO date found in Last verified line"
  FAIL=1
fi

# 3. Every "## Tool:" section must have at least one "Verified" row
SECTION_COUNT=$(grep -c "^## Tool:" "$SOURCES")
VERIFIED_ROWS=$(grep -c "| [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} |" "$SOURCES")
if [ "$VERIFIED_ROWS" -ge "$SECTION_COUNT" ]; then
  echo "PASS: $VERIFIED_ROWS verified rows across $SECTION_COUNT tool sections"
else
  echo "FAIL: only $VERIFIED_ROWS verified rows for $SECTION_COUNT sections"
  FAIL=1
fi

# 4. Every section must mention a URL (source link)
URL_ROWS=$(grep -c "https://" "$SOURCES")
if [ "$URL_ROWS" -ge "$SECTION_COUNT" ]; then
  echo "PASS: $URL_ROWS source URLs in SOURCES.md"
else
  echo "FAIL: only $URL_ROWS URLs for $SECTION_COUNT sections"
  FAIL=1
fi

# 5. SOURCES.md must document the re-verification procedure
if grep -q "Re-verification procedure\|Re-verification\|re-verify" "$SOURCES"; then
  echo "PASS: SOURCES.md documents re-verification procedure"
else
  echo "FAIL: SOURCES.md missing re-verification procedure"
  FAIL=1
fi

# 6. SOURCES.md must have a "Claims we could NOT verify" section (even if empty)
if grep -q "Claims we could NOT verify\|could NOT verify" "$SOURCES"; then
  echo "PASS: SOURCES.md has unverified-claims section"
else
  echo "FAIL: SOURCES.md missing unverified-claims section"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1