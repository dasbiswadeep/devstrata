#!/usr/bin/env bash
# test_install_sh_post_drill_fixes.sh — verify the fixes from the mock-drill
# are in place: --yes flag, absolute paths in next-steps, profile-aware upgrade,
# pro-specific next-steps, 32b pull step, AGENTS.md lite-trimming, uv check.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

# 1. --yes/-y flag skips the interactive prompt
if grep -q -- '--yes' "$INSTALL" && grep -q -- '-y' "$INSTALL"; then
  echo "PASS: install.sh supports --yes/-y to skip prompt"
else
  echo "FAIL: install.sh missing --yes flag"
  FAIL=1
fi

# 2. next-steps use absolute paths (DEVSTRATA_DIR), not ./scripts/
if grep -q 'DEVSTRATA_DIR' "$INSTALL" && grep -q 'bash $DEVSTRATA_DIR' "$INSTALL"; then
  echo "PASS: install.sh uses absolute paths in next-steps"
else
  echo "FAIL: install.sh uses relative ./scripts/ paths (break from project dir)"
  FAIL=1
fi

# 3. profile-aware upgrade path (pro says "top profile", not "upgrade to full")
if grep -q 'This is the top profile' "$INSTALL"; then
  echo "PASS: pro upgrade-path says 'top profile' (not downgrade to full)"
else
  echo "FAIL: pro upgrade-path still suggests downgrade"
  FAIL=1
fi

# 4. pro next-steps include Hermes setup
if grep -q 'hermes setup' "$INSTALL"; then
  echo "PASS: pro next-steps include hermes setup"
else
  echo "FAIL: pro next-steps missing hermes setup"
  FAIL=1
fi

# 5. pro next-steps include Obsidian vault creation
if grep -q 'obsidian-vault\|Obsidian vault' "$INSTALL"; then
  echo "PASS: pro next-steps include Obsidian vault"
else
  echo "FAIL: pro next-steps missing Obsidian"
  FAIL=1
fi

# 6. pro next-steps include 32b model pull
if grep -q 'qwen2.5-coder:32b' "$INSTALL"; then
  echo "PASS: pro next-steps include 32b model pull"
else
  echo "FAIL: pro next-steps missing 32b model"
  FAIL=1
fi

# 7. Step 12 actually exists (the 32b pull step)
if grep -q 'Step 12' "$INSTALL"; then
  echo "PASS: install.sh has Step 12 (32b model)"
else
  echo "FAIL: install.sh missing Step 12"
  FAIL=1
fi

# 8. AGENTS.md lite-trimming (sed removes Mem0/Helix lines for lite)
if grep -q 'lite.*trimmed\|Profile-aware trimming\|sed.*Mem0' "$INSTALL"; then
  echo "PASS: install.sh trims AGENTS.md for lite (no Mem0/Helix references)"
else
  echo "FAIL: install.sh doesn't trim AGENTS.md for lite"
  FAIL=1
fi

# 9. uv/uvx prerequisite check with offer to install
if grep -q 'command -v uvx' "$INSTALL" && grep -q 'astral.sh/uv/install' "$INSTALL"; then
  echo "PASS: install.sh checks uvx + offers to install uv"
else
  echo "FAIL: install.sh missing uvx check/install"
  FAIL=1
fi

# 10. non-interactive read guards (|| true or [ -t 0 ] check)
if grep -q '|| true' "$INSTALL" || grep -q '\[ -t 0 \]' "$INSTALL"; then
  echo "PASS: install.sh guards reads for non-interactive mode"
else
  echo "FAIL: install.sh reads can crash on exhausted stdin"
  FAIL=1
fi

# 11. Node version check extracts MAJOR (not just presence)
if grep -q 'NODE_MAJOR' "$INSTALL"; then
  echo "PASS: install.sh checks Node major version"
else
  echo "FAIL: install.sh doesn't check Node major version"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1