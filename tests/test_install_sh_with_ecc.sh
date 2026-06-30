#!/usr/bin/env bash
# test_install_sh_with_ecc.sh — verify the --with-ecc flag exists, parses, and
# points to ECC's official install path (affaan-m/ECC, /plugin install ecc@ecc).
# ECC is an opt-in replacement for L4+L5, not part of the default composed stack.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. install.sh must accept --with-ecc flag
if grep -q -- '--with-ecc' "$INSTALL"; then
  echo "PASS: install.sh accepts --with-ecc flag"
else
  echo "FAIL: install.sh missing --with-ecc flag"
  FAIL=1
fi

# 2. --with-ecc must set WITH_ECC=true
if grep -q 'WITH_ECC=true\|WITH_ECC="true"\|WITH_ECC.*=.*true' "$INSTALL"; then
  echo "PASS: --with-ecc sets WITH_ECC=true"
else
  echo "FAIL: --with-ecc doesn't set WITH_ECC variable"
  FAIL=1
fi

# 3. --help must mention --with-ecc
if grep -A20 '\-\-help' "$INSTALL" | grep -q -- '--with-ecc'; then
  echo "PASS: --help mentions --with-ecc"
else
  echo "FAIL: --help doesn't mention --with-ecc"
  FAIL=1
fi

# 4. must print the official ECC install path (plugin marketplace add + plugin install ecc@ecc)
if grep -q 'plugin marketplace add.*affaan-m/ECC' "$INSTALL" && grep -q 'plugin install ecc@ecc' "$INSTALL"; then
  echo "PASS: install.sh prints official ECC plugin install path"
else
  echo "FAIL: install.sh missing official ECC install commands"
  FAIL=1
fi

# 5. must NOT auto-install ECC (it's a plugin install, must be done in the agent)
# install.sh should print the commands, not run them
if grep -q "devstrata does not auto-install\|must be done inside the agent" "$INSTALL"; then
  echo "PASS: install.sh does not auto-install ECC (prints commands only)"
else
  echo "FAIL: install.sh may try to auto-install ECC (should print commands only)"
  FAIL=1
fi

# 6. must warn that ECC replaces L4+L5 (don't layer both)
if grep -q "replaces.*L4\|supersedes.*Superpowers\|don't layer both\|Don't layer both" "$INSTALL"; then
  echo "PASS: install.sh warns ECC replaces L4+L5 (don't layer)"
else
  echo "FAIL: install.sh doesn't warn ECC replaces L4+L5"
  FAIL=1
fi

# 7. must mention ECC is MIT + 223k stars (sourced claim)
if grep -q "MIT" "$INSTALL" && grep -q "223k\|223,000\|223835" "$INSTALL"; then
  echo "PASS: install.sh cites ECC license (MIT) + star count (~223k)"
else
  echo "FAIL: install.sh missing ECC license or star count"
  FAIL=1
fi

# 8. SKILLS.md must document ECC as the batteries-included alternative
if grep -q "ECC" "$REPO/docs/SKILLS.md" && grep -q "batteries-included\|monolith" "$REPO/docs/SKILLS.md"; then
  echo "PASS: SKILLS.md documents ECC as batteries-included alternative"
else
  echo "FAIL: SKILLS.md missing ECC documentation"
  FAIL=1
fi

# 9. SKILLS.md must include the "when to pick which" comparison table
if grep -q "Pick the composed default\|Pick ECC" "$REPO/docs/SKILLS.md"; then
  echo "PASS: SKILLS.md has composed-vs-ECC comparison table"
else
  echo "FAIL: SKILLS.md missing composed-vs-ECC comparison"
  FAIL=1
fi

# 10. README must mention --with-ecc
if grep -q -- '--with-ecc' "$REPO/README.md"; then
  echo "PASS: README mentions --with-ecc"
else
  echo "FAIL: README doesn't mention --with-ecc"
  FAIL=1
fi

# 11. SOURCES.md must have an ECC section with verified claims
if grep -q "## Tool: ECC" "$REPO/docs/SOURCES.md"; then
  echo "PASS: SOURCES.md has ECC section with verified claims"
else
  echo "FAIL: SOURCES.md missing ECC section"
  FAIL=1
fi

# 12. ECC must NOT be in the default stack table (it's opt-in, not composed)
# The README stack table lists 11 tools — ECC should not be one of them
if grep -E "^\| L[0-9] " "$REPO/README.md" | grep -q "ECC"; then
  echo "FAIL: ECC is in the default stack table (should be opt-in only)"
  FAIL=1
else
  echo "PASS: ECC is NOT in the default 11-tool stack table (opt-in only)"
fi

# 13. functional test: install.sh --pro --with-ecc --yes runs without crashing
# and prints the ECC install commands
SB=$(mktemp -d)
cp -r "$REPO" "$SB/devstrata" 2>/dev/null
cd "$SB/devstrata" && mkdir -p ecctest && cd ecctest
OUTPUT=$(bash ../scripts/install.sh --lite --with-ecc --yes 2>&1)
RC=$?
if [ "$RC" -eq 0 ] && echo "$OUTPUT" | grep -q "plugin marketplace add.*affaan-m/ECC"; then
  echo "PASS: install.sh --with-ecc runs + prints ECC commands"
else
  echo "FAIL: install.sh --with-ecc failed (RC=$RC) or didn't print ECC commands"
  FAIL=1
fi
cd / && rm -rf "$SB"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1