#!/usr/bin/env bash
# test_doc_links.sh — every docs/X.md link in README resolves to a real file.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# Extract [text](docs/XX.md) and [text](configs/YY) style links from README
LINKS=$(grep -oE '\]\(([a-zA-Z0-9_./-]+\.(md|yml|json|template|plist|service))' "$REPO/README.md" \
        | sed -E 's/^\]\(//' )

if [ -z "$LINKS" ]; then
  echo "PASS: no relative doc links found in README (nothing to check)"
  exit 0
fi

echo "$LINKS" | sort -u | while IFS= read -r link; do
  if [ -e "$REPO/$link" ]; then
    echo "PASS: link resolves $link"
  else
    echo "FAIL: broken link $link"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1