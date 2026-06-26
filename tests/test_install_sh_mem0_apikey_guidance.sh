#!/usr/bin/env bash
# test_install_sh_mem0_apikey_guidance.sh — verify install.sh tells full/pro users
# they need to run `mem0 init` to get an API key (round 4 friction R4-4).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. install.sh must mention mem0 init in its output (so users know to get their key)
if grep -q 'mem0 init' "$INSTALL"; then
  echo "PASS: install.sh mentions mem0 init (API key setup)"
else
  echo "FAIL: install.sh doesn't mention mem0 init (users hit 'No API key configured')"
  FAIL=1
fi

# 2. install.sh must mention MEM0_API_KEY env var
if grep -q 'MEM0_API_KEY' "$INSTALL"; then
  echo "PASS: install.sh tells users to set MEM0_API_KEY"
else
  echo "FAIL: install.sh doesn't mention MEM0_API_KEY env var"
  FAIL=1
fi

# 3. the mem0 init guidance must be inside the full/pro branch (not lite — lite has no Mem0)
# Check that 'mem0 init' appears after the full/pro branch marker
if grep -A50 'PROFILE" == "full" || "\$PROFILE" == "pro"' "$INSTALL" | grep -q 'mem0 init'; then
  echo "PASS: mem0 init guidance is in the full/pro branch"
else
  echo "FAIL: mem0 init guidance not in the full/pro branch (may show to lite users)"
  FAIL=1
fi

# 4. install.sh must mention agent signup (mem0 init --agent)
if grep -q 'mem0 init.*--agent\|agent-caller' "$INSTALL"; then
  echo "PASS: install.sh mentions agent signup option"
else
  echo "FAIL: install.sh doesn't mention agent signup"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1