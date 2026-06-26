#!/usr/bin/env bash
# test_instructions_no_bun_prereq.sh — verify INSTRUCTIONS.md no longer lists bun
# as a Hermes prerequisite (Hermes installs its own Python/Node/ripgrep/ffmpeg, not bun).
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOC="$REPO/docs/INSTRUCTIONS.md"
FAIL=0

# 1. INSTRUCTIONS.md must NOT list `bun --version` as a prerequisite check
if grep -q 'bun --version' "$DOC"; then
  echo "FAIL: INSTRUCTIONS.md still lists 'bun --version' as a prereq (Hermes doesn't need bun)"
  FAIL=1
else
  echo "PASS: INSTRUCTIONS.md no longer requires bun"
fi

# 2. must NOT recommend installing bun via bun.sh/install
if grep -q 'bun.sh/install' "$DOC"; then
  echo "FAIL: INSTRUCTIONS.md still recommends installing bun"
  FAIL=1
else
  echo "PASS: INSTRUCTIONS.md doesn't recommend bun install"
fi

# 3. must mention uv/uvx (the actual prerequisite for the git MCP server)
if grep -q 'astral.sh/uv/install' "$DOC"; then
  echo "PASS: INSTRUCTIONS.md mentions uv install (needed for git MCP server)"
else
  echo "FAIL: INSTRUCTIONS.md missing uv install guidance"
  FAIL=1
fi

# 4. should clarify Hermes installs its own deps (so users don't pre-install needlessly)
if grep -qi 'Hermes.*installs.*own\|Hermes.*managed\|don.t need to pre-install' "$DOC"; then
  echo "PASS: INSTRUCTIONS.md clarifies Hermes installs its own deps"
else
  echo "FAIL: INSTRUCTIONS.md doesn't clarify Hermes self-installs"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1