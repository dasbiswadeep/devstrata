#!/usr/bin/env bash
# test_cornerstones_intact.sh — verify the 10 guiding principles and 7 architecture
# layers are all present and intact. These are the foundation of devstrata and
# must not be broken by any edit.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# ── 10 Guiding Principles ────────────────────────────────────────────────────
EXPECTED_PRINCIPLES=(
  "Composition over creation"
  "One LLM swap, everything adapts"
  "Memory has exactly four domains"
  "Security is not optional"
  "Process isolation"
  "Profiles match hardware reality"
  "Config files are the product"
  "Honest documentation over marketing"
  "Best-effort maintenance"
  "Educational purpose first"
)

for p in "${EXPECTED_PRINCIPLES[@]}"; do
  if grep -q "$p" "$REPO/docs/GUIDING_PRINCIPLES.md"; then
    echo "PASS: principle present — $p"
  else
    echo "FAIL: principle missing — $p"
    FAIL=1
  fi
done

# Must have exactly 10 numbered principles
PRINCIPLE_COUNT=$(grep -cE '^## [0-9]+\.' "$REPO/docs/GUIDING_PRINCIPLES.md")
if [ "$PRINCIPLE_COUNT" -eq 10 ]; then
  echo "PASS: exactly 10 guiding principles"
else
  echo "FAIL: found $PRINCIPLE_COUNT principles (expected 10)"
  FAIL=1
fi

# ── 7 Architecture Layers (L0-L6) ────────────────────────────────────────────
EXPECTED_LAYERS=(
  "L0"  # Security (Shannon)
  "L1"  # Storage + Memory (HelixDB + Mem0)
  "L2"  # Protocol + Compress (MCP + Headroom)
  "L3"  # Knowledge (Graphify)
  "L4"  # Method + Workflow (Superpowers + GSD)
  "L5"  # Skills + Agent (skills.sh + Hermes)
  "L6"  # PKM (Obsidian)
)

for layer in "${EXPECTED_LAYERS[@]}"; do
  if grep -q "$layer" "$REPO/docs/ARCHITECTURE.md"; then
    echo "PASS: layer present — $layer"
  else
    echo "FAIL: layer missing — $layer"
    FAIL=1
  fi
done

# ── 11 tools in the stack table ─────────────────────────────────────────────
EXPECTED_TOOLS=(
  "Shannon" "HelixDB" "Mem0" "MCP Servers" "Headroom" "Graphify"
  "Superpowers" "GSD Core" "skills.sh" "Hermes Agent" "Obsidian"
)

for tool in "${EXPECTED_TOOLS[@]}"; do
  if grep -q "$tool" "$REPO/README.md"; then
    echo "PASS: tool in README stack — $tool"
  else
    echo "FAIL: tool missing from README — $tool"
    FAIL=1
  fi
done

# ── 3 memory domains preserved ──────────────────────────────────────────────
for domain in "Mem0" "Graphify" "Hermes FTS5" "Obsidian"; do
  if grep -q "$domain" "$REPO/docs/MEMORY_DOMAINS.md"; then
    echo "PASS: memory domain present — $domain"
  else
    echo "FAIL: memory domain missing — $domain"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && exit 0 || exit 1