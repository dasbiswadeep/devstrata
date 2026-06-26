#!/usr/bin/env bash
# test_install_sh_force_backup.sh — verify --force backs up existing files
# before clobbering them (prevents data loss on profile upgrade).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. --force backs up .mcp.json before overwriting
if grep -q 'Backed up existing .mcp.json\|.mcp.json.bak' "$INSTALL"; then
  echo "PASS: install.sh backs up .mcp.json on --force"
else
  echo "FAIL: install.sh doesn't back up .mcp.json on --force (data loss risk)"
  FAIL=1
fi

# 2. --force backs up AGENTS.md before overwriting
if grep -q 'Backed up existing AGENTS.md\|AGENTS.md.bak' "$INSTALL"; then
  echo "PASS: install.sh backs up AGENTS.md on --force"
else
  echo "FAIL: install.sh doesn't back up AGENTS.md on --force (data loss risk)"
  FAIL=1
fi

# 3. backup files use a timestamp suffix (.bak.<epoch>)
if grep -qE '\.bak\.\$\(date \+%s\)' "$INSTALL"; then
  echo "PASS: backup files are timestamped (.bak.<epoch>)"
else
  echo "FAIL: backup files not timestamped (would clobber previous backup)"
  FAIL=1
fi

# 4. user is informed when a backup is made
if grep -q 'edit was preserved\|your edits are preserved' "$INSTALL"; then
  echo "PASS: user is told their edits are preserved in backup"
else
  echo "FAIL: user not informed about backup (may think edits are lost)"
  FAIL=1
fi

# 5. docker-compose.yml is backed up on downgrade to lite
if grep -q 'docker-compose.yml.bak\|Removing docker-compose.yml' "$INSTALL"; then
  echo "PASS: docker-compose.yml handled on downgrade (backed up + removed)"
else
  echo "FAIL: docker-compose.yml orphaned on downgrade to lite"
  FAIL=1
fi

# 6. functional test: --force creates a .bak file
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p bakutest && cd bakutest
echo "# my custom project context" > AGENTS.md
bash ../scripts/install.sh --lite --yes --force >/dev/null 2>&1
if ls AGENTS.md.bak.* >/dev/null 2>&1; then
  echo "PASS: --force created AGENTS.md.bak.* (edit preserved)"
  # Verify backup contains the user's edit
  if grep -q "my custom project context" AGENTS.md.bak.* 2>/dev/null; then
    echo "PASS: backup contains the user's original edit"
  else
    echo "FAIL: backup doesn't contain the user's edit"
    FAIL=1
  fi
else
  echo "FAIL: --force didn't create a backup of AGENTS.md"
  FAIL=1
fi
cd / && rm -rf "$SB"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1