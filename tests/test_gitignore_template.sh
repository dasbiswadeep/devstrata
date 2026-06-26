#!/usr/bin/env bash
# test_gitignore_template.sh — verify the .gitignore template + repo .gitignore
# protect secrets, backups, and artifacts from being committed.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# 1. repo has a top-level .gitignore
if [ -f "$REPO/.gitignore" ]; then
  echo "PASS: repo has a top-level .gitignore"
else
  echo "FAIL: repo missing top-level .gitignore"
  FAIL=1
fi

# 2. configs/.gitignore.template exists (for copying to user projects)
if [ -f "$REPO/configs/.gitignore.template" ]; then
  echo "PASS: configs/.gitignore.template exists"
else
  echo "FAIL: configs/.gitignore.template missing"
  FAIL=1
fi

# 3. .gitignore must protect headroom.env (the secrets file)
if grep -q 'headroom.env' "$REPO/.gitignore" && grep -q 'headroom.env' "$REPO/configs/.gitignore.template"; then
  echo "PASS: .gitignore protects headroom.env (secrets)"
else
  echo "FAIL: .gitignore doesn't protect headroom.env"
  FAIL=1
fi

# 4. .gitignore must protect *.env and .env.*
if grep -q '\.env' "$REPO/configs/.gitignore.template"; then
  echo "PASS: .gitignore protects .env files"
else
  echo "FAIL: .gitignore doesn't protect .env files"
  FAIL=1
fi

# 5. .gitignore must protect *.bak.* (install.sh --force backups)
if grep -q '\.bak\.' "$REPO/configs/.gitignore.template"; then
  echo "PASS: .gitignore protects .bak.* backups"
else
  echo "FAIL: .gitignore doesn't protect backup files"
  FAIL=1
fi

# 6. .gitignore must protect graphify-out/ (regenerable, large)
if grep -q 'graphify-out' "$REPO/configs/.gitignore.template"; then
  echo "PASS: .gitignore protects graphify-out/"
else
  echo "FAIL: .gitignore doesn't protect graphify-out/"
  FAIL=1
fi

# 7. .gitignore must protect .shannon/ (scan reports may contain vuln details)
if grep -q '.shannon' "$REPO/configs/.gitignore.template"; then
  echo "PASS: .gitignore protects .shannon/ (vuln reports)"
else
  echo "FAIL: .gitignore doesn't protect .shannon/"
  FAIL=1
fi

# 8. .gitignore must protect .pem / .key (private keys)
if grep -q '\.pem\|\.key' "$REPO/configs/.gitignore.template"; then
  echo "PASS: .gitignore protects private keys"
else
  echo "FAIL: .gitignore doesn't protect private keys"
  FAIL=1
fi

# 9. install.sh copies .gitignore.template to user projects
if grep -q '.gitignore.template' "$REPO/scripts/install.sh"; then
  echo "PASS: install.sh copies .gitignore to user projects"
else
  echo "FAIL: install.sh doesn't copy .gitignore"
  FAIL=1
fi

# 10. functional test: install.sh creates .gitignore in a fresh project
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p gittest && cd gittest
bash ../scripts/install.sh --lite --yes >/dev/null 2>&1
if [ -f ".gitignore" ]; then
  echo "PASS: install.sh created .gitignore in user project"
  # Verify it protects the right things
  if grep -q 'headroom.env' .gitignore; then
    echo "PASS: project .gitignore protects headroom.env"
  else
    echo "FAIL: project .gitignore missing headroom.env protection"
    FAIL=1
  fi
else
  echo "FAIL: install.sh didn't create .gitignore"
  FAIL=1
fi
cd / && rm -rf "$SB"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1