#!/usr/bin/env bash
# test_claude_md_no_changelog_refs.sh — verify CLAUDE.md no longer references
# CHANGELOG.md (which doesn't exist in the repo). Round 9 found 2 stale refs.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE="$REPO/CLAUDE.md"
FAIL=0

# 1. CLAUDE.md must NOT reference CHANGELOG.md (file doesn't exist)
if grep -q 'CHANGELOG' "$CLAUDE"; then
  echo "FAIL: CLAUDE.md still references CHANGELOG.md (file doesn't exist in repo)"
  grep -n 'CHANGELOG' "$CLAUDE" | sed 's/^/    /'
  FAIL=1
else
  echo "PASS: CLAUDE.md no longer references non-existent CHANGELOG.md"
fi

# 2. CLAUDE.md must reference SOURCES.md (the real file for version tracking)
if grep -q 'SOURCES.md' "$CLAUDE"; then
  echo "PASS: CLAUDE.md references SOURCES.md (the real version-tracking doc)"
else
  echo "FAIL: CLAUDE.md doesn't reference SOURCES.md"
  FAIL=1
fi

# 3. CLAUDE.md must mention test.sh in the testing section
if grep -q 'test.sh' "$CLAUDE"; then
  echo "PASS: CLAUDE.md mentions test.sh"
else
  echo "FAIL: CLAUDE.md missing test.sh reference"
  FAIL=1
fi

# 4. The testing section must include both test.sh AND doctor.sh
if grep -A5 'Testing changes' "$CLAUDE" | grep -q 'test.sh' && grep -A5 'Testing changes' "$CLAUDE" | grep -q 'doctor.sh'; then
  echo "PASS: CLAUDE.md testing section includes both test.sh + doctor.sh"
else
  echo "FAIL: CLAUDE.md testing section incomplete"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1