#!/usr/bin/env bash
# test_install_sh_refs.sh — every $SCRIPT_DIR/... path referenced in install.sh
# points to a file that actually exists in the repo.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# Extract $SCRIPT_DIR/<path> references from install.sh
REFS=$(grep -oE '\$SCRIPT_DIR/[a-zA-Z0-9_./-]+' "$REPO/scripts/install.sh" | sort -u)

if [ -z "$REFS" ]; then
  echo "PASS: no \$SCRIPT_DIR refs in install.sh"
  exit 0
fi

echo "$REFS" | while IFS= read -r ref; do
  # Strip the $SCRIPT_DIR/ prefix
  path="${ref#\$SCRIPT_DIR/}"
  if [ -e "$REPO/$path" ]; then
    echo "PASS: install.sh ref resolves $path"
  else
    echo "FAIL: install.sh references missing file $path"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1