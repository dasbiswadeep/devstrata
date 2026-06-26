#!/usr/bin/env bash
# test_scripts_absolute_paths_in_footer.sh — verify doctor.sh + morning-startup.sh
# use absolute paths (not ./scripts/) in their footer messages, so they work
# when run from a user's project directory (not the devstrata repo root).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# 1. doctor.sh must resolve DEVSTRATA_DIR + use absolute paths in footer
DOCTOR="$REPO/scripts/doctor.sh"
if grep -q 'DEVSTRATA_DIR' "$DOCTOR"; then
  echo "PASS: doctor.sh resolves DEVSTRATA_DIR for absolute paths"
else
  echo "FAIL: doctor.sh doesn't compute DEVSTRATA_DIR"
  FAIL=1
fi

# 2. doctor.sh footer must NOT use relative ./scripts/ paths
if grep -E "echo.*'\./scripts/" "$DOCTOR" | grep -v 'BASH_SOURCE\|dirname'; then
  echo "FAIL: doctor.sh still uses relative ./scripts/ in footer"
  FAIL=1
else
  echo "PASS: doctor.sh footer uses absolute paths"
fi

# 3. morning-startup.sh footer must use absolute path to doctor.sh
MS="$REPO/scripts/morning-startup.sh"
if grep -q 'BASH_SOURCE.*doctor.sh\|DEVSTRATA_DIR.*doctor.sh\|$(cd.*scripts/doctor.sh' "$MS"; then
  echo "PASS: morning-startup.sh footer uses absolute path to doctor.sh"
else
  echo "FAIL: morning-startup.sh footer uses relative ./scripts/doctor.sh"
  FAIL=1
fi

# 4. functional test: run doctor.sh from a non-repo dir, verify footer shows absolute path
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p footertest && cd footertest
OUTPUT=$(bash ../scripts/doctor.sh 2>&1 | tail -5)
if echo "$OUTPUT" | grep -q "/devstrata/scripts/"; then
  echo "PASS: doctor.sh footer shows absolute path when run from project dir"
else
  echo "FAIL: doctor.sh footer doesn't show absolute path"
  echo "$OUTPUT" | sed 's/^/    /'
  FAIL=1
fi
cd / && rm -rf "$SB"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1