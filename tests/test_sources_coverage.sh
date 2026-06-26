#!/usr/bin/env bash
# test_sources_coverage.sh — every numeric claim in README has a SOURCES.md entry.
# This is a lightweight check: for each tool name in the README stack table,
# verify it has a section in SOURCES.md.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# Tools that should have a SOURCES.md section
TOOLS=(Headroom Mem0 Graphify HelixDB Shannon Superpowers "GSD Core" "Hermes Agent" "MCP Servers" skills.sh Obsidian)

for tool in "${TOOLS[@]}"; do
  if grep -q "## Tool: $tool" "$REPO/docs/SOURCES.md" 2>/dev/null; then
    echo "PASS: SOURCES.md covers '$tool'"
  else
    echo "FAIL: SOURCES.md missing section for '$tool'"
    FAIL=1
  fi
done

# Verify SOURCES.md has a "Verified" date
if grep -q "Last verified:" "$REPO/docs/SOURCES.md"; then
  echo "PASS: SOURCES.md has a Last verified date"
else
  echo "FAIL: SOURCES.md missing Last verified date"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1