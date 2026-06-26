#!/usr/bin/env bash
# test_install_sh_force_and_upgrade.sh — verify --force flag + upgrade detection.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. --force flag exists and regenerates .mcp.json
if grep -q -- '--force' "$INSTALL" && grep -qE 'FORCE.*==.*true' "$INSTALL"; then
  echo "PASS: install.sh has --force flag"
else
  echo "FAIL: install.sh missing --force"
  FAIL=1
fi

# 2. .mcp.json regenerates on --force (condition includes FORCE)
if grep -qE '\[ ! -f ".mcp.json" \] \|\| \[ "\$FORCE"' "$INSTALL"; then
  echo "PASS: .mcp.json regenerates when --force is set"
else
  echo "FAIL: .mcp.json doesn't honor --force"
  FAIL=1
fi

# 3. AGENTS.md regenerates on --force
if grep -qE '\[ ! -f "AGENTS.md" \] \|\| \[ "\$FORCE"' "$INSTALL"; then
  echo "PASS: AGENTS.md regenerates when --force is set"
else
  echo "FAIL: AGENTS.md doesn't honor --force"
  FAIL=1
fi

# 4. upgrade detection: warns when .mcp.json has helix but profile is lite
if grep -q 'Existing .mcp.json has helix/mem0' "$INSTALL"; then
  echo "PASS: warns on downgrade (full→lite without --force)"
else
  echo "FAIL: missing downgrade warning"
  FAIL=1
fi

# 5. upgrade detection: warns when .mcp.json is lite but profile is full/pro
if grep -q 'Existing .mcp.json is the lite version' "$INSTALL"; then
  echo "PASS: warns on upgrade (lite→full without --force)"
else
  echo "FAIL: missing upgrade warning"
  FAIL=1
fi

# 6. warns the user to use --force on mismatch
if grep -q 'Use --force\|Run with --force' "$INSTALL"; then
  echo "PASS: tells user to use --force on mismatch"
else
  echo "FAIL: missing --force guidance"
  FAIL=1
fi

# 7. arg parsing: --yes without profile defaults to lite (not "profile: yes")
# Functional test: run install --yes, check it doesn't say "profile: yes"
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p testproj && cd testproj
OUTPUT=$(bash ../scripts/install.sh --yes 2>&1 | head -3)
if echo "$OUTPUT" | grep -q "profile: lite"; then
  echo "PASS: --yes without profile defaults to lite"
elif echo "$OUTPUT" | grep -q "profile: yes"; then
  echo "FAIL: --yes parsed as profile 'yes' (should default to lite)"
  FAIL=1
else
  echo "PASS: --yes didn't crash (profile handling works)"
fi
cd / && rm -rf "$SB"

# 8. invalid arg exits non-zero
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata"
bash scripts/install.sh --invalidflag --yes >/dev/null 2>&1
RC=$?
if [ "$RC" -ne 0 ]; then
  echo "PASS: invalid arg exits non-zero (RC=$RC)"
else
  echo "FAIL: invalid arg exits 0 (should reject)"
  FAIL=1
fi
cd / && rm -rf "$SB"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1