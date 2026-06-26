#!/usr/bin/env bash
# test_memory_domains_count_consistency.sh — verify all docs consistently say
# "four domains" (Mem0, Graphify, Hermes FTS5, Obsidian), not "three".
# Round 8 found GUIDING_PRINCIPLES #3 said "three" but listed 4 in the table.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# 1. GUIDING_PRINCIPLES must say "four domains" (the table has 4 rows)
if grep -q "exactly four domains\|Memory has exactly four" "$REPO/docs/GUIDING_PRINCIPLES.md"; then
  echo "PASS: GUIDING_PRINCIPLES says 'four domains' (matches 4-row table)"
elif grep -q "exactly three domains\|Memory has exactly three" "$REPO/docs/GUIDING_PRINCIPLES.md"; then
  echo "FAIL: GUIDING_PRINCIPLES still says 'three domains' (table has 4 rows)"
  FAIL=1
else
  echo "FAIL: GUIDING_PRINCIPLES missing the domain-count statement"
  FAIL=1
fi

# 2. MEMORY_DOMAINS.md must say "Four Domains" in the heading
if grep -q "## The Four Domains\|## Four Domains" "$REPO/docs/MEMORY_DOMAINS.md"; then
  echo "PASS: MEMORY_DOMAINS.md heading says 'Four Domains'"
elif grep -q "## The Three Domains\|## Three Domains" "$REPO/docs/MEMORY_DOMAINS.md"; then
  echo "FAIL: MEMORY_DOMAINS.md still says 'Three Domains'"
  FAIL=1
fi

# 3. MEMORY_DOMAINS.md intro must say "four memory systems"
if grep -qi "four memory system\|four memory domain" "$REPO/docs/MEMORY_DOMAINS.md"; then
  echo "PASS: MEMORY_DOMAINS.md intro says 'four memory systems'"
elif grep -qi "three memory system\|three memory domain" "$REPO/docs/MEMORY_DOMAINS.md"; then
  echo "FAIL: MEMORY_DOMAINS.md intro still says 'three'"
  FAIL=1
fi

# 4. ARCHITECTURE.md must say "Four memory systems" (not "Three")
if grep -q "Four memory systems coexist\|four memory systems" "$REPO/docs/ARCHITECTURE.md"; then
  echo "PASS: ARCHITECTURE.md says 'Four memory systems'"
elif grep -q "Three memory systems coexist\|three memory systems" "$REPO/docs/ARCHITECTURE.md"; then
  echo "FAIL: ARCHITECTURE.md still says 'Three memory systems'"
  FAIL=1
fi

# 5. The MCP Memory consequence must say "fifth" (not "fourth") since there are now 4 legitimate domains
if grep -q "fifth memory domain\|a fifth" "$REPO/docs/GUIDING_PRINCIPLES.md"; then
  echo "PASS: MCP Memory correctly described as 'fifth' domain (4 legitimate + 1 unwanted)"
elif grep -q "fourth memory domain\|a fourth" "$REPO/docs/GUIDING_PRINCIPLES.md"; then
  echo "FAIL: GUIDING_PRINCIPLES still says MCP Memory is 'fourth' (should be 'fifth' — there are 4 legitimate domains)"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1