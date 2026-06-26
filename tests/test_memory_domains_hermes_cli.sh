#!/usr/bin/env bash
# test_memory_domains_hermes_cli.sh — verify MEMORY_DOMAINS.md uses real Hermes CLI.
# Round 5 found `hermes search` which is NOT a Hermes subcommand. The real commands
# are `hermes sessions list/browse/stats` and `hermes insights`.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOC="$REPO/docs/MEMORY_DOMAINS.md"
FAIL=0

# 1. MEMORY_DOMAINS.md must NOT show `hermes search` as a command (in a bash block)
# It's OK to mention 'hermes search' in prose (explaining it doesn't exist).
# Check for command usage: lines that start with `hermes search` (in code blocks).
if grep -Pzo '```bash\n[^`]*hermes search' "$DOC" 2>/dev/null | grep -q 'hermes search'; then
  echo "FAIL: MEMORY_DOMAINS.md uses 'hermes search' as a command in a code block"
  FAIL=1
else
  echo "PASS: MEMORY_DOMAINS.md no longer uses 'hermes search' as a command"
fi

# 2. must use `hermes sessions` (the real subcommand for conversation history)
if grep -q 'hermes sessions' "$DOC"; then
  echo "PASS: MEMORY_DOMAINS.md uses 'hermes sessions' (real subcommand)"
else
  echo "FAIL: MEMORY_DOMAINS.md doesn't use 'hermes sessions'"
  FAIL=1
fi

# 3. must mention `hermes insights` (the real analytics command)
if grep -q 'hermes insights' "$DOC"; then
  echo "PASS: MEMORY_DOMAINS.md mentions 'hermes insights'"
else
  echo "FAIL: MEMORY_DOMAINS.md missing 'hermes insights'"
  FAIL=1
fi

# 4. should clarify FTS5 search is within sessions browse, not a top-level command
if grep -qi 'FTS5.*search.*within\|sessions browse.*search\|not a top-level' "$DOC"; then
  echo "PASS: MEMORY_DOMAINS.md clarifies FTS5 search is inside sessions browse"
else
  echo "FAIL: MEMORY_DOMAINS.md doesn't clarify FTS5 search location"
  FAIL=1
fi

# 5. pro PROFILE.md must also NOT use `hermes search`
if grep -q 'hermes search' "$REPO/profiles/pro/PROFILE.md"; then
  echo "FAIL: pro PROFILE.md still uses 'hermes search'"
  FAIL=1
else
  echo "PASS: pro PROFILE.md no longer uses 'hermes search'"
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1