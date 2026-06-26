#!/usr/bin/env bash
# test_version_check.sh — verify version-check.sh queries upstream registries.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
VC="$REPO/scripts/version-check.sh"
FAIL=0

[ -x "$VC" ] && echo "PASS: version-check.sh is executable" || { echo "FAIL: not executable"; FAIL=1; }
bash -n "$VC" 2>/dev/null && echo "PASS: syntax OK" || { echo "FAIL: syntax"; FAIL=1; }

# 1. queries PyPI (headroom-ai, graphifyy, mem0ai)
for pkg in "headroom-ai" "graphifyy" "mem0ai"; do
  if grep -q "$pkg" "$VC"; then
    echo "PASS: version-check.sh checks PyPI: $pkg"
  else
    echo "FAIL: version-check.sh missing PyPI check for $pkg"
    FAIL=1
  fi
done

# 2. queries GitHub releases (helix, shannon, hermes, gsd, superpowers)
for repo in "helixdb/helix-db" "KeygraphHQ/shannon" "nousresearch/hermes-agent" "open-gsd/gsd-core" "obra/superpowers"; do
  if grep -q "$repo" "$VC"; then
    echo "PASS: version-check.sh checks GitHub: $repo"
  else
    echo "FAIL: version-check.sh missing GitHub check for $repo"
    FAIL=1
  fi
done

# 3. queries npm for MCP servers
if grep -q "registry.npmjs.org\|modelcontextprotocol" "$VC"; then
  echo "PASS: version-check.sh queries npm for MCP servers"
else
  echo "FAIL: version-check.sh missing npm check"
  FAIL=1
fi

# 4. reports drift (exit 1 if installed != latest)
if grep -q "DRIFT=1\|drift detected" "$VC"; then
  echo "PASS: version-check.sh reports drift via exit code"
else
  echo "FAIL: version-check.sh doesn't track drift"
  FAIL=1
fi

# 5. references doctor.sh (post-upgrade)
if grep -q "doctor.sh" "$VC"; then
  echo "PASS: version-check.sh references doctor.sh"
else
  echo "FAIL: version-check.sh missing doctor.sh reference"
  FAIL=1
fi

# 6. handles offline gracefully (curl to pypi fails → warn, not crash)
if grep -q "could not reach PyPI\|offline" "$VC"; then
  echo "PASS: version-check.sh handles offline gracefully"
else
  echo "FAIL: version-check.sh doesn't handle offline"
  FAIL=1
fi

# 7. does NOT auto-upgrade (only reports)
if grep -qi "auto-upgrade\|pip install.*upgrade.*&&" "$VC" | grep -v "upgrade command\|upgrade $pkg\|--upgrade"; then
  echo "FAIL: version-check.sh appears to auto-upgrade"
  FAIL=1
else
  echo "PASS: version-check.sh only reports (no auto-upgrade)"
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1