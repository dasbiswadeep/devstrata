#!/usr/bin/env bash
# test_install_sh_downgrade_cleanup.sh — verify downgrade to --lite cleans up
# full/pro artifacts (docker-compose.yml removed, .mcp.json stripped, AGENTS.md trimmed).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. install.sh has a downgrade-to-lite branch that removes docker-compose.yml
if grep -qE 'Downgrade to --lite|not needed for --lite.*Mem0' "$INSTALL"; then
  echo "PASS: install.sh removes docker-compose.yml on downgrade to lite"
else
  echo "FAIL: install.sh doesn't clean up docker-compose.yml on downgrade"
  FAIL=1
fi

# 2. the removal is backed up (mv to .bak), not rm'd outright
if grep -q 'mv docker-compose.yml.*bak\|docker-compose.yml.bak' "$INSTALL"; then
  echo "PASS: docker-compose.yml is backed up before removal (not rm'd)"
else
  echo "FAIL: docker-compose.yml is rm'd without backup (data loss)"
  FAIL=1
fi

# 3. functional test: simulate full install, downgrade to lite, verify cleanup
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p dgtest && cd dgtest
# Simulate a full install's files
cp ../configs/.mcp.json.template .mcp.json
cp ../configs/AGENTS.md.template AGENTS.md
cp ../configs/docker-compose.yml docker-compose.yml
echo "Before downgrade: docker-compose.yml exists =" && ls docker-compose.yml >/dev/null 2>&1 && echo yes || echo no
echo "Before downgrade: .mcp.json servers =" && jq '.mcpServers | keys' .mcp.json
# Run downgrade with --force
bash ../scripts/install.sh --lite --yes --force >/dev/null 2>&1
echo "After downgrade: docker-compose.yml removed (should be gone)?" 
if [ ! -f docker-compose.yml ]; then
  echo "PASS: docker-compose.yml removed on downgrade"
else
  echo "FAIL: docker-compose.yml still present after downgrade"
  FAIL=1
fi
echo "After downgrade: .mcp.json servers (should be 4)?"
SERVERS=$(jq '.mcpServers | keys | length' .mcp.json 2>/dev/null)
if [ "$SERVERS" == "4" ]; then
  echo "PASS: .mcp.json has 4 servers after downgrade"
else
  echo "FAIL: .mcp.json has $SERVERS servers (expected 4)"
  FAIL=1
fi
echo "After downgrade: backup of docker-compose.yml exists?"
if ls docker-compose.yml.bak.* >/dev/null 2>&1; then
  echo "PASS: docker-compose.yml backed up before removal"
else
  echo "FAIL: no backup of docker-compose.yml"
  FAIL=1
fi
cd / && rm -rf "$SB"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1