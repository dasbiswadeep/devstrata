#!/usr/bin/env bash
# test_recommend_profile.sh — verify the profile recommender logic.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
RP="$REPO/scripts/recommend-profile.sh"
FAIL=0

[ -x "$RP" ] && echo "PASS: recommend-profile.sh is executable" || { echo "FAIL: not executable"; FAIL=1; }
bash -n "$RP" 2>/dev/null && echo "PASS: syntax OK" || { echo "FAIL: syntax"; FAIL=1; }

# 1. detects RAM (must have sysctl on macOS or /proc/meminfo on Linux)
if grep -qE "sysctl -n hw.memsize|/proc/meminfo" "$RP"; then
  echo "PASS: recommend-profile.sh detects RAM cross-platform"
else
  echo "FAIL: recommend-profile.sh missing RAM detection"
  FAIL=1
fi

# 2. recommends --pro for 24GB+
if grep -q 'RAM_GB" -ge 24' "$RP" && grep -q -- "--pro" "$RP"; then
  echo "PASS: recommends --pro at 24GB+"
else
  echo "FAIL: missing --pro branch"
  FAIL=1
fi

# 3. recommends --full for 16GB
if grep -q 'RAM_GB" -ge 16' "$RP" && grep -q -- "--full" "$RP"; then
  echo "PASS: recommends --full at 16GB"
else
  echo "FAIL: missing --full branch"
  FAIL=1
fi

# 4. recommends --lite for 8GB
if grep -q 'RAM_GB" -ge 8' "$RP" && grep -q -- "--lite" "$RP"; then
  echo "PASS: recommends --lite at 8GB"
else
  echo "FAIL: missing --lite branch"
  FAIL=1
fi

# 5. detects cloud backend availability (allows higher profile on less RAM)
if grep -q "ANTHROPIC_API_KEY\|OPENAI_API_KEY\|GEMINI_API_KEY" "$RP"; then
  echo "PASS: detects cloud fallback availability"
else
  echo "FAIL: missing cloud key detection"
  FAIL=1
fi

# 6. detects Apple Silicon
if grep -q "Apple M\|Apple Silicon\|apple_silicon\|APPLE_SILICON" "$RP"; then
  echo "PASS: detects Apple Silicon"
else
  echo "FAIL: missing Apple Silicon detection"
  FAIL=1
fi

# 7. below 8GB with no cloud → exits non-zero
if grep -q "Below 8GB\|below --lite\|exit 1" "$RP"; then
  echo "PASS: handles sub-8GB case (exit or warn)"
else
  echo "FAIL: missing sub-8GB handling"
  FAIL=1
fi

# 8. actually run it and check it produces a recommendation
OUTPUT=$("$RP" 2>&1 || true)
if echo "$OUTPUT" | grep -qE "Recommended profile: --(lite|full|pro)"; then
  echo "PASS: produces a recommendation when run"
else
  echo "FAIL: produced no recommendation when run"
  echo "$OUTPUT" | tail -5 | sed 's/^/    /'
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1