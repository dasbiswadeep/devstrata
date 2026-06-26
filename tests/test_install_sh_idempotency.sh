#!/usr/bin/env bash
# test_install_sh_idempotency.sh — verify running install.sh twice produces no errors
# and doesn't duplicate config entries.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# Static checks: install.sh must guard each install step with "already installed" checks
# 1. Headroom: checks command -v before installing (guard may be several lines above pip install)
if grep -q 'command -v headroom' "$INSTALL" && grep -q 'Headroom already installed' "$INSTALL"; then
  echo "PASS: Headroom install guarded (command -v check)"
else
  echo "FAIL: Headroom not guarded against duplicate install"
  FAIL=1
fi

# 2. Graphify: checks command -v before installing
if grep -q 'command -v graphify' "$INSTALL" && grep -q 'Graphify already installed' "$INSTALL"; then
  echo "PASS: Graphify install guarded (command -v check)"
else
  echo "FAIL: Graphify not guarded against duplicate install"
  FAIL=1
fi

# 3. Headroom proxy: checks if running before starting (pgrep)
if grep -q 'pgrep -f.*headroom proxy\|Headroom proxy already running' "$INSTALL"; then
  echo "PASS: Headroom proxy start is idempotent (checks if running)"
else
  echo "FAIL: Headroom proxy may double-start"
  FAIL=1
fi

# 4. .mcp.json: respects existing file (doesn't overwrite without --force)
if grep -qE 'if \[ ! -f ".mcp.json" \] \|\| \[ "\$FORCE"' "$INSTALL"; then
  echo "PASS: .mcp.json respects existing (idempotent)"
else
  echo "FAIL: .mcp.json may overwrite on re-run"
  FAIL=1
fi

# 5. AGENTS.md: respects existing file (may use parens-wrapped condition for --force)
if grep -qE 'if \(\[ ! -f "AGENTS.md" \] \|\| \[ "\$FORCE"' "$INSTALL"; then
  echo "PASS: AGENTS.md respects existing (idempotent)"
else
  echo "FAIL: AGENTS.md may overwrite on re-run"
  FAIL=1
fi

# 6. .graphifyignore + headroom.env: respect existing
if grep -q 'if \[ ! -f ".graphifyignore" \]' "$INSTALL" && grep -q 'if \[ ! -f "headroom.env" \]' "$INSTALL"; then
  echo "PASS: .graphifyignore + headroom.env respect existing"
else
  echo "FAIL: templates may overwrite on re-run"
  FAIL=1
fi

# 7. Functional test: run install twice in a sandbox, verify second run doesn't error
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p idem && cd idem
bash ../scripts/install.sh --lite --yes >/tmp/idem-run1.log 2>&1
RC1=$?
bash ../scripts/install.sh --lite --yes >/tmp/idem-run2.log 2>&1
RC2=$?
if [ "$RC1" -eq 0 ] && [ "$RC2" -eq 0 ]; then
  echo "PASS: both runs exit 0 (idempotent)"
else
  echo "FAIL: run1 RC=$RC1, run2 RC=$RC2 (not idempotent)"
  FAIL=1
fi

# 8. Second run should say "already exists" not "generated" (no overwrite)
if grep -q "already exists\|already running\|already installed" /tmp/idem-run2.log; then
  echo "PASS: second run reports 'already exists' (no duplicate writes)"
else
  echo "FAIL: second run may be re-writing files"
  FAIL=1
fi

cd / && rm -rf "$SB"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1