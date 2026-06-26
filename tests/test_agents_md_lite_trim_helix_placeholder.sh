#!/usr/bin/env bash
# test_agents_md_lite_trim_helix_placeholder.sh — verify the lite-trim also strips
# HelixDB from the Database Stack placeholder line (round 3 leftover, R3-2).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. The AGENTS.md template must NOT list HelixDB as a generic Database option
# (HelixDB is a tool, not a user's DB choice — the placeholder should be generic)
if grep -q 'PostgreSQL / HelixDB' "$REPO/configs/AGENTS.md.template"; then
  echo "FAIL: AGENTS.md template lists HelixDB in Database placeholder (should be generic)"
  FAIL=1
else
  echo "PASS: AGENTS.md template Database placeholder is generic (no HelixDB)"
fi

# 2. functional test: generate a lite AGENTS.md, verify no HelixDB in Stack line
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p helixtest && cd helixtest
bash ../scripts/install.sh --lite --yes --force >/dev/null 2>&1
if grep -E '^- Database:' AGENTS.md | grep -q 'HelixDB'; then
  echo "FAIL: lite AGENTS.md Stack line still has HelixDB"
  grep 'Database' AGENTS.md | sed 's/^/    /'
  FAIL=1
else
  echo "PASS: lite AGENTS.md Stack line has no HelixDB"
fi
cd / && rm -rf "$SB"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1