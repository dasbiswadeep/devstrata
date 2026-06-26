#!/usr/bin/env bash
# test_clone_url_not_placeholder.sh — verify the README + PROFILE.md use a real
# clone URL, not the YOUR_USERNAME placeholder that breaks for new users.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# 1. README must NOT have the YOUR_USERNAME placeholder in the clone command
if grep -q 'git clone.*YOUR_USERNAME' "$REPO/README.md"; then
  echo "FAIL: README still has YOUR_USERNAME placeholder in clone command"
  FAIL=1
else
  echo "PASS: README clone command has a real URL (no YOUR_USERNAME placeholder)"
fi

# 2. lite PROFILE.md must NOT have the placeholder
if grep -q 'git clone.*YOUR_USERNAME' "$REPO/profiles/lite/PROFILE.md"; then
  echo "FAIL: lite PROFILE.md still has YOUR_USERNAME placeholder"
  FAIL=1
else
  echo "PASS: lite PROFILE.md clone command has a real URL"
fi

# 3. the clone URL must point to a github.com URL (not a broken path)
if grep -q 'git clone https://github.com/.*/devstrata.git' "$REPO/README.md"; then
  echo "PASS: README clone URL is a valid github.com URL"
else
  echo "FAIL: README clone URL is not a valid github.com path"
  FAIL=1
fi

# 4. the clone URL must mention it's replaceable if forked
if grep -qi 'replace.*fork\|fork.*replace' "$REPO/README.md"; then
  echo "PASS: README notes the URL should be replaced if forked"
else
  echo "FAIL: README doesn't tell users to replace URL if they forked"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1