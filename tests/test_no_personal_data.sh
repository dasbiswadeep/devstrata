#!/usr/bin/env bash
# test_no_personal_data.sh — scan every file for personal identifiers.
# devstrata must contain ZERO personal project names, PII, personal paths,
# or personal hardware/location details. Enforces the "no personal data" rule.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

# Personal identifiers that must NEVER appear in this open-source repo.
# (Your name in LICENSE/README attribution is allowed — see allowlist below.)
PATTERNS=(
  'biswa-devstrata'      # personal superset name
  'dev-brain'            # personal vault path
  'biswa-brain'          # personal vault name
  'ARTHА'                # personal project (unicode variants)
  'ARTHA'                # personal project
  'artha'                # personal project (lowercase, in prose)
  'VITT'                 # personal project
  'vitt'                 # personal project (lowercase)
  'Hirevine'             # personal project
  'hirevine'             # personal project
  'Refyne'               # employer
  'refyne'               # employer
  'Bangalore'            # personal location
  'bangalore'            # personal location
  'M4 Pro'               # personal hardware
  'Account Aggregator'   # personal fintech domain
  'consent flow'         # personal fintech domain
  'fintech'              # personal domain (in prose only — templates may use generically)
)

# Files where your name (attribution) is ALLOWED — license + README + profile
# docs that show the clone URL (same GitHub handle as attribution).
ALLOWLIST=(
  "$REPO/LICENSE"
  "$REPO/README.md"
  "$REPO/profiles/lite/PROFILE.md"
  "$REPO/profiles/full/PROFILE.md"
  "$REPO/profiles/pro/PROFILE.md"
  "$REPO/docs/INSTRUCTIONS.md"
)

# Files where "Kafka" is allowed (generic tech placeholders in templates).
# We allow Kafka in templates/principles as a generic messaging tech, but not
# tied to a personal pattern like "async Kafka consumers" (handled by other patterns).
KAFKA_ALLOWLIST=(
  "$REPO/configs/AGENTS.md.template"
  "$REPO/docs/SKILLS.md"
)

# This test file itself contains the patterns it scans for (it must, to
# define them). Exclude it from the scan.
SELF="$REPO/tests/test_no_personal_data.sh"

scan() {
  local pattern="$1"
  local file="$2"
  # Skip allowlisted files for name patterns
  for a in "${ALLOWLIST[@]}"; do
    if [ "$file" == "$a" ]; then
      case "$pattern" in
        Biswa|Biswadeep|biswadeep) return 0 ;;
      esac
    fi
  done
  # Skip Kafka allowlist for Kafka-as-generic-tech
  for a in "${KAFKA_ALLOWLIST[@]}"; do
    if [ "$file" == "$a" ] && [[ "$pattern" == "Kafka" || "$pattern" == "kafka" ]]; then
      return 0
    fi
  done
  if grep -qIn "$pattern" "$file" 2>/dev/null; then
    echo "FAIL: personal data '$pattern' in $file"
    grep -In "$pattern" "$file" | head -3 | sed 's/^/    /'
    FAIL=1
  fi
}

# Scan all tracked files (exclude .DS_Store, .git, mnt if recreated, and THIS test file)
FILES=$(find "$REPO" -type f \
          -not -name '.DS_Store' \
          -not -path '*/.git/*' \
          -not -path '*/mnt/*' \
          -not -name '*.pyc' \
          -not -name 'test_no_personal_data.sh' 2>/dev/null)

COUNT=0
for f in $FILES; do
  for p in "${PATTERNS[@]}"; do
    scan "$p" "$f"
    COUNT=$((COUNT+1))
  done
done

# Check that your name appears ONLY in allowlisted files (attribution + clone URL)
NAME_LEAK=0
for f in $FILES; do
  case "$f" in
    "$REPO/LICENSE"|"$REPO/README.md"|"$REPO/profiles/lite/PROFILE.md"|"$REPO/profiles/full/PROFILE.md"|"$REPO/profiles/pro/PROFILE.md"|"$REPO/docs/INSTRUCTIONS.md") continue ;;
  esac
  if grep -qIn 'Biswa\|biswa' "$f" 2>/dev/null; then
    echo "FAIL: name 'Biswa/biswa' found outside allowlisted files in $f"
    grep -In 'Biswa\|biswa' "$f" | head -3 | sed 's/^/    /'
    NAME_LEAK=1
  fi
done

if [ "$FAIL" -eq 0 ] && [ "$NAME_LEAK" -eq 0 ]; then
  echo "PASS: no personal data found ($COUNT scans across $(echo "$FILES" | wc -l | tr -d ' ') files)"
else
  exit 1
fi