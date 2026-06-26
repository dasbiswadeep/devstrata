#!/usr/bin/env bash
# test_agent_isolate.sh — verify agent-isolate.sh prevents Hermes/OpenCode conflicts.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
AI="$REPO/scripts/agent-isolate.sh"
FAIL=0

[ -x "$AI" ] && echo "PASS: agent-isolate.sh is executable" || { echo "FAIL: not executable"; FAIL=1; }
bash -n "$AI" 2>/dev/null && echo "PASS: syntax OK" || { echo "FAIL: syntax"; FAIL=1; }

# 1. references all three agent dirs
for dir in ".config/opencode" ".claude" ".hermes"; do
  if grep -q "$dir" "$AI"; then
    echo "PASS: agent-isolate.sh references $dir"
  else
    echo "FAIL: agent-isolate.sh missing $dir"
    FAIL=1
  fi
done

# 2. detects shared skills (symlink detection)
if grep -q "readlink\|symlink\|L " "$AI"; then
  echo "PASS: agent-isolate.sh detects symlinked/shared skills dirs"
else
  echo "FAIL: agent-isolate.sh doesn't detect shared skills"
  FAIL=1
fi

# 3. unlinks shared dirs to make them independent
if grep -q "rm.*skills\|unlink\|independent" "$AI"; then
  echo "PASS: agent-isolate.sh can unlink shared dirs"
else
  echo "FAIL: agent-isolate.sh missing unlink logic"
  FAIL=1
fi

# 4. writes a registry file
if grep -q "registry\|Registry\|INDEX" "$AI"; then
  echo "PASS: agent-isolate.sh writes a skills registry"
else
  echo "FAIL: agent-isolate.sh missing registry output"
  FAIL=1
fi

# 5. recommends picking ONE primary agent
if grep -qi "primary\|pick one\|recommendation" "$AI"; then
  echo "PASS: agent-isolate.sh recommends a single primary agent"
else
  echo "FAIL: agent-isolate.sh missing primary-agent recommendation"
  FAIL=1
fi

# 6. uses set -u
if grep -q "set -u" "$AI" && ! grep -q "^set -e" "$AI"; then
  echo "PASS: agent-isolate.sh uses set -u"
else
  echo "FAIL: agent-isolate.sh missing set -u"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1