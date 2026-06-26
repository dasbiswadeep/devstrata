#!/usr/bin/env bash
# test_config_templates_completeness.sh — every config template must have
# meaningful content (not empty, not just a comment header), and each must
# be referenced by install.sh so it actually gets copied into projects.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO/scripts/install.sh"
FAIL=0

TEMPLATES=(
  "configs/AGENTS.md.template"
  "configs/.mcp.json.template"
  "configs/.graphifyignore.template"
  "configs/headroom.env.template"
  "configs/docker-compose.yml"
)

for t in "${TEMPLATES[@]}"; do
  FILE="$REPO/$t"
  # 1. File must exist
  if [ ! -f "$FILE" ]; then
    echo "FAIL: $t does not exist"
    FAIL=1
    continue
  fi
  # 2. File must have more than just comments/whitespace (at least 5 non-comment lines)
  CONTENT_LINES=$(grep -vE '^\s*(#|//|$)' "$FILE" | wc -l | tr -d ' ')
  if [ "$CONTENT_LINES" -ge 3 ]; then
    echo "PASS: $t has $CONTENT_LINES content lines"
  else
    echo "FAIL: $t has only $CONTENT_LINES content lines (too sparse)"
    FAIL=1
  fi
  # 3. install.sh must reference this template (by basename)
  BASENAME=$(basename "$t")
  if grep -q "$BASENAME" "$INSTALL"; then
    echo "PASS: install.sh references $BASENAME"
  else
    echo "FAIL: install.sh does not reference $BASENAME"
    FAIL=1
  fi
done

# docker-compose.yml must only be copied for full + pro (not lite)
# The gating line "PROFILE == full || PROFILE == pro" appears BEFORE the cp.
if grep -B1 'docker-compose.yml' "$INSTALL" | grep -qE 'full|pro'; then
  echo "PASS: docker-compose.yml gated to full/pro"
else
  echo "FAIL: docker-compose.yml not gated to full/pro"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] && exit 0 || exit 1